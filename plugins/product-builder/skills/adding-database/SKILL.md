---
name: adding-database
description: Adds a Cloudflare D1 database to an existing Product Builder project using Drizzle ORM, Wrangler bindings, migrations, and React Router server context. Use when the user asks to add D1, Cloudflare database storage, Drizzle ORM, database migrations, or persistent SQLite data to an existing Cloudflare Workers React Router project.
---

# Adding D1 Database

Installs Drizzle ORM, creates and binds a Cloudflare D1 database, generates the initial schema and migrations, wires the database into the Worker and app context, and sets up Miniflare integration testing.

## Context

**Guard** — stop before changing any files if `context.project.name` is missing:

```text
Stop — docs/context.json is missing project.name. Run scaffolding-project first, then re-run this skill.
```

Set `skills.adding-database` to `in-progress` at the start. Derive `PROJECT_PATH` from `context.repository.local_path`. On success write:

```json
{
  "project": { "d1_database_name": "<D1_DATABASE_NAME>" },
  "capabilities": { "database": true },
  "skills": { "adding-database": "done" }
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

1. Read `docs/context.json`. Confirm `project.name` is present. Set `skills.adding-database` to `in-progress`.
2. Install and configure Drizzle using [01-drizzle-setup.md](references/01-drizzle-setup.md).
3. Create or register the Cloudflare D1 database and environment variables using [02-cloudflare-d1.md](references/02-cloudflare-d1.md).
4. Load `react-router-patterns`, then add the database schema and wire Drizzle into app context and the Worker using [03-app-integration.md](references/03-app-integration.md).
5. If adding application tables, DAOs, queries, services, or transactions, follow [data-access-architecture.md](../../shared/references/data-access-architecture.md).
6. Generate and apply migrations using [04-migrations-validation.md](references/04-migrations-validation.md).
7. Set up integration testing with Miniflare using [05-testing-setup.md](references/05-testing-setup.md).
8. Update project documentation using [documentation-updates.md](../../shared/references/documentation-updates.md) and [08-doc-updates.md](references/08-doc-updates.md): stack entry, directory structure, data model link, data-access convention, testing convention, README and AGENTS.md additions.
9. Write `project.d1_database_name`, `capabilities.database = true`, and `skills.adding-database = "done"` to `docs/context.json`.
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
- [ ] `docs/context.json` updated with `project.d1_database_name`, `capabilities.database = true`, and `skills.adding-database = "done"`.
- [ ] Changes committed with Conventional Commit message.
