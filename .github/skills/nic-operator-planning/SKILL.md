---
name: nic-operator-planning
description: 'NGINX Ingress Helm Operator task planning and approach strategy. Use when starting any non-trivial task, reading issues or specs, or when asked to plan before implementing.'
---

# Planning and Task Approach

## Before Writing Code

1. **Read the requirement** — Understand what's being asked. Check linked issues, specs, or PRs.
2. **Identify affected layers** — Use the architecture to determine which layers are touched:
   - `watches.yaml` (operator core config)
   - `helm-charts/nginx-ingress/` (chart templates, values, schema)
   - `config/crd/` (CRD definitions)
   - `config/rbac/` (RBAC permissions)
   - `config/manager/` (operator deployment)
   - `bundle/` (OLM manifests)
   - `examples/` (sample CRs)
   - `docs/` (user documentation)
3. **Check invariants** — Review copilot-instructions.md Key Invariants section for rules that apply.
4. **Identify test surface** — What tests need to be added or updated?
5. **Produce a plan** — State your approach before coding.

## Layer Impact Checklist

For any change, ask:
- [ ] Does it touch `watches.yaml`? → Affects default overrides for ALL NginxIngress CRs
- [ ] Does it touch the Helm chart? → Update `values.yaml`, `values.schema.json`, templates, and examples
- [ ] Does it add new K8s resources? → Update RBAC in `config/rbac/role.yaml`
- [ ] Does it change CRD structure? → Run `make bundle` to regenerate
- [ ] Does it affect container image? → Update Dockerfile if needed, verify multi-arch
- [ ] Does it affect OLM? → Regenerate bundle, update CSV annotations

## Security Impact Assessment

Before implementing, verify:
- [ ] Does this change accept new external input? → Validate at trust boundary
- [ ] Does this change touch credential/secret paths? → Use Secret references only
- [ ] Does this change modify RBAC? → Audit for least privilege
- [ ] Does this change affect container security context? → Verify no privilege escalation
- [ ] Does this expose new network endpoints? → Ensure TLS by default

## Scope Assessment

| Scope | Action |
|-------|--------|
| Trivial (typo, docs) | Fix directly, no plan needed |
| Small (chart value, single template) | Brief plan, implement, validate bundle |
| Medium (new chart feature, RBAC change) | Detailed plan, implement, regenerate bundle, update docs |
| Large (NIC version bump, architecture) | Write spec first, update version matrix, full bundle regen |

## Common Planning Mistakes

- Forgetting to run `make bundle` after RBAC/CRD/manager changes
- Not updating `values.schema.json` when adding new chart values
- Missing example CR updates when adding features
- Not checking version compatibility matrix in README
- Adding Go code (this is a pure Helm operator — no Go allowed)
- Changing `watches.yaml` overrides without considering security implications
