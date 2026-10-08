# Runbook: Regional disaster recovery (UK South -> UK West)

**Targets:** RTO < 4 h, RPO < 1 h (geo-redundant PostgreSQL backup).

## Preconditions
- `postgres_geo_backup = true` in prod (default).
- ACR geo-replication to UK West (roadmap) or re-push images from CI.

## Steps
1. **Declare disaster** - incident commander confirms UK South outage via Azure Service Health.
2. **Restore database to UK West**
   ```bash
   az postgres flexible-server geo-restore \
     --resource-group rg-securebank-prod-ukw \
     --name psql-securebank-prod-ukw \
     --source-server /subscriptions/<sub>/resourceGroups/rg-securebank-prod-uks/providers/Microsoft.DBforPostgreSQL/flexibleServers/psql-securebank-prod-uks \
     --location ukwest
   ```
3. **Deploy infrastructure to UK West** - copy `infra/envs/prod` to `infra/envs/prod-ukw`, set `location = "ukwest"`, `location_short = "ukw"`, new CIDRs `10.40.0.0/16` / `10.41.0.0/16`, then `terraform apply`.
4. **Deploy apps** - run `app-ci-cd` workflow with target cluster `aks-securebank-prod-ukw`.
5. **Switch DNS** - point the public record to the new App Gateway IP (TTL 60 s).
6. **Validate** - `scripts/smoke-test.sh prod` against UK West, reconcile last transfers using idempotency keys.
7. **Fail back** once UK South is healthy, using the same process in reverse.

## Test schedule
DR drill every 6 months in staging; record actual RTO/RPO in this file.
