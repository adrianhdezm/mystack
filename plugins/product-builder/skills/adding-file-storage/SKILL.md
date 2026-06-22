---
name: adding-file-storage
description: Adds Cloudflare R2 file storage to an existing Product Builder project using Wrangler bindings, a Drizzle file metadata table, and React Router server context. Use when the user asks to add uploads, file storage, R2 buckets, object storage, file metadata, or file management to an existing Cloudflare Workers React Router project.
---

# Adding File Storage

Creates a Cloudflare R2 bucket, adds a `files` metadata table to D1, builds a `FilesService` that stores bytes in R2 and metadata in D1, and wires the service into the Worker and app context.

## Context

**Guard** — stop before changing any files if `context.capabilities.database` is not `true`:

```text
Stop — docs/context.json is missing capabilities.database = true. Run adding-database first, then re-run this skill.
```

Set `skills.adding-file-storage` to `in-progress` at the start. Derive `PROJECT_PATH` from `context.repository.local_path`. On success write:

```json
{
  "project": { "r2_bucket_name": "<R2_BUCKET_NAME>" },
  "capabilities": { "file_storage": true },
  "skills": { "adding-file-storage": "done" }
}
```

Default R2 binding: `APP_FILES`. Default D1 binding: `APP_DB`. Default bucket name: `<project-name>-files`.

## Rules

- Store file bytes in Cloudflare R2 and file metadata in the D1 `files` table — never store raw file contents in D1.
- Roll back uploaded R2 objects if inserting file metadata fails — always delete the R2 object in the catch path.
- Use `r2_buckets` (plural) in `wrangler.jsonc` — the singular `r2_bucket` silently ignores the binding.
- `env.APP_FILES.put()` accepts `ReadableStream`, `ArrayBuffer`, or `string` — not `File` or `Blob` directly; extract the body before calling `put()`.
- R2 bucket names are globally unique across all Cloudflare accounts — a "bucket already exists" error means the name is taken, not that the bucket exists in this account.
- Preserve existing `wrangler.jsonc` settings — merge R2 configuration in, never overwrite.
- Read [data-access-architecture.md](../../shared/references/data-access-architecture.md) for service boundaries and transaction ownership.
- Read [worker-architecture.md](../../shared/references/worker-architecture.md) before modifying `workers/app.ts`. Wire bindings inline — no helper files under `workers/`.
- Load `react-router-patterns` before changing React Router context, Worker request handling, or any route.

## Workflow

1. Read `docs/context.json`. Confirm `capabilities.database = true`. Set `skills.adding-file-storage` to `in-progress`.
2. Create or register the Cloudflare R2 bucket using [01-cloudflare-r2.md](references/01-cloudflare-r2.md).
3. Add the file metadata schema and service using [02-file-schema-and-service.md](references/02-file-schema-and-service.md).
4. Read [data-access-architecture.md](../../shared/references/data-access-architecture.md) for the file metadata service and any data access changes.
5. Load `react-router-patterns`, then wire the service into app context and the Worker using [03-app-integration.md](references/03-app-integration.md).
6. Generate and apply migrations, validate types using [04-migrations-validation.md](references/04-migrations-validation.md).
7. Update project documentation using [documentation-updates.md](../../shared/references/documentation-updates.md): stack entry (`Cloudflare R2`), `files` entity in data model, README and AGENTS.md additions.
8. Write `project.r2_bucket_name`, `capabilities.file_storage = true`, and `skills.adding-file-storage = "done"` to `docs/context.json`.
9. Run `pnpm format`, `pnpm typecheck`, `pnpm lint`, `pnpm build`, and migration commands. Fix any failures before committing.
10. Commit using the repository's Conventional Commits format.

## References

- **Cloudflare R2**: [references/01-cloudflare-r2.md](references/01-cloudflare-r2.md)
- **File schema and service**: [references/02-file-schema-and-service.md](references/02-file-schema-and-service.md)
- **App integration**: [references/03-app-integration.md](references/03-app-integration.md)
- **Migrations and validation**: [references/04-migrations-validation.md](references/04-migrations-validation.md)
- **Documentation updates**: [documentation-updates.md](../../shared/references/documentation-updates.md)
- **Data access architecture**: [data-access-architecture.md](../../shared/references/data-access-architecture.md)
- **Worker architecture**: [worker-architecture.md](../../shared/references/worker-architecture.md)

## Review Checklist

- [ ] `docs/context.json` guard passed (`capabilities.database = true`).
- [ ] `wrangler.jsonc` includes `r2_buckets` binding for `APP_FILES`.
- [ ] `app/db/schema.ts` exports a `files` table included in `schema`.
- [ ] Migration created the `files` metadata table.
- [ ] `app/services/file.service.ts` uploads to R2 before inserting metadata.
- [ ] Failed metadata inserts delete the newly uploaded R2 object.
- [ ] Deleting a file removes both the D1 row and the R2 object.
- [ ] `app/context.ts` exposes `files: FilesService`.
- [ ] `workers/app.ts` constructs `new FilesService(db, env.APP_FILES)` inline.
- [ ] Generated `Env` types include `APP_FILES`.
- [ ] `docs/data-model.md` includes the `files` entity.
- [ ] `pnpm format`, `pnpm typecheck`, `pnpm lint`, `pnpm build`, and migration commands pass.
- [ ] `docs/context.json` updated with `project.r2_bucket_name`, `capabilities.file_storage = true`, and `skills.adding-file-storage = "done"`.
- [ ] Changes committed with Conventional Commit message.
