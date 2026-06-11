---
name: adding-file-storage
description: Adds Cloudflare R2 file storage to an existing Product Builder project using Wrangler bindings, a Drizzle file metadata table, and React Router server context. Use when the user asks to add uploads, file storage, R2 buckets, object storage, file metadata, or file management to an existing Cloudflare Workers React Router project.
---

# Adding File Storage

## Required inputs

Work in the target project repository. If the project path is unclear, ask for only the path before changing files.

Derive these values from the project or user prompt when possible:

```text
PROJECT_PATH: <absolute path>
R2_BUCKET_NAME: <project-name>-files
R2_BINDING: APP_FILES
D1_BINDING: APP_DB
```

Use `APP_FILES` as the default R2 binding and `APP_DB` as the default D1 binding unless the existing project already uses different binding names.

## Hard rules

- Use `pnpm` for Wrangler, package, and project scripts.
- Load `react-router-patterns` before changing React Router context, Worker request handling, route modules, loaders, actions, upload forms, or resource routes. Any React Router code must follow those patterns.
- Require an existing D1 and Drizzle setup for file metadata; if missing, run the `adding-database` skill first.
- Read [data-access-architecture.md](../../shared/references/data-access-architecture.md) for file metadata service boundaries, transaction ownership, and any DAO or data access workflow changes.
- Store file bytes in Cloudflare R2 and file metadata in the D1 `files` table.
- Do not store raw file contents, Cloudflare account IDs, or API tokens in D1.
- Preserve existing `wrangler.jsonc` settings and merge R2 configuration into it.
- Preserve existing React Router request handling and inject file storage services through router context.
- Roll back uploaded R2 objects if inserting file metadata fails.

## Gotchas

- R2 buckets created with `wrangler r2 bucket create` are region-specific. The bucket name must be globally unique across all Cloudflare accounts — a "bucket already exists" error usually means the name is taken, not that the bucket was already created in this account.
- R2 bindings in `wrangler.jsonc` use `r2_buckets` (plural), not `r2_bucket`. Using the singular form silently ignores the binding.
- Uploading to R2 succeeds even if the D1 metadata insert later fails. Always delete the R2 object in the catch path to avoid orphaned files with no metadata.
- `env.APP_FILES.put()` accepts a `ReadableStream`, `ArrayBuffer`, or `string` — not a `File` or `Blob` directly. Extract the body from the uploaded file before calling `put()`.

## Workflow

1. Verify the target project is a Product Builder-style Cloudflare Workers, Vite, React Router, TypeScript, pnpm, D1, and Drizzle project.
2. Create or register the Cloudflare R2 bucket using [01-cloudflare-r2.md](references/01-cloudflare-r2.md).
3. Add the file metadata schema and service using [02-file-schema-and-service.md](references/02-file-schema-and-service.md).
4. Read [data-access-architecture.md](../../shared/references/data-access-architecture.md) for the file metadata service and any data access changes.
5. Load `react-router-patterns`, then wire the service into app context and the Worker using [03-app-integration.md](references/03-app-integration.md).
6. Generate/apply migrations and validate types using [04-migrations-validation.md](references/04-migrations-validation.md).
7. Update project documentation using [documentation-updates.md](../../shared/references/documentation-updates.md) with these specifics:
   - **Stack addition**: `Cloudflare R2 (file storage)`.
   - **Data model addition**: `files` entity with columns, types, and relationships matching `app/db/schema.ts`.
   - **README additions**: R2 bucket setup, file metadata table, upload/delete behavior.
   - **AGENTS.md additions**: file storage instructions.
8. Run formatting, typecheck, lint, build, and the migration commands available for the current environment.
9. Commit the generated and updated files in the repository using the repository's Conventional Commits format.

## Validation checklist

- [ ] `wrangler.jsonc` includes an R2 binding for `APP_FILES`.
- [ ] `app/db/schema.ts` exports a `files` table and includes it in `schema`.
- [ ] A generated migration creates the `files` metadata table.
- [ ] `app/services/file.service.ts` uploads to R2 before inserting metadata.
- [ ] Failed metadata inserts delete the newly uploaded R2 object.
- [ ] Deleting a file removes both the D1 metadata row and the R2 object.
- [ ] `app/context.ts` exposes `files: FilesService`.
- [ ] `workers/app.ts` constructs `new FilesService(db, env.APP_FILES)`.
- [ ] `data-access-architecture.md` was followed for file metadata service boundaries and any DAO or data access workflow changes.
- [ ] `react-router-patterns` was loaded and followed for any React Router context, Worker request-handling, route, upload, or resource endpoint changes.
- [ ] Generated `Env` types include `APP_FILES`.
- [ ] `docs/architecture.md` includes Cloudflare R2 in the Stack section.
- [ ] `docs/data-model.md` includes the `files` entity matching `app/db/schema.ts`.
- [ ] `README.md` and `AGENTS.md` document file storage setup and behavior, and `AGENTS.md` references `docs/`.
- [ ] Migrations and project verification commands work or failures are explained.
- [ ] Generated and updated files were committed with a Conventional Commit message.
