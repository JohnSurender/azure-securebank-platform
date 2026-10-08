# Cost estimate (indicative)

> Rough monthly figures for **UK South pay-as-you-go**, for planning only. Always confirm with the [Azure Pricing Calculator](https://azure.microsoft.com/pricing/calculator/) - prices change.

| Component | dev | prod |
|---|---|---|
| AKS nodes (D2s/D4s v5) | ~GBP 70-140 | ~GBP 900-1,500 |
| AKS Standard tier | - | ~GBP 60 |
| App Gateway WAF v2 | ~GBP 0-200 (scale to 0) | ~GBP 450-700 |
| PostgreSQL Flexible | ~GBP 15 | ~GBP 500-650 (HA doubles compute) |
| ACR Premium | ~GBP 35 | ~GBP 35 |
| Key Vault Premium | < GBP 5 | ~GBP 10 |
| Log Analytics | ~GBP 20 | ~GBP 150-300 |
| Defender for Containers | ~GBP 10 | ~GBP 50+ |

## Cost controls built in
- Consumption **budgets** with 80 % alerts per environment (Terraform).
- App Gateway autoscale min 0 in dev; cluster autoscaler on all pools.
- `scripts/cleanup-dev.sh` to destroy dev outside working hours.
- Use **Reserved Instances / Savings Plan** for prod node pools and PostgreSQL once usage is stable.
