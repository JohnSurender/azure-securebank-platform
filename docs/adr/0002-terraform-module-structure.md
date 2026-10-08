# ADR 0002: Terraform modules + per-environment root modules

- **Status:** Accepted
- **Date:** 2026-10-07

## Decision
Reusable modules live in `infra/modules/`; each environment in `infra/envs/<env>/` is a thin root module with its own backend key and `terraform.tfvars`.

## Why not workspaces?
Terraform workspaces share one backend config and make it too easy to apply to the wrong environment. Separate directories give separate state, separate pipeline approvals and obvious diffs between environments.

## Consequences
- Small duplication of `main.tf` across envs (kept identical; only tfvars differ).
- Remote state in Azure Storage with Entra ID auth (`use_azuread_auth = true`), blob versioning and soft delete.
