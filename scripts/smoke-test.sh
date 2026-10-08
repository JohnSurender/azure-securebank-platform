#!/usr/bin/env bash
# Post-deployment smoke test. Usage: scripts/smoke-test.sh <env>
set -euo pipefail
ENV="${1:-dev}"
IP=$(az network public-ip show -g "rg-securebank-${ENV}-uks" -n "pip-agw-securebank-${ENV}-uks" --query ipAddress -o tsv)
echo "Testing http://$IP"
for path in /api/accounts/healthz /api/transfers/healthz; do
  code=$(curl -s -o /dev/null -w '%{http_code}' --retry 5 --retry-delay 5 "http://$IP$path")
  [[ "$code" == "200" ]] && echo "PASS $path" || { echo "FAIL $path ($code)"; exit 1; }
done
