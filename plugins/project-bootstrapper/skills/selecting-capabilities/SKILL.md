---
name: selecting-capabilities
description: Collects the product idea and selects the deployment target and infrastructure capabilities for a new project. Writes project.deployment_target, project.idea, and capabilities.* to docs/context.json. Use after preparing-repositories and before scaffolding-project.
---

# Selecting Capabilities

Collects the one-sentence product idea, selects the deployment target, and determines which infrastructure capabilities the project requires. Writes the approved selections to `docs/context.json` so `scaffolding-project` and all capability skills can read them.

Landing page and legal pages are **not** selected here — those are product decisions handled by `product-builder`.

## Context

**Guard** — stop before proceeding if `repository.local_path` is not set in `docs/context.json`:

```text
Stop — docs/context.json is missing repository.local_path.
Run preparing-repositories first, then re-run this skill.
```

**Skip condition** — if `project.deployment_target` is already set in `docs/context.json`, selections are complete. Report the current values and stop — do not re-run.

## Workflow

### 1) Get the Product Idea

Ask the user for a one-sentence description of the product they are building. This becomes the seed for documentation and initial `docs/` files. Do not proceed until you have a clear answer.

### 2) Select Deployment Target

Present the deployment target options and ask the user to choose one:

| Target | Description |
| --- | --- |
| `cloudflare` | Cloudflare Workers + Vite + React Router v7. Database: D1 (SQLite). File storage: R2. Runtime: Workers edge runtime (no Node.js APIs). Deploy via `wrangler deploy`. |
| `docker-postgres` | Node.js server (Hono) + Vite + React Router v7. Database: Postgres. File storage: RustFS (S3-compatible). Runtime: Node.js. Deploy via Docker Compose. |

Do not proceed until the user selects a target.

### 3) Select Capabilities

From the product idea and deployment target, propose infrastructure capability selections. Prefer inference — only ask when an answer materially changes the project.

Inference signals:

- `database` — persistent state, relational data, or user-owned records.
- `authentication` — accounts, login, protected pages, or per-user data. **Requires `database`**.
- `file_storage` — uploads, attachments, or durable binary assets. **Requires `database`**.
- `ai` — text/image generation, structured AI output, or LLM integration.

Enforce dependencies before presenting:

- If `authentication=yes` → set `database=yes`
- If `file_storage=yes` → set `database=yes`

Present the table for user approval. Re-enforce dependencies and re-present if the user changes any value. Do not proceed until explicitly approved.

| Capability       | Value    | Rationale |
| ---------------- | -------- | --------- |
| `database`       | yes / no | …         |
| `authentication` | yes / no | …         |
| `file_storage`   | yes / no | …         |
| `ai`             | yes / no | …         |

### 4) Write to Context

Write the approved selections to `docs/context.json`. Preserve all existing fields — only add or overwrite `project.deployment_target`, `project.idea`, and `capabilities.*`.

Set each capability to `"planned"` if Value=yes, `"skipped"` if Value=no.

```json
{
  "project": {
    "deployment_target": "<cloudflare | docker-postgres>",
    "idea": "<one-sentence product idea>"
  },
  "capabilities": {
    "database": "<planned | skipped>",
    "authentication": "<planned | skipped>",
    "file_storage": "<planned | skipped>",
    "ai": "<planned | skipped>"
  }
}
```

### 5) Output the Contract

```text
DEPLOYMENT_TARGET: <cloudflare | docker-postgres>
IDEA: <one-sentence product idea>
CAPABILITIES:
  database: <planned | skipped>
  authentication: <planned | skipped>
  file_storage: <planned | skipped>
  ai: <planned | skipped>
```

## Review Checklist

- [ ] Guard passed — `repository.local_path` is set in `docs/context.json`.
- [ ] Skip condition checked — `project.deployment_target` not already set.
- [ ] User provided a substantive one-sentence product idea.
- [ ] User explicitly selected a deployment target.
- [ ] Capability dependencies enforced before presenting the table.
- [ ] Capability table presented and explicitly approved before writing.
- [ ] `docs/context.json` written with `project.deployment_target`, `project.idea`, and `capabilities.*` fields.
- [ ] Contract output printed.
