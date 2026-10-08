#!/usr/bin/env bash
# Creates an Entra ID app registration with federated credentials so GitHub
# Actions can deploy WITHOUT any client secret.
# Usage: GITHUB_REPO=JohnSurender/azure-securebank-platform ./bootstrap/02-setup-github-oidc.sh
set -euo pipefail

: "${GITHUB_REPO:?Set GITHUB_REPO=owner/repo}"
APP_NAME="sp-securebank-github"
SUB_ID=$(az account show --query id -o tsv)
TENANT_ID=$(az account show --query tenantId -o tsv)

APP_ID=$(az ad app create --display-name "$APP_NAME" --query appId -o tsv)
az ad sp create --id "$APP_ID" -o none || true

# Least privilege: Contributor + User Access Administrator (for role assignments made by Terraform)
for ROLE in "Contributor" "User Access Administrator"; do
  az role assignment create --assignee "$APP_ID" --role "$ROLE" --scope "/subscriptions/$SUB_ID" -o none
done

add_fic () {
  az ad app federated-credential create --id "$APP_ID" --parameters "{
    \"name\": \"$1\",
    \"issuer\": \"https://token.actions.githubusercontent.com\",
    \"subject\": \"$2\",
    \"audiences\": [\"api://AzureADTokenExchange\"]
  }" -o none
}
add_fic "gh-main"         "repo:${GITHUB_REPO}:ref:refs/heads/main"
add_fic "gh-pr"           "repo:${GITHUB_REPO}:pull_request"
add_fic "gh-env-dev"      "repo:${GITHUB_REPO}:environment:dev"
add_fic "gh-env-staging"  "repo:${GITHUB_REPO}:environment:staging"
add_fic "gh-env-prod"     "repo:${GITHUB_REPO}:environment:prod"

cat <<OUT

Add these as GitHub repository secrets (Settings > Secrets and variables > Actions):
  AZURE_CLIENT_ID       = $APP_ID
  AZURE_TENANT_ID       = $TENANT_ID
  AZURE_SUBSCRIPTION_ID = $SUB_ID
OUT
