# ADR 0003: GitHub OIDC federation instead of client secrets

- **Status:** Accepted
- **Date:** 2026-10-07

## Decision
GitHub Actions authenticate to Azure with **workload identity federation**. Federated credentials are scoped to `main`, `pull_request` and each GitHub Environment.

## Consequences
- No secret to rotate, leak or expire (supports PCI DSS 8.6).
- Tokens are short-lived (minutes) and bound to the repo and ref.
- Requires `permissions: id-token: write` in every workflow that touches Azure.
