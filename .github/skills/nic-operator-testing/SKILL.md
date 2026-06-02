---
name: nic-operator-testing
description: 'NGINX Ingress Helm Operator testing patterns including bundle validation, E2E tests, and scorecard tests. Use when writing tests, validating changes, or running the test suite.'
---

# Testing Patterns

## Commands

| Command | Purpose |
|---------|---------|
| `make bundle` | Regenerate and validate OLM bundle |
| `operator-sdk bundle validate ./bundle` | Validate bundle structure and content |
| `operator-sdk scorecard ./bundle` | Run OLM scorecard tests |
| `make docker-build` | Build operator image (validates Dockerfile) |
| `make install` | Install CRDs into test cluster |
| `make deploy` | Deploy operator for manual testing |
| `make run` | Run operator locally (fast iteration) |
| `kustomize build config/default` | Validate kustomize overlays render cleanly |

## Validation Tiers

### Tier 1: Static Validation (Always Run)

```bash
# Validate bundle manifests
make bundle
operator-sdk bundle validate ./bundle

# Validate kustomize renders
kustomize build config/default > /dev/null
kustomize build config/crd > /dev/null

# Validate Helm chart
helm lint helm-charts/nginx-ingress/
helm template test helm-charts/nginx-ingress/ > /dev/null
```

### Tier 2: Local Operator Run

```bash
# Install CRD
make install

# Run operator locally (watches for CRs)
make run

# In another terminal, apply a test CR
kubectl apply -f tests/nginx-ingress-controller-oss.yaml

# Verify resources created
kubectl get deployments,services -n <namespace>
```

### Tier 3: In-Cluster Deployment

```bash
# Build and push operator image
make docker-build docker-push

# Deploy to cluster
make deploy

# Apply test CR
kubectl apply -f examples/deployment-oss-min/nginx-ingress-controller.yaml

# Check operator logs
kubectl logs -n nginx-ingress-operator-system deployment/nginx-ingress-operator-controller-manager
```

### Tier 4: OLM Scorecard

```bash
# Build bundle image
make bundle-build bundle-push

# Run scorecard
operator-sdk scorecard ./bundle
```

### Tier 5: E2E (CI Only)

The E2E pipeline (`.github/workflows/e2e-test.yml`) runs daily:
- Spins up Minikube
- Deploys operator from built image
- Applies NginxIngress CR
- Validates NIC deployment is healthy
- Validates service is accessible

## Test CRs

| File | Purpose |
|------|---------|
| `tests/nginx-ingress-controller-oss.yaml` | Basic OSS NIC deployment |
| `examples/deployment-oss-min/nginx-ingress-controller.yaml` | Minimal OSS config |
| `examples/deployment-plus-min/nginx-ingress-controller.yaml` | Minimal Plus config |
| `config/samples/charts_v1alpha1_nginxingress.yaml` | Kustomize sample CR |

## What to Validate After Changes

| Change Type | Validation Required |
|-------------|-------------------|
| Chart values/templates | `helm lint` + `helm template` + Tier 2 local run |
| RBAC changes | `make bundle` + Tier 3 in-cluster deployment |
| CRD changes | `make bundle` + `operator-sdk bundle validate` |
| watches.yaml changes | Tier 2 local run (verify overrides apply) |
| Dockerfile changes | `make docker-build` + Tier 3 deployment |
| Version bumps | Full Tier 1-4 validation |

## Negative Testing

When adding features, verify:
- CR with missing required fields → operator handles gracefully
- CR with invalid values → Helm or schema rejects before deployment
- CR deletion → all managed resources are cleaned up (Helm uninstall)
- Invalid TLS configuration → operator does not deploy with inline certs

## Gotchas

- **Bundle validation is fast** — Always run `make bundle` even for small changes
- **`make run` requires CRDs installed** — Run `make install` first
- **Helm lint may not catch runtime issues** — Always test with actual CR apply
- **Scorecard requires published bundle image** — Cannot run purely locally
- **E2E tests run on schedule** — Not on every PR; use Tier 1-3 for PR validation
- **Test namespace matters** — Some RBAC is namespace-scoped; test in correct namespace
