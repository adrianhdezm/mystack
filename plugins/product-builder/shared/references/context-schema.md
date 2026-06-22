# Context Schema

`docs/context.json` is the shared state file for Product Builder. Skills read it to check prerequisites and write it to record their outputs. It is the single source of truth for build progress — `creating-products` uses it to resume interrupted runs.

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
    "worker_name": "my-app-worker",
    "cloudflare_account_id": "abc123",
    "d1_database_name": "my-app-db",
    "r2_bucket_name": "my-app-files"
  },
  "operator": {
    "name": "Acme GmbH",
    "address": "Musterstraße 1, 10115 Berlin, Germany",
    "email": "legal@acme.com"
  },
  "capabilities": {
    "database": false,
    "authentication": false,
    "file_storage": false,
    "ai": false,
    "landing_page": false,
    "legal_pages": false
  },
  "skills": {
    "preparing-repositories": "done",
    "writing-prd": "done",
    "scaffolding-project": "done",
    "adding-database": "done",
    "adding-authentication": "pending",
    "adding-file-storage": "skipped",
    "adding-ai": "done",
    "adding-landing-page": "pending",
    "adding-legal-pages": "pending",
    "planning-features": "pending",
    "implementing-features": "pending",
    "verifying-features": "pending",
    "testing-features": "pending"
  }
}
```

## Field Reference

### `repository`

Written by `preparing-repositories`. Read by `scaffolding-project`.

| Field         | Description                                        |
| ------------- | -------------------------------------------------- |
| `local_path`  | Absolute path to the cloned repository on disk     |
| `status`      | `existing-local` / `cloned` / `created-and-cloned` |
| `github_slug` | `owner/repo` GitHub identifier                     |

### `project`

Written by `scaffolding-project`. Read by all foundation and feature skills.

| Field                   | Description                                          |
| ----------------------- | ---------------------------------------------------- |
| `name`                  | Project name derived from the repository slug        |
| `worker_name`           | Cloudflare Worker name (usually same as `name`)      |
| `cloudflare_account_id` | Cloudflare account ID from `wrangler whoami`         |
| `d1_database_name`      | D1 database name — written by `adding-database`      |
| `r2_bucket_name`        | R2 bucket name — written by `adding-file-storage`    |

### `operator`

Written by `adding-legal-pages` (or earlier by the user / `writing-prd`). Read by `adding-legal-pages`. Can be pre-populated manually before running any skill.

| Field     | Description                                  |
| --------- | -------------------------------------------- |
| `name`    | Full legal name of the individual or company |
| `address` | Full postal address                          |
| `email`   | Contact email address                        |

### `capabilities`

Written by foundation skills. Read by `creating-products` to determine which foundation skills to run and by feature skills to understand what infrastructure is available.

| Field            | Set to `true` by        |
| ---------------- | ----------------------- |
| `database`       | `adding-database`       |
| `authentication` | `adding-authentication` |
| `file_storage`   | `adding-file-storage`   |
| `ai`             | `adding-ai`             |
| `landing_page`   | `adding-landing-page`   |
| `legal_pages`    | `adding-legal-pages`    |

### `skills`

Each skill sets its own entry. `creating-products` reads the full map to skip completed skills and resume from the first non-`done` step.

**Status values:**

| Value         | Meaning                                   |
| ------------- | ----------------------------------------- |
| `pending`     | Not yet run                               |
| `in-progress` | Currently running (set at start of skill) |
| `done`        | Completed successfully                    |
| `skipped`     | Capability not needed for this project    |
| `failed`      | Terminated with an unresolved error       |

## Reading and Writing

All skills must read `docs/context.json` at the start and write back their changes at the end using a targeted merge — only update the fields the skill owns, preserving everything else. If the file does not exist, create it with all fields at their defaults before writing.

### Default file to create when missing

```json
{
  "repository": {},
  "project": {},
  "operator": {},
  "capabilities": {
    "database": false,
    "authentication": false,
    "file_storage": false,
    "ai": false,
    "landing_page": false,
    "legal_pages": false
  },
  "skills": {
    "preparing-repositories": "pending",
    "writing-prd": "pending",
    "scaffolding-project": "pending",
    "adding-database": "pending",
    "adding-authentication": "pending",
    "adding-file-storage": "pending",
    "adding-ai": "pending",
    "adding-landing-page": "pending",
    "adding-legal-pages": "pending",
    "planning-features": "pending",
    "implementing-features": "pending",
    "verifying-features": "pending",
    "testing-features": "pending"
  }
}
```

## Guard Pattern

Every skill that has prerequisites must check context at the top of its workflow and stop with a clear message if they are not satisfied:

```
Stop — docs/context.json is missing the required field `capabilities.database = true`.
Run the `adding-database` skill first, then re-run this skill.
```

Never proceed past a guard failure. Never infer or assume a prerequisite is met.
