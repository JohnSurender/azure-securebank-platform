# Architecture

![Architecture](images/architecture.png)

## Request flow

```mermaid
sequenceDiagram
    autonumber
    participant C as Customer
    participant W as App Gateway WAF v2
    participant F as web-frontend
    participant T as transactions-service
    participant A as accounts-service
    participant KV as Key Vault
    participant DB as PostgreSQL (private)
    C->>W: HTTPS POST /api/transfers (Idempotency-Key)
    W->>W: OWASP DRS 2.1 + rate limit
    W->>T: Forward (AGIC-managed rule)
    T->>KV: Read DB credential (Workload Identity, CSI)
    T->>A: Debit / credit balance (cluster-internal, NetworkPolicy)
    A->>DB: UPDATE balances (TLS, private endpoint)
    T-->>C: 201 Created (transfer id)
```

## Component view

```mermaid
flowchart LR
  subgraph Internet
    U[Customers]
    GH[GitHub Actions]
  end
  subgraph Hub[Hub VNet]
    AGW[App Gateway WAF v2]
    BAS[Azure Bastion]
  end
  subgraph Spoke[Spoke VNet]
    subgraph AKS[AKS - CNI Overlay + Cilium]
      WEB[web-frontend]
      ACC[accounts-service]
      TRX[transactions-service]
    end
    subgraph PE[Private Endpoints]
      PG[(PostgreSQL Flex HA)]
      KV[Key Vault HSM]
      ACR[ACR Premium]
    end
  end
  LAW[Log Analytics / Defender]
  U --> AGW --> WEB & ACC & TRX
  TRX --> ACC --> PG
  ACC & TRX -.CSI.-> KV
  GH -- OIDC --> ACR
  GH -- helm --> AKS
  AKS -.logs.-> LAW
```

## Design principles

1. **Zero trust** - every hop is authenticated (Entra ID / Workload Identity) and network-restricted (NSG + NetworkPolicy default-deny).
2. **No secrets in code or pipelines** - OIDC federation for CI, Key Vault for runtime.
3. **Everything as code** - infrastructure, policy, alerts, dashboards and deployment manifests are versioned and reviewed.
4. **Immutable, scanned artefacts** - images tagged by commit SHA, blocked on HIGH/CRITICAL CVEs.
5. **Blast-radius isolation** - separate resource groups, state files, VNets and approval gates per environment.
6. **Zone resilience** - AKS node pools, App Gateway, ACR and PostgreSQL HA span three availability zones.

## Resilience targets

| Tier | RTO | RPO | Mechanism |
|---|---|---|---|
| Zone failure | < 5 min | 0 | Zone-redundant AKS, App Gateway, PostgreSQL HA |
| Region failure | < 4 h | < 1 h | Geo-redundant DB backup restore to UK West + Terraform redeploy (see [DR runbook](runbooks/dr-failover.md)) |
| Bad deployment | < 5 min | 0 | `helm --atomic` rollback, `helm rollback` |
