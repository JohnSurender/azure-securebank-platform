# Runbook: Incident response

| Severity | Example | Response | Update cadence |
|---|---|---|---|
| Sev 1 | Transfers failing, data exposure | 15 min, page on-call + security | 30 min |
| Sev 2 | Degraded latency, one service down | 30 min | 1 h |
| Sev 3 | Non-customer-facing issue | Next business day | daily |

## 1. Triage (first 15 minutes)
```bash
az aks get-credentials -g rg-securebank-prod-uks -n aks-securebank-prod-uks
kubelogin convert-kubeconfig -l azurecli
kubectl -n securebank get pods,hpa,events --sort-by=.lastTimestamp | tail -30
kubectl -n securebank logs deploy/transactions-service --since=15m | tail -100
```
Check App Gateway backend health:
```bash
az network application-gateway show-backend-health -g rg-securebank-prod-uks -n agw-securebank-prod-uks -o table
```

## 2. Mitigate
- **Bad release:** `helm -n securebank rollback transactions-service` (previous revision).
- **Traffic spike / attack:** confirm WAF blocks (KQL query 1), tighten rate-limit rule, scale `kubectl -n securebank scale deploy/... --replicas=N`.
- **Database CPU:** check `pg_stat_activity`, scale SKU via tfvars change (planned) or portal (emergency, then back-port to code).
- **Suspected credential compromise:** disable the identity in Entra ID, rotate Key Vault secret, review KQL query 4.

## 3. Communicate
Post in #incident channel: impact, start time, current action, next update time.

## 4. Post-incident
Blameless review within 5 working days; actions tracked as GitHub issues labelled `postmortem`.
