# Security Policy

This is a portfolio/reference project. It contains **no real customer data** and must not be used to process real payments without a formal security review.

## Reporting a vulnerability
Please open a private [GitHub Security Advisory](../../security/advisories/new) rather than a public issue. Expect an acknowledgement within 72 hours.

## Security controls in this repo
- No long-lived cloud credentials: GitHub Actions authenticate to Azure via **OIDC workload identity federation**.
- Secrets live in **Azure Key Vault** and are mounted into pods with the **Secrets Store CSI driver** + **Workload Identity**.
- Every PR runs **Checkov**, **tfsec/Trivy config**, **Trivy image scan**, **Gitleaks** and **CodeQL**.
- All PaaS data services use **Private Endpoints**; public network access is disabled.
- See [docs/security-compliance.md](docs/security-compliance.md) for the PCI DSS v4.0 control mapping.
