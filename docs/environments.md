# Environments

| Setting | dev | staging | prod |
|---|---|---|---|
| Resource group | rg-securebank-dev-uks | rg-securebank-staging-uks | rg-securebank-prod-uks |
| State file | securebank-dev.tfstate | securebank-staging.tfstate | securebank-prod.tfstate |
| Hub / spoke CIDR | 10.10.0.0/16 / 10.11.0.0/16 | 10.20.0.0/16 / 10.21.0.0/16 | 10.30.0.0/16 / 10.31.0.0/16 |
| AKS SKU tier | Free | Standard (SLA) | Standard (SLA) |
| System / apps nodes | 1 / 1-3 | 2 / 2-5 | 3 / 3-10 |
| PostgreSQL | B_Standard_B1ms | GP_Standard_D2ds_v5 | GP_Standard_D4ds_v5, ZR-HA, geo-backup |
| Backup retention | 7 d | 14 d | 35 d |
| WAF | Detection | Prevention | Prevention |
| Log retention | 30 d | 90 d | 365 d |
| GitHub Environment protection | none | 1 reviewer | 2 reviewers, `main` only, 10 min wait |
| Budget alert (80 %) | GBP 300 | GBP 900 | GBP 3,000 |

## Promotion rules
- The same container image (same SHA) is promoted through every environment - never rebuilt.
- Infra changes are planned for all three environments on every PR so reviewers see prod impact early.
- Prod deploys are blocked Friday 16:00 - Monday 08:00 (enforce with a GitHub Environment deployment branch/time rule or a change-freeze check).
