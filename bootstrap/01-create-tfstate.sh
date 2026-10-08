#!/usr/bin/env bash
# Creates the remote-state storage account used by every environment.
# Run once per subscription:  ./bootstrap/01-create-tfstate.sh
set -euo pipefail

LOCATION="${LOCATION:-uksouth}"
RG="rg-securebank-tfstate-uks"
SA="stsecurebanktf$RANDOM"     # must be globally unique, 3-24 lowercase chars
CONTAINER="tfstate"

az group create -n "$RG" -l "$LOCATION" --tags project=securebank owner=platform -o none

az storage account create -n "$SA" -g "$RG" -l "$LOCATION" \
  --sku Standard_ZRS --kind StorageV2 \
  --min-tls-version TLS1_2 --allow-blob-public-access false \
  --allow-shared-key-access false -o none

az storage account blob-service-properties update -g "$RG" --account-name "$SA" \
  --enable-versioning true --enable-delete-retention true --delete-retention-days 30 -o none

az storage container create -n "$CONTAINER" --account-name "$SA" --auth-mode login -o none

echo "State storage account: $SA"
echo "Update storage_account_name in infra/envs/*/backend.tf with this value."
