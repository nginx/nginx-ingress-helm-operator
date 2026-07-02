# Agent Instructions

NGINX Ingress Helm Operator — a Kubernetes/OpenShift operator that deploys and manages NGINX Ingress Controllers via Helm-based reconciliation using the Operator Framework SDK. Built on `helm-operator` (no Go code), it watches `NginxIngress` CRs and translates them into Helm chart install/upgrade/uninstall operations.

## References

| Topic | Link |
|-------|------|
| NGINX Ingress Controller Docs | https://docs.nginx.com/nginx-ingress-controller/ |
| Operator Framework (Helm) | https://sdk.operatorframework.io/docs/building-operators/helm/ |
| Contributing Guide | CONTRIBUTING.md |
| Installation Docs | docs/installation.md |

## Build, Test, Validate

| Command | Purpose |
|---------|---------|
| `make docker-build` | Build operator Docker image |
| `make docker-buildx` | Cross-platform build (linux/amd64, linux/arm64) |
| `make run` | Run operator locally against configured cluster |
| `make install` | Install CRDs into cluster |
| `make deploy` | Deploy operator to cluster (sets image via kustomize) |
| `make bundle` | Regenerate OLM bundle manifests and validate |
| `make bundle-build` | Build OLM bundle image |
| `make catalog-build` | Build OLM catalog image |
| `make update-openshift-versions` | Update supported OpenShift version range |

After changing helm chart values or CRD structure, run `make bundle` to regenerate bundle manifests. Always validate bundle with `operator-sdk bundle validate ./bundle`.

## Project Layout

| Path | Purpose |
|------|---------|
| `watches.yaml` | Maps NginxIngress CRD to helm chart — the operator's core config |
| `helm-charts/nginx-ingress/` | Embedded NGINX Ingress Controller Helm chart |
| `config/crd/` | CRD base definitions and kustomize overlays |
| `config/rbac/` | RBAC roles, bindings, service accounts |
| `config/manager/` | Operator deployment manifest |
| `config/default/` | Default kustomize overlay (namespace, patches) |
| `bundle/` | OLM bundle manifests, metadata, scorecard tests |
| `examples/` | Sample NginxIngress CR deployments (OSS, Plus) |
| `docs/` | Installation, upgrade, and usage documentation |
| `scripts/` | Automation scripts (OpenShift version updates) |

## Skills

| Skill | SDLC Stage | When to load |
|-------|------------|--------------|
| `nic-operator-planning` | Plan | Starting any non-trivial task |
| `nic-operator-architecture` | Plan + Dev | Exploring codebase, understanding reconciliation flow |
| `nic-operator-development` | Dev | Adding features, updating chart, modifying CRD |
| `nic-operator-testing` | Test | Writing tests, validating changes |
| `nic-operator-debugging` | Bugfix | Diagnosing operator or chart failures |
| `nic-operator-ci-release` | Review | CI workflows, build pipeline, OLM release |

## Key Invariants

- **No Go code** — This is a pure Helm-based operator. All reconciliation logic is in `watches.yaml` + Helm chart. Never add Go source files.
- **Chart is the source of truth** — `helm-charts/nginx-ingress/` defines all deployable configuration. CRD spec fields map directly to Helm values.
- **Bundle must stay in sync** — After any change to CRD, RBAC, or manager config, run `make bundle` to regenerate OLM manifests.
- **CRD uses preserve-unknown-fields** — The `NginxIngress` CRD uses `x-kubernetes-preserve-unknown-fields: true` to pass all spec values through to Helm without schema validation at the CRD level.
- **Security: TLS defaults are empty** — `watches.yaml` overrides TLS cert/key to empty strings by default so users must explicitly provide secrets.
- **RBAC is broad by design** — The operator needs permissions across many resource types to manage NIC deployments; changes to RBAC require careful audit.
- **Multi-arch support** — Images must build for both `linux/amd64` and `linux/arm64`.

## Code Review Checklist

### Security
- RBAC changes: does the operator request only necessary permissions?
- TLS/secret handling: are credentials passed via Secret references, never inline?
- Container security: no privilege escalation, appropriate SecurityContextConstraints?

### Correctness
- Chart value changes reflected in `values.yaml`, `values.schema.json`, and examples?
- `watches.yaml` overrideValues match expected defaults?
- Version matrix updated in README when bumping NIC version?

### Architecture
- No Go source files added (pure Helm operator pattern)?
- Bundle regenerated after CRD/RBAC/manager changes?
- Kustomize overlays consistent across config/ subdirectories?
