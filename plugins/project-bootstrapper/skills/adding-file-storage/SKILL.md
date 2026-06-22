---
name: adding-file-storage
description: Adds file storage to a bootstrapped project. Cloudflare target uses R2 + D1 metadata; Docker/Postgres target uses MinIO + Postgres metadata. Use when capabilities.file_storage is planned and adding-database has run.
---

# Adding File Storage

Adds an object storage bucket, a `files` metadata table, and a `FilesService` that stores bytes in the object store and metadata in the database. Wires the service into the server and app context.

## Context

**Guard** — stop before changing any files if `context.capabilities.database` is not `"ready"`:

```text
Stop — docs/context.json is missing capabilities.database = "ready". Run adding-database first, then re-run this skill.
```

Derive `PROJECT_PATH` from `context.repository.local_path`. Derive `DEPLOYMENT_TARGET` from `context.project.deployment_target`.

On success write to `docs/context.json`:

```json
{
  "project": { "storage_bucket_name": "<BUCKET_NAME>" },
  "capabilities": { "file_storage": "ready" }
}
```

## Rules

- Store file bytes in the object store and file metadata in the `files` table — never store raw file contents in the database.
- Roll back uploaded objects if inserting file metadata fails — always delete the object in the catch path.
- Read [data-access-architecture.md](../../shared/references/data-access-architecture.md) for service boundaries and transaction ownership.
- Load `react-router-patterns` before changing React Router context or any route.

**Cloudflare target only:**
- Use `r2_buckets` (plural) in `wrangler.jsonc` — the singular `r2_bucket` silently ignores the binding.
- `env.APP_FILES.put()` accepts `ReadableStream`, `ArrayBuffer`, or `string` — not `File` or `Blob` directly.
- R2 bucket names are globally unique across all Cloudflare accounts.
- Preserve existing `wrangler.jsonc` settings — merge R2 configuration in, never overwrite.
- Read [worker-architecture.md](../../shared/references/worker-architecture.md) before modifying `workers/app.ts`.
- Default R2 binding: `APP_FILES`.

**Docker/Postgres target only:**
- Use RustFS (S3-compatible) running in Docker Compose for local development.
- Use the AWS SDK v3 (`@aws-sdk/client-s3`) with the S3-compatible RustFS endpoint.
- Add RustFS service to `docker-compose.yml`.
- `S3_ENDPOINT`, `S3_ACCESS_KEY`, `S3_SECRET_KEY`, and `S3_BUCKET` go in `.env`.

## Workflow

1. Read `docs/context.json`. Confirm guard passes. Derive `PROJECT_PATH` and `DEPLOYMENT_TARGET`.
2. **Set up object storage:**
   - `cloudflare` → Create R2 bucket using [references/cloudflare/01-cloudflare-r2.md](references/cloudflare/01-cloudflare-r2.md)
   - `docker-postgres` → Set up RustFS using [references/docker-postgres/01-rustfs-setup.md](references/docker-postgres/01-rustfs-setup.md)
3. Add the file metadata schema and service using [references/02-file-schema-and-service.md](references/02-file-schema-and-service.md).
4. Read [data-access-architecture.md](../../shared/references/data-access-architecture.md) for the file metadata service.
5. **Wire the service into app context and the server:**
   - `cloudflare` → [references/cloudflare/03-app-integration.md](references/cloudflare/03-app-integration.md)
   - `docker-postgres` → [references/docker-postgres/03-app-integration.md](references/docker-postgres/03-app-integration.md)
6. Generate and apply migrations using [references/04-migrations-validation.md](references/04-migrations-validation.md).
7. Update project documentation using [documentation-updates.md](../../shared/references/documentation-updates.md).
8. Write `project.storage_bucket_name` and `capabilities.file_storage = "ready"` to `docs/context.json`.
9. Run `pnpm format`, `pnpm typecheck`, `pnpm lint`, `pnpm build`, and migration commands. Fix any failures before proceeding.

## References

**Shared (both targets):**
- [references/02-file-schema-and-service.md](references/02-file-schema-and-service.md)
- [references/04-migrations-validation.md](references/04-migrations-validation.md)
- [shared/references/data-access-architecture.md](../../shared/references/data-access-architecture.md)
- [shared/references/documentation-updates.md](../../shared/references/documentation-updates.md)

**Cloudflare target:**
- [references/cloudflare/01-cloudflare-r2.md](references/cloudflare/01-cloudflare-r2.md)
- [references/cloudflare/03-app-integration.md](references/cloudflare/03-app-integration.md)
- [shared/references/worker-architecture.md](../../shared/references/worker-architecture.md)

**Docker/Postgres target:**
- [references/docker-postgres/01-rustfs-setup.md](references/docker-postgres/01-rustfs-setup.md)
- [references/docker-postgres/03-app-integration.md](references/docker-postgres/03-app-integration.md)

## Review Checklist

- [ ] Guard passed — `capabilities.database = "ready"` in `docs/context.json`.
- [ ] Object storage bucket created and bound.
- [ ] `app/db/schema.ts` exports a `files` table included in `schema`.
- [ ] Migration created the `files` metadata table.
- [ ] `app/services/file.service.ts` uploads to object store before inserting metadata.
- [ ] Failed metadata inserts delete the newly uploaded object.
- [ ] Deleting a file removes both the database row and the stored object.
- [ ] `app/context.ts` exposes `files: FilesService`.
- [ ] Server entry constructs `new FilesService(...)` and passes it to context.
- [ ] `docs/data-model.md` includes the `files` entity.
- [ ] `pnpm format`, `pnpm typecheck`, `pnpm lint`, `pnpm build`, and migration commands pass.
- [ ] `docs/context.json` updated with `project.storage_bucket_name` and `capabilities.file_storage = "ready"`.

# Adding File Storage

Creates a Cloudflare R2 bucket, adds a `files` metadata table to D1, builds a `FilesService` that stores bytes in R2 and metadata in D1, and wires the service into the Worker and app context.

## Context

**Guard** — stop before changing any files if `context.capabilities.database` is not `"ready"`:

```text
Stop — docs/context.json is missing capabilities.database = "ready". Run adding-database first, then re-run this skill.
```

Derive `PROJECT_PATH` from `context.repository.local_path`. On success write:

```json
{
  "project": { "r2_bucket_name": "<R2_BUCKET_NAME>" },
  "capabilities": { "file_storage": "ready" }
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

1. Read `docs/context.json`. Confirm `capabilities.database = "ready"`. Derive `PROJECT_PATH` from `context.repository.local_path`.
2. Create or register the Cloudflare R2 bucket using [01-cloudflare-r2.md](references/01-cloudflare-r2.md).
3. Add the file metadata schema and service using [02-file-schema-and-service.md](references/02-file-schema-and-service.md).
4. Read [data-access-architecture.md](../../shared/references/data-access-architecture.md) for the file metadata service and any data access changes.
5. Load `react-router-patterns`, then wire the service into app context and the Worker using [03-app-integration.md](references/03-app-integration.md).
6. Generate and apply migrations, validate types using [04-migrations-validation.md](references/04-migrations-validation.md).
7. Update project documentation using [documentation-updates.md](../../shared/references/documentation-updates.md): stack entry (`Cloudflare R2`), `files` entity in data model, README and AGENTS.md additions.
8. Write `project.r2_bucket_name` and `capabilities.file_storage = "ready"` to `docs/context.json`.
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

- [ ] `docs/context.json` guard passed (`capabilities.database = "ready"`).
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
- [ ] `docs/context.json` updated with `project.r2_bucket_name` and `capabilities.file_storage = "ready"`.
- [ ] Changes committed with Conventional Commit message.
