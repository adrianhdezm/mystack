# Context Schema

`docs/context.json` is the shared state file for Project Bootstrapper and Product Builder. It lives at `<repository.local_path>/docs/context.json` and is created by `preparing-repositories` as the first act of setting up a project — before any other skill runs. Skills read it to check prerequisites and write it to record their outputs. It tracks infrastructure configuration only — repository, project, operator, and capability status. Per-feature progress is tracked in `docs/features/manifest.json`.

## Full Schema

```json
{
  "repository": {
    "local_path": "/Users/user/projects/my-app",
    "status": "existing-local | cloned | created-and-cloned",
    "github_slug": "owner/my-app"
  },
  "project": {
    "name": "my-app",
    "idea": "A tool that helps developers track their time.",
    "deployment_target": "cloudflare | docker-postgres",
    "worker_name": "my-app-worker",
    "cloudflare_account_id": "abc123",
    "database_name": "my-app-db",
    "r2_bucket_name": "my-app-files"
  },
  "operator": {
    "name": "Acme GmbH",
    "address": "Musterstraße 1, 10115 Berlin, Germany",
    "email": "legal@acme.com"
  },
  "capabilities": {
    "database": "ready",
    "authentication": "ready",
    "file_storage": "skipped",
    "ai": "planned"
  }
}
```

## Capability Status

Each capability has an explicit status set by the skills that own it:

| Status | Meaning | Set by |
| --- | --- | --- |
| `skipped` | Not needed for this product (default) | `selecting-capabilities` |
| `planned` | Approved by the user during capability selection | `selecting-capabilities` |
| `ready` | Foundation skill ran and the capability is wired up | `adding-*` skill |

**Lifecycle**: `skipped` or `planned` (written by `selecting-capabilities`) → `ready` (written when foundation skill completes).

`bootstrapping-projects` uses these statuses to determine which foundation skills to run (`planned`) and which to skip (`skipped` or `ready`). `creating-products` reads them to understand what's already wired.

## Field Reference

### `repository`

Written by `preparing-repositories`. Read by `scaffolding-project`.

| Field         | Description                                        |
| ------------- | -------------------------------------------------- |
| `local_path`  | Absolute path to the cloned repository on disk     |
| `status`      | `existing-local` / `cloned` / `created-and-cloned` |
| `github_slug` | `owner/repo` GitHub identifier                     |

### `project`

`idea` and `deployment_target` written by `selecting-capabilities`. `name` and target-specific fields written by `scaffolding-project`. Read by all foundation and feature skills.

| Field | Description |
| --- | --- |
| `idea` | One-sentence product description — written by `selecting-capabilities` |
| `deployment_target` | `cloudflare` or `docker-postgres` — written by `selecting-capabilities` |
| `name` | Project name derived from the repository slug |
| `worker_name` | **Cloudflare only** — Worker name from `wrangler.jsonc` |
| `cloudflare_account_id` | **Cloudflare only** — account ID from `wrangler whoami` |
| `database_name` | Database name — written by `adding-database` |
| `r2_bucket_name` | **Cloudflare only** — R2 bucket name — written by `adding-file-storage` |

### `operator`

Written by `adding-legal-pages` (in `product-builder`). Read by `adding-legal-pages`. Can be pre-populated manually before running any skill.

| Field     | Description                                  |
| --------- | -------------------------------------------- |
| `name`    | Full legal name of the individual or company |
| `address` | Full postal address                          |
| `email`   | Contact email address                        |

### `capabilities`

Written first by `selecting-capabilities` (sets `planned` or `skipped`), then by each foundation skill (sets `ready`). Read by `bootstrapping-projects` to determine which foundation skills to run. `landing_page` and `legal_pages` are managed by `product-builder` skills, not by the bootstrapper.

| Field | Set to `planned` by | Set to `ready` by |
| --- | --- | --- |
| `database` | `selecting-capabilities` | `adding-database` |
| `authentication` | `selecting-capabilities` | `adding-authentication` |
| `file_storage` | `selecting-capabilities` | `adding-file-storage` |
| `ai` | `selecting-capabilities` | `adding-ai` |
| `landing_page` | `writing-prd` (product-builder) | `adding-landing-page` (product-builder) |
| `legal_pages` | `writing-prd` (product-builder) | `adding-legal-pages` (product-builder) |

## Reading and Writing

All skills must read `docs/context.json` at the start and write back their changes at the end using a targeted merge — only update the fields the skill owns, preserving everything else. If the file does not exist, create it with all fields at their defaults before writing.

### Default file to create when missing

```json
{
  "repository": {},
  "project": {},
  "operator": {},
  "capabilities": {
    "database": "skipped",
    "authentication": "skipped",
    "file_storage": "skipped",
    "ai": "skipped",
    "landing_page": "skipped",
    "legal_pages": "skipped"
  }
}
```

## Guard Pattern

Every skill that has prerequisites must check context at the top of its workflow and stop with a clear message if they are not satisfied:

```
Stop — docs/context.json is missing the required field `capabilities.database = "ready"`.
Run the `adding-database` skill first, then re-run this skill.
```

Never proceed past a guard failure. Never infer or assume a prerequisite is met.
