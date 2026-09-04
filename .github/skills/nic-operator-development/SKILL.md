---
name: nic-operator-development
description: 'NGINX Ingress Helm Operator development checklists and patterns. Use when adding new features, updating the embedded Helm chart, modifying CRD or RBAC, bumping NIC versions, or changing operator configuration.'
---

# Development Patterns

## Updating the Embedded Helm Chart

The most common development task. The chart at `helm-charts/nginx-ingress/` is synced from the upstream NGINX Ingress Controller Helm chart.

### Checklist

1. Update files in `helm-charts/nginx-ingress/` (values.yaml, templates/, crds/, Chart.yaml)
2. If new values added: update `values.schema.json`
3. If new CRDs added to `helm-charts/nginx-ingress/crds/`: update RBAC in `config/rbac/role.yaml`
4. Update example CRs in `examples/` to demonstrate new features
5. Run `make bundle` to regenerate OLM manifests
6. Validate: `operator-sdk bundle validate ./bundle`
7. Update version matrix in `README.md` if NIC version changed
8. Update `CHANGELOG.md` or ensure GitHub Release notes will cover it

## Bumping NIC Version

### Checklist

1. Update `helm-charts/nginx-ingress/Chart.yaml`:
   - `appVersion` → new NIC version
   - `version` → new chart version
2. Update `helm-charts/nginx-ingress/values.yaml`:
   - `controller.image.tag` → new image tag
3. Update image references in examples:
   - `examples/deployment-oss-min/nginx-ingress-controller.yaml`
   - `examples/deployment-plus-min/nginx-ingress-controller.yaml`
4. Update `README.md` version compatibility table
5. Run `make bundle` to regenerate
6. Validate bundle

## Bumping Operator Version

### Checklist

1. Update `VERSION` in `Makefile` (e.g., `3.6.0` → `3.7.0`)
2. Update `REPLACES` in `Makefile` to previous version (e.g., `nginx-ingress-operator.v3.6.0`)
3. Run `make bundle` to regenerate all OLM manifests (this patches the image in `config/manager/` via kustomize)
4. Validate bundle
5. Tag release: `git tag v3.7.0`

## Modifying RBAC

### Checklist

1. Edit `config/rbac/role.yaml` to add/remove permissions
2. Verify the operator actually needs the permission (check Helm chart templates)
3. Run `make bundle` to propagate changes to `bundle/manifests/`
4. Audit: ensure no excessive permissions granted
5. If OpenShift SCC needed: update `resources/scc.yaml`

## Adding watches.yaml Overrides

### Security Considerations

The `overrideValues` in `watches.yaml` are applied to EVERY NginxIngress CR. They exist primarily for security (forcing TLS defaults to empty). Adding overrides requires careful thought:

1. Edit `watches.yaml`
2. Document WHY the override exists (comment in watches.yaml)
3. Verify the override doesn't break existing deployments
4. Update documentation if user-visible behavior changes

## Modifying Kustomize Configuration

### Files and Relationships

```
config/default/kustomization.yaml    → references config/manager and config/rbac
config/manager/kustomization.yaml    → operator Deployment
config/manifests/kustomization.yaml  → input for bundle generation
config/crd/kustomization.yaml        → CRD with patches
```

### Checklist

1. Make changes in the appropriate config/ subdirectory
2. Verify kustomize builds cleanly: `kustomize build config/default`
3. Run `make bundle` to propagate to bundle/
4. Test deployment: `make deploy`

## Input Validation

Since the CRD uses `x-kubernetes-preserve-unknown-fields: true`, validation happens at the Helm level:

- `values.schema.json` — JSON Schema validates values before Helm render
- Helm template logic — Templates can fail on invalid combinations
- NGINX config validation — NIC validates generated nginx.conf at runtime

When adding new values, ensure:
1. Schema constraints in `values.schema.json` catch obvious errors
2. Template conditionals handle missing/empty values gracefully
3. Document valid value ranges in `values.yaml` comments

## Gotchas

- **Never add Go source files** — This is a pure Helm operator
- **Always run `make bundle` after config/ changes** — Bundle gets out of sync silently
- **Chart is embedded, not referenced** — Changes to upstream chart must be manually synced
- **`watches.yaml` overrides apply globally** — They affect all NginxIngress CRs in the cluster
- **Image tags use UBI base** — Default tags end in `-ubi` for Red Hat certification
- **Schema and values must agree** — `values.schema.json` must match `values.yaml` structure
