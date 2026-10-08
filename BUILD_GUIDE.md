# Step-by-step build guide

Follow these steps to create this repository from scratch, deploy it to Azure, and publish it on LinkedIn. Allow roughly 1-2 days of work spread over a week.

---

## Phase 0 - Prerequisites (30 min)

| Tool | Install | Check |
|---|---|---|
| Azure subscription | Free trial or Pay-As-You-Go | `az account show` |
| Azure CLI 2.65+ | https://learn.microsoft.com/cli/azure/install-azure-cli | `az version` |
| Terraform 1.9+ | https://developer.hashicorp.com/terraform/install | `terraform -version` |
| kubectl + kubelogin | `az aks install-cli` | `kubectl version --client` |
| Helm 3 | https://helm.sh/docs/intro/install/ | `helm version` |
| Docker Desktop | https://docs.docker.com/get-docker/ | `docker run hello-world` |
| Python 3.12 | https://www.python.org/downloads/ | `python --version` |
| Git + GitHub account | https://git-scm.com | `git --version` |
| Optional: tflint, checkov, trivy, pre-commit | `brew install tflint trivy` / `pip install checkov pre-commit` | |

```bash
az login
az account set --subscription "<your-subscription-id>"
```

> Cost warning: AKS, App Gateway WAF v2 and Premium SKUs cost money. Deploy **dev only**, take your screenshots, then run `make destroy ENV=dev`. Set a budget alert first.

---

## Phase 1 - Create the GitHub repository (10 min)

1. On GitHub: **New repository** -> name `azure-securebank-platform` -> Public -> no README (we have one).
2. Locally:
   ```bash
   mkdir azure-securebank-platform && cd azure-securebank-platform
   git init -b main
   ```
3. Copy every file from this project into the folder (or unzip the archive), keeping the folder structure exactly as shown in the README.
4. First commit:
   ```bash
   git add .
   git commit -m "feat: initial SecureBank platform scaffold"
   git remote add origin https://github.com/JohnSurender/azure-securebank-platform.git
   git push -u origin main
   ```

---

## Phase 2 - Run and test locally (20 min)

```bash
cp .env.example .env
make test            # 9 unit tests should pass
make up              # start postgres + 3 services
curl localhost:8001/healthz
curl localhost:8002/healthz
open http://localhost:8080
make down
```

Install the pre-commit hooks so every commit is checked:
```bash
pip install pre-commit && pre-commit install
pre-commit run --all-files
```

---

## Phase 3 - Bootstrap Azure (20 min)

### 3.1 Remote Terraform state
```bash
./bootstrap/01-create-tfstate.sh
# note the printed storage account name, e.g. stsecurebanktf12345
```
Replace `stsecurebanktfXXXXX` in **all three** `infra/envs/*/backend.tf` files with that name. Give yourself data access to the state:
```bash
SA_ID=$(az storage account show -n <name> -g rg-securebank-tfstate-uks --query id -o tsv)
az role assignment create --assignee $(az ad signed-in-user show --query id -o tsv) \
  --role "Storage Blob Data Contributor" --scope $SA_ID
```

### 3.2 GitHub OIDC federation (no secrets)
```bash
GITHUB_REPO=JohnSurender/azure-securebank-platform ./bootstrap/02-setup-github-oidc.sh
```
Grant the same pipeline identity access to the state account:
```bash
az role assignment create --assignee <AZURE_CLIENT_ID> --role "Storage Blob Data Contributor" --scope $SA_ID
```

### 3.3 Configure GitHub
In **Settings -> Secrets and variables -> Actions**:
- Secrets: `AZURE_CLIENT_ID`, `AZURE_TENANT_ID`, `AZURE_SUBSCRIPTION_ID`
- Variables: `ACR_NAME` = `acrsecurebankdevuks`, `WORKLOAD_CLIENT_ID` (set after Phase 4)

In **Settings -> Environments** create `dev`, `staging`, `prod`:
- `staging`: required reviewers = you
- `prod`: required reviewers = you, deployment branch = `main` only, wait timer 10 min

In **Settings -> Branches** add a rule for `main`: require PR, 1 approval, status checks `static-checks` and `test`.

---

## Phase 4 - Deploy dev infrastructure (30-40 min)

1. Edit `infra/envs/dev/terraform.tfvars`:
   - `alert_email` = your email
   - `aks_api_authorized_ip_ranges = ["<your-public-ip>/32"]` (find it with `curl ifconfig.me`)
2. Get your Entra ID object ID and add it as an AKS admin (or create a group):
   ```bash
   az ad signed-in-user show --query id -o tsv
   ```
   Put it in `aks_admin_group_ids` (a group ID is best practice).
3. Deploy:
   ```bash
   make fmt
   make init ENV=dev
   make plan ENV=dev     # review: ~45 resources to add
   make apply ENV=dev
   ```
4. Note the outputs:
   ```bash
   terraform -chdir=infra/envs/dev output
   ```
   Copy `workload_identity_client_id` into the GitHub variable `WORKLOAD_CLIENT_ID`.

Common errors:
| Error | Fix |
|---|---|
| `name already taken` (ACR / Key Vault) | Names are global - add a suffix in `locals` in `main.tf` |
| `403` on Key Vault secret | Wait 2-5 min for RBAC propagation and re-apply |
| Quota exceeded for vCPU | Request quota increase or use smaller `aks_apps_vm_size` |
| Postgres zone not available | Remove `zone = "1"` or choose another zone |

---

## Phase 5 - Deploy the applications (20 min)

Option A - through the pipeline (recommended, this is what recruiters want to see):
```bash
git checkout -b feature/first-deploy
echo "" >> apps/accounts-service/app/main.py
git commit -am "feat: trigger first deployment"
git push -u origin feature/first-deploy
```
Open a PR -> watch checks pass -> merge -> `app-ci-cd` builds, scans, pushes and deploys to dev.

Option B - manually:
```bash
az acr login -n acrsecurebankdevuks
for s in accounts-service transactions-service web-frontend; do
  docker build -t acrsecurebankdevuks.azurecr.io/$s:v1 apps/$s
  docker push acrsecurebankdevuks.azurecr.io/$s:v1
done
az aks get-credentials -g rg-securebank-dev-uks -n aks-securebank-dev-uks
kubelogin convert-kubeconfig -l azurecli
kubectl apply -f deploy/k8s/base/
helm upgrade --install accounts-service deploy/helm/banking-service -n securebank \
  -f deploy/helm/banking-service/values.yaml -f deploy/helm/banking-service/values-dev.yaml \
  --set nameOverride=accounts-service --set image.tag=v1 \
  --set image.repository=acrsecurebankdevuks.azurecr.io/accounts-service
```
Validate:
```bash
kubectl -n securebank get pods,svc,ingress,hpa
bash scripts/smoke-test.sh dev
```

---

## Phase 6 - Capture evidence screenshots (20 min)

Create `docs/screenshots/` and add (blur subscription IDs and emails):
1. Azure portal resource group view showing all resources
2. AKS -> Workloads showing the 3 deployments running
3. Application Gateway -> WAF policy (Prevention mode, managed rules)
4. Key Vault -> Networking (public access disabled)
5. GitHub Actions -> a green `app-ci-cd` run showing dev -> staging approval gate
6. A PR with the Terraform plan comment
7. Defender for Cloud -> recommendations / secure score
8. Log Analytics running one of the KQL queries in `monitoring/kql/queries.kql`

Reference them from the README under a new **Screenshots** section. Real screenshots prove it was deployed, not just written.

---

## Phase 7 - Tear down (5 min)

```bash
make destroy ENV=dev
# Key Vault has purge protection: it will stay soft-deleted for 90 days (no cost)
```
Keep the remote-state resource group (costs pennies).

---

## Phase 8 - Polish the repository (15 min)

- **About** section (right side of repo page): description `Production-grade Azure banking platform: Terraform, AKS, WAF, Key Vault, GitHub Actions OIDC, PCI DSS-aligned`, website = your LinkedIn.
- **Topics:** `azure`, `terraform`, `aks`, `kubernetes`, `devops`, `github-actions`, `helm`, `fintech`, `banking`, `pci-dss`, `infrastructure-as-code`, `azure-devops`.
- **Social preview:** Settings -> General -> Social preview -> upload `docs/images/linkedin-banner.png`.
- **Pin** the repository on your GitHub profile (first position).
- Create release **v1.0.0** with the CHANGELOG text.

---

## Phase 9 - Publish on LinkedIn (15 min)

1. Use the post in [LINKEDIN_POST.md](LINKEDIN_POST.md); attach `docs/images/architecture.png` and `cicd-pipeline.png` (carousel/images perform better than links alone).
2. Put the GitHub link in the **first comment** as well as in the post.
3. Profile -> **Add section -> Projects**: title `SecureBank Platform - Azure Banking Infrastructure`, link the repo, associate with your current portfolio position, skills: Terraform, AKS, GitHub Actions, Azure Key Vault, Kubernetes.
4. **Featured** section -> add link to the repo.
5. Update headline to include `Terraform | AKS | GitHub Actions` alongside AZ-104.
6. Post Tuesday-Thursday, 08:00-09:30 UK time; reply to every comment within the first hour.

---

## Interview talking points

Be ready to explain:
1. Why OIDC instead of a service principal secret (ADR 0003).
2. How a request reaches the database and every control on the way (docs/architecture.md).
3. Why separate state per environment instead of workspaces (ADR 0002).
4. How you would make it multi-region (DR runbook + roadmap).
5. What PCI DSS requirement each control supports (docs/security-compliance.md).
6. How idempotency keys prevent double payments.
7. What you would change for a real bank: private AKS, self-hosted runners, Front Door, image signing, HSM-backed customer-managed keys.
