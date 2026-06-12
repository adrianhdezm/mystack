---
name: adding-database
description: Adds a Cloudflare D1 database to an existing Product Builder project using Drizzle ORM, Wrangler bindings, migrations, and React Router server context. Use when the user asks to add D1, Cloudflare database storage, Drizzle ORM, database migrations, or persistent SQLite data to an existing Cloudflare Workers React Router project.
---

# Adding D1 Database

## Required inputs

Work in the target project repository. If the project path is unclear, ask for only the path before changing files.

Derive these values from the project or user prompt when possible:

```text
PROJECT_PATH: <absolute path>
D1_DATABASE_NAME: <cloudflare-d1-database-name>
D1_BINDING: APP_DB
```

Use `APP_DB` as the default binding unless the existing project already uses a different D1 binding.

## Hard rules

- Use `pnpm` for package installation and scripts.
- Load `react-router-patterns` before changing React Router context, Worker request handling, route modules, loaders, or actions. Any React Router code must follow those patterns.
- Use Drizzle ORM with the SQLite dialect and Cloudflare D1 driver.
- Use `drizzle-zod` for DAO-owned validation schemas when DAOs are added.
- Do not hardcode Cloudflare account IDs, database IDs, or API tokens in source.
- Keep generated migrations under `db/migrations`.
- Keep the application schema in `app/db/schema.ts`.
- Read [data-access-architecture.md](../../shared/references/data-access-architecture.md) when adding tables, DAOs, services, transactions, or data access workflows.
- Preserve existing `wrangler.jsonc` settings and merge D1 configuration into it.
- Preserve existing React Router request handling and inject the database through router context.

## Gotchas

- D1 is SQLite. There is no `ALTER COLUMN` — changing a column type or adding a `NOT NULL` column without a default requires creating a new table, copying data, and dropping the old one. Drizzle Kit handles this automatically during migration generation, but the resulting migration may drop and recreate tables.
- `pnpm wrangler d1 create` returns the database ID in its output. Capture it immediately — there is no list command that shows the ID later without `wrangler d1 list`, which requires an authenticated session.
- `drizzle-kit generate` reads `drizzle.config.ts`, which needs `CLOUDFLARE_ACCOUNT_ID`, `CLOUDFLARE_DATABASE_ID`, and `CLOUDFLARE_D1_TOKEN` in `.env`. If `.env` is missing or incomplete, the command fails with an unhelpful credentials error.
- Local D1 (`pnpm wrangler d1 migrations apply --local`) and remote D1 (`pnpm db:migrate`) use different migration tracking. Always run both after generating a new migration.

## Workflow

1. Verify the target project is a Product Builder-style Cloudflare Workers, Vite, React Router, TypeScript, and pnpm project.
2. Install and configure Drizzle using [01-drizzle-setup.md](references/01-drizzle-setup.md).
3. Create or register the Cloudflare D1 database and environment variables using [02-cloudflare-d1.md](references/02-cloudflare-d1.md).
4. Load `react-router-patterns`, then add the database schema and wire Drizzle into app context and the Worker using [03-app-integration.md](references/03-app-integration.md).
5. If adding application tables, DAOs, services, transactions, or data access workflows, follow [data-access-architecture.md](../../shared/references/data-access-architecture.md).
6. Generate and apply migrations using [04-migrations-validation.md](references/04-migrations-validation.md).
7. Update project documentation using [documentation-updates.md](../../shared/references/documentation-updates.md) with these specifics:
   - **Stack addition**: `Drizzle ORM, Cloudflare D1`.
   - **Structure additions**: `app/db/` (schema.ts, dao.ts, daos/), `app/services/`, `db/migrations/`.
   - **Data model link**: `See [data-model.md](data-model.md)` in architecture.
   - **New convention**: `docs/conventions/data-access.md` — seed with key patterns from [data-access-architecture.md](../../shared/references/data-access-architecture.md): DAO interface contract, one DAO per table, type ownership (`<Entity>Record`, `Create<Entity>`, `Update<Entity>`, `<Entity>Filters`), `getAll()` for filtered access, service transaction boundaries, dependency graph (Routes → Services → DAOs → Database). Anti-patterns: no custom public query methods on DAOs, no DAO-to-DAO imports, no business logic in DAOs, no `Promise.all` for D1 queries (D1 is SQLite — all queries run sequentially over a single connection, so `Promise.all` adds overhead without parallelism; use sequential `await` instead), no looped individual queries for batch operations (use a single query with `inArray()` instead, e.g. `db.delete(table).where(inArray(table.id, ids))`), no `db.transaction()` on D1 (D1 does not support interactive SQL transactions — `db.transaction()` throws at runtime; use Drizzle's `db.batch()` API for atomic multi-statement writes, which executes statements sequentially and rolls back on failure).
   - **README additions**: D1 setup, required environment variables, migration commands.
   - **AGENTS.md additions**: database instructions, `docs/data-model.md` reference in Project Documentation section.
8. Run formatting, typecheck, lint, build, and the migration commands available for the current environment. If any command fails, fix the issue and re-run until it passes before committing.
9. Commit the generated and updated files in the repository using the repository's Conventional Commits format.

## Validation checklist

- [ ] `drizzle-orm`, `drizzle-zod`, and `drizzle-kit` are installed.
- [ ] `package.json` includes `db:generate`, `db:migrate`, and `db:local:migrate`.
- [ ] `drizzle.config.ts` reads Cloudflare credentials from `.env`.
- [ ] `.env.example` documents `CLOUDFLARE_ACCOUNT_ID`, `CLOUDFLARE_DATABASE_ID`, and `CLOUDFLARE_D1_TOKEN`.
- [ ] `.env` uses the account ID from `pnpm wrangler whoami` and the database ID from `pnpm wrangler d1 create`.
- [ ] `wrangler.jsonc` includes a D1 binding with `migrations_table` and `migrations_dir`.
- [ ] `app/db/schema.ts` exports `schema`.
- [ ] `app/context.ts` exposes `db: DrizzleD1Database<typeof schema>`.
- [ ] `workers/app.ts` creates `drizzle(env.APP_DB, { schema })` and sets it in router context.
- [ ] `data-access-architecture.md` was followed for any tables, DAOs, services, transactions, or data access workflows.
- [ ] `react-router-patterns` was loaded and followed for any React Router context or Worker request-handling changes.
- [ ] `docs/architecture.md` includes Drizzle ORM / D1 in stack, db/ directories in structure, data model link, and data-access convention link.
- [ ] `docs/data-model.md` was created and reflects `app/db/schema.ts`.
- [ ] `docs/conventions/data-access.md` was created with seed patterns from `data-access-architecture.md`.
- [ ] `README.md` documents the D1 setup, required environment variables, and migration commands.
- [ ] `AGENTS.md` documents database-specific instructions and references `docs/data-model.md` in the Project Documentation section.
- [ ] `pnpm db:generate`, `pnpm db:migrate`, and `pnpm db:local:migrate` work or failures are explained.
- [ ] Generated and updated files were committed with a Conventional Commit message.
