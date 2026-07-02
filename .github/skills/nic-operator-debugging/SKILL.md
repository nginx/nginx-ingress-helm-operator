---
name: nic-operator-debugging
description: 'NGINX Ingress Helm Operator debugging patterns, common failure modes, and troubleshooting. Use when diagnosing operator failures, tracing reconciliation issues, investigating deployment errors, or fixing bugs.'
---

# Debugging and Troubleshooting

## Common Failure Modes

### 1. Helm Reconciliation Failed

**Symptoms:** NginxIngress CR status shows error, NIC not deployed or partially deployed.

**Diagnosis:**
```bash
# Check operator logs
kubectl logs -n nginx-ingress-operator-system deployment/nginx-ingress-operator-controller-manager

# Look for Helm errors
kubectl logs -n nginx-ingress-operator-system deployment/nginx-ingress-operator-controller-manager | grep -i "error\|failed"

# Check CR status
kubectl get nginxingress <name> -o yaml | yq '.status'
```

**Common causes:**
- Invalid values in CR spec (Helm template render failure)
- Missing RBAC permissions (operator can't create resources)
- Namespace doesn't exist
- Image pull failures (wrong registry or missing pull secret)

### 2. RBAC Permission Denied

**Symptoms:** Operator logs show `forbidden` errors when trying to create/update resources.

**Diagnosis:**
```bash
# Check what the operator is trying to do
kubectl logs -n nginx-ingress-operator-system deployment/nginx-ingress-operator-controller-manager | grep "forbidden"

# Verify ClusterRole has needed permission
kubectl get clusterrole nginx-ingress-operator-manager-role -o yaml
```

**Fix:** Add missing permission to `config/rbac/role.yaml`, then `make bundle` and redeploy.

### 3. CRD Not Recognized

**Symptoms:** `kubectl apply` for NginxIngress CR fails with "no matches for kind".

**Diagnosis:**
```bash
# Check if CRD exists
kubectl get crd nginxingresses.charts.nginx.org

# If missing, install it
make install
```

### 4. Operator Pod CrashLoopBackOff

**Symptoms:** Operator pod restarts repeatedly.

**Diagnosis:**
```bash
# Check pod events
kubectl describe pod -n nginx-ingress-operator-system -l control-plane=controller-manager

# Check container logs (previous instance)
kubectl logs -n nginx-ingress-operator-system deployment/nginx-ingress-operator-controller-manager --previous
```

**Common causes:**
- `watches.yaml` syntax error or missing chart path
- Helm chart not present in container (Dockerfile build issue)
- Leader election failure (multiple operators competing)

### 5. NIC Deployed But Not Working

**Symptoms:** NginxIngress CR reconciled successfully, NIC pods running, but ingress not routing traffic.

**Diagnosis:** This is a NIC issue, not an operator issue. Check:
```bash
# NIC pod logs
kubectl logs -n <nic-namespace> deployment/<nic-deployment>

# NIC config validity
kubectl exec -n <nic-namespace> <nic-pod> -- nginx -t

# IngressClass created?
kubectl get ingressclass
```

### 6. Bundle Validation Failures

**Symptoms:** `make bundle` or `operator-sdk bundle validate` fails.

**Diagnosis:**
```bash
# Run validation with verbose output
operator-sdk bundle validate ./bundle --verbose

# Common issues:
# - CSV missing required fields
# - CRD schema mismatch
# - Annotations file format error
```

## Log Locations

| Log | How to access | What it shows |
|-----|---------------|---------------|
| Operator logs | `kubectl logs -n nginx-ingress-operator-system deploy/nginx-ingress-operator-controller-manager` | Reconciliation events, Helm operations, errors |
| Operator events | `kubectl get events -n nginx-ingress-operator-system` | Pod scheduling, image pulls, restarts |
| NIC logs | `kubectl logs -n <ns> deploy/<nic-name>` | NGINX Ingress Controller runtime (NOT operator) |
| Helm release | `kubectl get secret -n <ns> -l owner=helm` | Helm release state stored as secrets |

## Validation Tools

| Tool | Command | What it checks |
|------|---------|----------------|
| Bundle validate | `operator-sdk bundle validate ./bundle` | OLM bundle structure and content |
| Helm lint | `helm lint helm-charts/nginx-ingress/` | Chart syntax and best practices |
| Helm template | `helm template test helm-charts/nginx-ingress/` | Template rendering without cluster |
| Kustomize build | `kustomize build config/default` | Kustomize overlay correctness |
| Dry-run apply | `kubectl apply --dry-run=server -f <cr.yaml>` | CR validation against CRD |

## Debugging Workflow

1. **Reproduce** — Get the exact error message from operator logs or CR status
2. **Locate** — Identify which layer failed:
   - `watches.yaml` issue → operator won't start
   - RBAC issue → operator logs show `forbidden`
   - Helm render issue → operator logs show template errors
   - Resource creation issue → operator logs show K8s API errors
3. **Isolate** — Test with minimal CR (`examples/deployment-oss-min/`)
4. **Fix** — Make the change in the correct layer
5. **Verify** — Run `make bundle` + redeploy + reapply CR
6. **Prevent** — Add validation or documentation to catch this in future

## Security During Debugging

- **Never log secrets** — If debugging TLS issues, check Secret existence, not content
- **Check exploitability** — If the bug allows bypassing TLS defaults in `watches.yaml`, treat as security issue
- **Credential masking** — Operator logs should not contain certificate data or keys
- **RBAC audit** — If fixing a "forbidden" error, verify the permission is actually needed (not just adding blanket access)

## Quick Reference: Is This an Operator Issue?

| Symptom | Operator issue? | Where to look |
|---------|----------------|---------------|
| CR not reconciling | Yes | Operator logs |
| NIC pods not starting | Maybe | Operator logs first, then NIC pod events |
| Ingress not routing | No | NIC logs, nginx config |
| TLS not working | Maybe | Check if watches.yaml overrides applied correctly |
| Metrics missing | Maybe | Check kube-rbac-proxy sidecar |
| OLM install fails | Yes | Bundle manifests, CSV |
