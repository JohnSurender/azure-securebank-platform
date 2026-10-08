# Security and PCI DSS v4.0 control mapping

> This mapping shows how platform controls **support** PCI DSS requirements. Formal compliance requires a QSA assessment; this is a reference implementation.

| PCI DSS v4.0 requirement | Control in this repo | Where |
|---|---|---|
| 1.2 / 1.3 Network security controls, restrict CDE access | Hub-spoke, NSG deny-all on private endpoint subnet, default-deny NetworkPolicy, WAF | `infra/modules/network`, `deploy/k8s/base/default-deny.yaml`, `infra/modules/appgw` |
| 1.4 No direct public access to CDE | `public_network_access_enabled = false` on Key Vault and PostgreSQL; Private Endpoints | `infra/modules/keyvault`, `infra/modules/postgres` |
| 2.2 Secure configuration | Pod Security `restricted`, non-root, read-only rootfs, drop ALL caps, Azure Linux nodes | `deploy/helm/.../deployment.yaml`, `deploy/k8s/base/namespace.yaml` |
| 3.5 / 3.6 Protect stored data, key management | Key Vault Premium (HSM), purge protection, RBAC; PostgreSQL encryption at rest | `infra/modules/keyvault` |
| 3.4 Mask PAN / account data when displayed | Account numbers masked in logs (`***1234`) | `apps/transactions-service/app/main.py` |
| 4.2 Strong cryptography in transit | TLS 1.2+ App Gateway policy, `require_secure_transport=on` on PostgreSQL | `infra/modules/appgw`, `infra/modules/postgres` |
| 5.2 / 11.3 Malware and vulnerability management | Defender for Containers, Trivy (block HIGH/CRITICAL), Dependabot, image cleaner | `.github/workflows`, `infra/modules/aks` |
| 6.2 / 6.3 Secure development | CodeQL, Checkov, Gitleaks, mandatory PR review via CODEOWNERS | `.github/` |
| 6.4 Protect public web apps | WAF v2 in Prevention mode with OWASP DRS 2.1 | `infra/modules/appgw` |
| 6.5 Change management | PR plans, GitHub Environment approvals, Conventional Commits, CHANGELOG | `.github/workflows/terraform-apply.yml` |
| 7.2 / 8.2 Least privilege, unique IDs | Entra ID RBAC for AKS, local accounts disabled, Workload Identity per service account | `infra/modules/aks` |
| 8.3 / 8.4 Strong auth, MFA | Entra ID with Conditional Access + PIM for engineers (tenant-level) | documented |
| 8.6 No hard-coded system credentials | GitHub OIDC federation; DB password generated and stored only in Key Vault | `bootstrap/02-setup-github-oidc.sh`, `infra/modules/postgres` |
| 10.2 / 10.3 Audit logs | Diagnostic settings on Key Vault, ACR, PostgreSQL, App Gateway; Container Insights | all modules |
| 10.5.1 Retain logs 12 months | 365-day Log Analytics retention in prod | `infra/envs/prod/terraform.tfvars` |
| 10.4 / 10.7 Review logs, detect failures | KQL detections + alert catalogue | `monitoring/` |
| 12.10 Incident response plan | Incident runbook | `docs/runbooks/incident-response.md` |

## Threat model highlights (STRIDE)

| Threat | Mitigation |
|---|---|
| Spoofing - stolen CI credential | No secrets exist; OIDC tokens scoped to repo/branch/environment |
| Tampering - malicious image | ACR-only Gatekeeper policy, Trivy scan, content trust, immutable SHA tags |
| Repudiation - untraceable transfer | Idempotency keys + structured audit logs retained 365 days |
| Information disclosure - DB exposed | Private endpoint only, NSG, TLS, Entra auth |
| Denial of service | WAF rate limit (300 req/min/IP), HPA, zone-redundant gateway |
| Elevation of privilege - container breakout | PSS restricted, no privilege escalation, dropped capabilities, Defender runtime alerts |
