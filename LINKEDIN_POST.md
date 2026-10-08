# LinkedIn post (ready to copy)

---

How would you build the cloud platform for a UK bank?

I set myself that challenge and built **SecureBank Platform**, an end-to-end Azure reference architecture for a retail-banking app (accounts + money transfers), designed the way a regulated environment would expect.

What's inside:

▪ **Terraform modules** for hub-and-spoke networking, AKS, ACR, Key Vault, PostgreSQL and App Gateway, with separate dev / staging / prod environments and isolated remote state
▪ **Zero-trust networking**: Private Endpoints for every data service, NSGs, Cilium network policies with default-deny
▪ **WAF v2** in Prevention mode with OWASP rules, bot protection and rate limiting
▪ **No secrets anywhere**: GitHub Actions deploys to Azure via OIDC, and apps read credentials from Key Vault through Workload Identity
▪ **CI/CD with gates**: Checkov, tflint, Gitleaks, CodeQL and Trivy on every PR, and Terraform plans posted as PR comments, then promotion dev → staging → prod with approvals and automatic Helm rollback
▪ **Resilience**: 3 availability zones, zone-redundant PostgreSQL HA, geo-backups, and a documented DR runbook
▪ **Compliance**: controls mapped to PCI DSS v4.0, 365-day audit log retention, plus Azure Policy for UK data residency

The part I learned most from was designing the security boundaries: making sure that even if a pod were compromised, it couldn't reach anything it didn't explicitly need.

Architecture diagrams, ADRs, runbooks and a full step-by-step build guide are in the repo
🔗 github.com/JohnSurender/azure-securebank-platform

I'm open to Azure Cloud / DevOps Engineer roles in London and across the UK, and I don't need visa sponsorship. Feedback from anyone working in financial-services cloud is very welcome.

#Azure #Terraform #Kubernetes #AKS #DevOps #CloudEngineering #FinTech #DevSecOps #GitHubActions #InfrastructureAsCode #AZ104 #LondonJobs #UKTech

---

**Attach:** `docs/images/architecture.png`, `docs/images/cicd-pipeline.png`
**First comment:** "Repo link: https://github.com/JohnSurender/azure-securebank-platform - the BUILD_GUIDE.md walks through every step if you want to deploy it yourself."

## LinkedIn Projects section entry

**Name:** SecureBank Platform - Production-grade Azure Banking Infrastructure
**Description:** Multi-environment Azure platform for a retail-banking application using Terraform modules, AKS (CNI Overlay + Cilium), Application Gateway WAF v2, Key Vault HSM, PostgreSQL Flexible Server HA and Private Endpoints. Secretless CI/CD with GitHub Actions OIDC, Checkov/Trivy/CodeQL security gates, Helm-based deployment with approval-gated promotion, and controls mapped to PCI DSS v4.0.
**Skills:** Terraform · Azure Kubernetes Service · GitHub Actions · Azure Key Vault · DevSecOps
