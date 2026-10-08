# Alert rules

| Alert | Signal | Threshold | Severity | Action |
|---|---|---|---|---|
| API 5xx rate | App Gateway `ResponseStatus` 5xx | > 2% for 5 min | Sev 1 | Page on-call |
| Unhealthy backend | App Gateway `UnhealthyHostCount` | > 0 for 5 min | Sev 2 | Page on-call |
| Pod crash loop | KQL query #2 | any result | Sev 2 | Email + Teams |
| Node CPU | Container Insights node CPU | > 85% for 15 min | Sev 3 | Email |
| PostgreSQL CPU | `cpu_percent` | > 80% for 10 min | Sev 2 | Page on-call |
| PostgreSQL storage | `storage_percent` | > 85% | Sev 2 | Email |
| Key Vault forbidden | KQL query #4 | > 5 in 5 min | Sev 1 | Page security |
| WAF block spike | KQL query #1 | > 500 in 5 min | Sev 2 | Page security |
| Budget | Consumption budget | 80% of monthly | Sev 4 | Email FinOps |
