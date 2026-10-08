# ADR 0001: AKS over App Service for banking workloads

- **Status:** Accepted
- **Date:** 2026-10-07

## Context
The platform runs several independently deployable services that need fine-grained east-west traffic control, per-service identities and consistent hardening.

## Decision
Use **AKS** with Azure CNI Overlay + Cilium, Workload Identity and Azure Policy add-on.

## Alternatives considered
- **App Service** - simpler, but limited east-west network policy and per-pod controls.
- **Azure Container Apps** - excellent for smaller teams (used in my `azure-global-ecommerce-cart` project) but fewer controls for Gatekeeper policy and PSS-level hardening that auditors expect.

## Consequences
- More operational responsibility (upgrades, node images) - mitigated with `automatic_upgrade_channel = patch` and `node_os_upgrade_channel = NodeImage`.
- Portable Helm-based deployment model.
