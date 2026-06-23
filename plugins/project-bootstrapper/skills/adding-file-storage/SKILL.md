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
