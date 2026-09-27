# Shared release actions repository

This repository is the centralized release engine for the organization. Every application repo calls the reusable workflows in this repository instead of reimplementing a release pipeline in each service.

## Tag strategy

- `vX.Y.Z-dev` is created after merge to `main` when the release pipeline starts.
- `vX.Y.Z-rc` is created when the dev stage succeeds.
- `vX.Y.Z` is created when the production approval gate is satisfied.

## Conventional commit rule

The versioning script in `scripts/calculate-next-tag.sh` derives the next version from the PR title:

- `feat:` or `feature:` -> minor bump
- `fix:` -> patch bump
- `BREAKING CHANGE` or `!:` -> major bump
- default fallback -> patch bump

## Teams-safe approval alternative

Because this organization is now on GitHub Teams, the safest alternative is:

1. Keep a dedicated release approval workflow in the shared repo.
2. Require a manager or release lead to approve from a designated team or ruleset.
3. Only after approval does the workflow move the final release tag to `production` and deploy.

This keeps the human approval step without depending on the Enterprise-only environment workflow experience.

## Consumer contract

Each app repo should contain a minimal workflow that calls the shared orchestrator:

```yaml
jobs:
  release:
    uses: tseste/release-actions/.github/workflows/release-orchestrator.yml@main
    with:
      service_name: my-service
      pr_title: feat: add new customer profile endpoint
      manager_team: release-managers
```
