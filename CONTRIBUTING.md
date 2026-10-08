# Contributing

1. Branch from `main` using `feature/<short-name>` or `fix/<short-name>`.
2. Install hooks: `pip install pre-commit && pre-commit install`.
3. Use [Conventional Commits](https://www.conventionalcommits.org/) (`feat:`, `fix:`, `docs:`, `infra:`, `ci:`).
4. Open a PR. CI posts the `terraform plan` as a PR comment; at least one CODEOWNER must approve.
5. Merges to `main` deploy to **dev** automatically; **staging** and **prod** require environment approval.
