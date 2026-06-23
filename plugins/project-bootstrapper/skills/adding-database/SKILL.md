---
name: adding-database
description: Adds a database to a bootstrapped project using Drizzle ORM. Dispatches to Cloudflare D1 or Postgres references based on deployment_target. Use when capabilities.database is planned and scaffolding-project has run.
---

# Adding Database

Installs Drizzle ORM, creates and binds the database (D1 or Postgres), generates the initial schema and migrations, wires the database into the server context, and sets up integration testing.

## Context

**Guard** — stop before changing any files if either field is missing from `docs/context.json`:
- `project.name`
- `project.deployment_target`

```text
Stop — docs/context.json is missing project.name or project.deployment_target.
Run scaffolding-project first, then re-run this skill.
```

Derive `PROJECT_PATH` from `context.repository.local_path`. Derive `DEPLOYMENT_TARGET` from `context.project.deployment_target`.

On success write to `docs/context.json`:

```json
{
  "project": { "database_name": "<DATABASE_NAME>" },
  "capabilities": { "database": "ready" }
}
```

Default binding/app name: `APP_DB`. Default migration directory: `db/migrations`. Default schema: `app/db/schema.ts`.

## Rules

- Use Drizzle ORM with `drizzle-zod` for DAO-owned validation schemas when DAOs are added.
- Do not hardcode account IDs, database IDs, or API tokens in source.
- Inject the database through router context; do not access it outside of loaders, actions, and services.
- Load `react-router-patterns` before changing React Router context or server request handling.
- Read [data-access-architecture.md](../../shared/references/data-access-architecture.md) before adding tables, DAOs, queries, services, or transactions.

**Cloudflare target only:**
- Use the SQLite dialect and Cloudflare D1 driver.
- Preserve existing `wrangler.jsonc` settings — merge D1 configuration in, never overwrite.
- Read [worker-architecture.md](../../shared/references/worker-architecture.md) before modifying `workers/app.ts`. Wire bindings inline — no helper files under `workers/`.
- `pnpm wrangler d1 create` outputs the database ID — capture it immediately.
- D1 is SQLite: no `ALTER COLUMN`. Changing a column type requires a new table + data copy.
- `drizzle-kit generate` needs `CLOUDFLARE_ACCOUNT_ID`, `CLOUDFLARE_DATABASE_ID`, and `CLOUDFLARE_D1_TOKEN` in `.env`.
- Local D1 (`pnpm db:local:migrate`) and remote D1 (`pnpm db:migrate`) use separate tracking — always run both.

**Docker/Postgres target only:**
- Use the Postgres dialect and `node-postgres` (`pg`) driver.
- `DATABASE_URL` in `.env` — format: `postgres://user:pass@localhost:5432/dbname`.
- Docker Compose must be running before running migrations or integration tests.

## Workflow

1. Read `docs/context.json`. Confirm guards pass. Derive `PROJECT_PATH` and `DEPLOYMENT_TARGET`.
2. Install and configure Drizzle using [references/01-drizzle-setup.md](references/01-drizzle-setup.md).
3. **Dispatch on deployment target:**
   - `cloudflare` → Create or register the D1 database using [references/cloudflare/02-cloudflare-d1.md](references/cloudflare/02-cloudflare-d1.md)
   - `docker-postgres` → Configure the Postgres connection using [references/docker-postgres/02-postgres-setup.md](references/docker-postgres/02-postgres-setup.md)
4. Load `react-router-patterns`, then add the database schema and wire Drizzle into app context and the server using [references/03-app-integration.md](references/03-app-integration.md).
5. If adding application tables, DAOs, queries, services, or transactions, follow [data-access-architecture.md](../../shared/references/data-access-architecture.md).
6. Generate and apply migrations using [references/04-migrations-validation.md](references/04-migrations-validation.md).
7. **Set up integration testing:**
   - `cloudflare` → Miniflare D1 using [references/cloudflare/05-testing-setup.md](references/cloudflare/05-testing-setup.md)
   - `docker-postgres` → Postgres integration tests using [references/docker-postgres/05-testing-setup.md](references/docker-postgres/05-testing-setup.md)
8. Update project documentation using [documentation-updates.md](../../shared/references/documentation-updates.md) and [references/08-doc-updates.md](references/08-doc-updates.md).
9. Write `project.database_name` and `capabilities.database = "ready"` to `docs/context.json`.
10. Run `pnpm format`, `pnpm typecheck`, `pnpm lint`, `pnpm test`, and `pnpm build`. For Cloudflare also run `pnpm db:local:migrate`. Fix any failures before proceeding.

## References

**Shared (both targets):**
- [references/01-drizzle-setup.md](references/01-drizzle-setup.md)
- [references/03-app-integration.md](references/03-app-integration.md)
- [references/04-migrations-validation.md](references/04-migrations-validation.md)
- [references/08-doc-updates.md](references/08-doc-updates.md)
- [shared/references/data-access-architecture.md](../../shared/references/data-access-architecture.md)

**Cloudflare target:**
- [references/cloudflare/02-cloudflare-d1.md](references/cloudflare/02-cloudflare-d1.md)
- [references/cloudflare/05-testing-setup.md](references/cloudflare/05-testing-setup.md)
- [shared/references/worker-architecture.md](../../shared/references/worker-architecture.md)

**Docker/Postgres target:**
- [references/docker-postgres/02-postgres-setup.md](references/docker-postgres/02-postgres-setup.md)
- [references/docker-postgres/05-testing-setup.md](references/docker-postgres/05-testing-setup.md)

## Review Checklist

- [ ] Guards passed — `project.name` and `project.deployment_target` present in `docs/context.json`.
- [ ] `drizzle-orm`, `drizzle-zod`, and `drizzle-kit` installed.
- [ ] `package.json` includes `db:generate` and `db:migrate` scripts.
- [ ] `app/db/schema.ts` exports `schema`.
- [ ] Database wired into app context (`db` field in `appContext`).
- [ ] Integration tests set up and passing.
- [ ] `docs/data-model.md` created and reflects `app/db/schema.ts`.
- [ ] `docs/conventions/data-access.md` and `docs/conventions/testing.md` created.
- [ ] `pnpm format`, `pnpm typecheck`, `pnpm lint`, `pnpm test`, and `pnpm build` pass.
- [ ] `docs/context.json` updated with `project.database_name` and `capabilities.database = "ready"`.

# Adding D1 Database

Installs Drizzle ORM, creates and binds a Cloudflare D1 database, generates the initial schema and migrations, wires the database into the Worker and app context, and sets up Miniflare integration testing.

## Context

**Guard** — stop before changing any files if `context.project.name` is missing:

```text
Stop — docs/context.json is missing project.name. Run scaffolding-project first, then re-run this skill.
```

Derive `PROJECT_PATH` from `context.repository.local_path`. On success write:

```json
{
  "project": { "d1_database_name": "<D1_DATABASE_NAME>" },
  "capabilities": { "database": "ready" }
}
```

Default binding: `APP_DB`. Default migration directory: `db/migrations`. Default schema: `app/db/schema.ts`.

## Rules

- Use Drizzle ORM with the SQLite dialect and Cloudflare D1 driver.
- Use `drizzle-zod` for DAO-owned validation schemas when DAOs are added.
- Do not hardcode Cloudflare account IDs, database IDs, or API tokens in source.
- Preserve existing `wrangler.jsonc` settings — merge D1 configuration in, never overwrite.
- Inject the database through router context; do not access it outside of loaders, actions, and services.
- Read [worker-architecture.md](../../shared/references/worker-architecture.md) before modifying `workers/app.ts`. Wire bindings inline — no helper files under `workers/`.
- Load `react-router-patterns` before changing React Router context or Worker request handling.
- Read [data-access-architecture.md](../../shared/references/data-access-architecture.md) before adding tables, DAOs, queries, services, or transactions.
- `pnpm wrangler d1 create` outputs the database ID — capture it immediately; `wrangler d1 list` requires authentication to retrieve it later.
- D1 is SQLite: no `ALTER COLUMN`. Changing a column type requires a new table + data copy. Drizzle Kit handles this but the migration may drop and recreate tables — review before applying.
- `drizzle-kit generate` needs `CLOUDFLARE_ACCOUNT_ID`, `CLOUDFLARE_DATABASE_ID`, and `CLOUDFLARE_D1_TOKEN` in `.env` — missing values produce an unhelpful credentials error.
- Local D1 (`pnpm db:local:migrate`) and remote D1 (`pnpm db:migrate`) use separate migration tracking — always run both after generating a new migration.

## Workflow

1. Read `docs/context.json`. Confirm `project.name` is present. Derive `PROJECT_PATH` from `context.repository.local_path`.
2. Install and configure Drizzle using [01-drizzle-setup.md](references/01-drizzle-setup.md).
3. Create or register the Cloudflare D1 database and environment variables using [02-cloudflare-d1.md](references/02-cloudflare-d1.md).
4. Load `react-router-patterns`, then add the database schema and wire Drizzle into app context and the Worker using [03-app-integration.md](references/03-app-integration.md).
5. If adding application tables, DAOs, queries, services, or transactions, follow [data-access-architecture.md](../../shared/references/data-access-architecture.md).
6. Generate and apply migrations using [04-migrations-validation.md](references/04-migrations-validation.md).
7. Set up integration testing with Miniflare using [05-testing-setup.md](references/05-testing-setup.md).
8. Update project documentation using [documentation-updates.md](../../shared/references/documentation-updates.md) and [08-doc-updates.md](references/08-doc-updates.md): stack entry, directory structure, data model link, data-access convention, testing convention, README and AGENTS.md additions.
9. Write `project.d1_database_name` and `capabilities.database = "ready"` to `docs/context.json`.
10. Run `pnpm format`, `pnpm typecheck`, `pnpm lint`, `pnpm test`, `pnpm build`, `pnpm db:local:migrate`. Fix any failures before committing.
11. Commit using the repository's Conventional Commits format.

## References

- **Drizzle setup**: [references/01-drizzle-setup.md](references/01-drizzle-setup.md)
- **Cloudflare D1**: [references/02-cloudflare-d1.md](references/02-cloudflare-d1.md)
- **App integration**: [references/03-app-integration.md](references/03-app-integration.md)
- **Migrations and validation**: [references/04-migrations-validation.md](references/04-migrations-validation.md)
- **Integration testing**: [references/05-testing-setup.md](references/05-testing-setup.md)
- **D1 doc updates**: [references/08-doc-updates.md](references/08-doc-updates.md)
- **Documentation updates**: [documentation-updates.md](../../shared/references/documentation-updates.md)
- **Data access architecture**: [data-access-architecture.md](../../shared/references/data-access-architecture.md)
- **Worker architecture**: [worker-architecture.md](../../shared/references/worker-architecture.md)

## Review Checklist

- [ ] `docs/context.json` guard passed (`project.name` present).
- [ ] `drizzle-orm`, `drizzle-zod`, and `drizzle-kit` installed.
- [ ] `package.json` includes `db:generate`, `db:migrate`, and `db:local:migrate`.
- [ ] `drizzle.config.ts` reads Cloudflare credentials from `.env`.
- [ ] `.env.example` documents `CLOUDFLARE_ACCOUNT_ID`, `CLOUDFLARE_DATABASE_ID`, and `CLOUDFLARE_D1_TOKEN`.
- [ ] `wrangler.jsonc` includes D1 binding with `migrations_table` and `migrations_dir`.
- [ ] `app/db/schema.ts` exports `schema`.
- [ ] `app/context.ts` exposes `db: DrizzleD1Database<typeof schema>`.
- [ ] `workers/app.ts` creates `drizzle(env.APP_DB, { schema })` inline.
- [ ] `@cloudflare/vitest-pool-workers` installed; integration test config and utils exist.
- [ ] `pnpm test` passes integration tests against Miniflare D1.
- [ ] `docs/data-model.md` created and reflects `app/db/schema.ts`.
- [ ] `docs/conventions/data-access.md` and `docs/conventions/testing.md` created.
- [ ] `pnpm format`, `pnpm typecheck`, `pnpm lint`, `pnpm build`, and `pnpm db:local:migrate` pass.
- [ ] `docs/context.json` updated with `project.d1_database_name` and `capabilities.database = "ready"`.
- [ ] Changes committed with Conventional Commit message.
