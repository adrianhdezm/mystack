---
name: adding-database
description: Adds a Cloudflare D1 database to an existing Product Builder project using Drizzle ORM, Wrangler bindings, migrations, and React Router server context. Use when the user asks to add D1, Cloudflare database storage, Drizzle ORM, database migrations, or persistent SQLite data to an existing Cloudflare Workers React Router project.
---

# Adding D1 Database

## Required inputs

Work in the target project repository. If the project path is unclear, ask for
only the path before changing files.

Derive these values from the project or user prompt when possible:

```text
PROJECT_PATH: <absolute path>
D1_DATABASE_NAME: <cloudflare-d1-database-name>
D1_BINDING: APP_DB
```

Use `APP_DB` as the default binding unless the existing project already uses a
different D1 binding.

## Hard rules

- Use `pnpm` for package installation and scripts.
- Use Drizzle ORM with the SQLite dialect and Cloudflare D1 driver.
- Do not hardcode Cloudflare account IDs, database IDs, or API tokens in source.
- Keep generated migrations under `db/migrations`.
- Keep the application schema in `app/db/schema.ts`.
- Preserve existing `wrangler.jsonc` settings and merge D1 configuration into it.
- Preserve existing React Router request handling and inject the database through
  router context.

## Workflow

1. Verify the target project is a Product Builder-style Cloudflare Workers,
   Vite, React Router, TypeScript, and pnpm project.
2. Install and configure Drizzle using
   [01-drizzle-setup.md](references/01-drizzle-setup.md).
3. Create or register the Cloudflare D1 database and environment variables using
   [02-cloudflare-d1.md](references/02-cloudflare-d1.md).
4. Add the database schema and wire Drizzle into app context and the Worker using
   [03-app-integration.md](references/03-app-integration.md).
5. Generate and apply migrations using
   [04-migrations-validation.md](references/04-migrations-validation.md).
6. Update project documentation in `README.md` and `AGENTS.md` with the D1
   setup, required environment variables, and migration commands.
7. Run formatting, typecheck, lint, build, and the migration commands available
   for the current environment.
8. Commit the changes with the repository's Conventional Commit format when the
   user requested a commit or the active Product Builder workflow expects one.

## Validation checklist

- [ ] `drizzle-orm` is installed and `drizzle-kit` is installed as a dev dependency.
- [ ] `package.json` includes `db:generate`, `db:migrate`, and `db:local:migrate`.
- [ ] `drizzle.config.ts` reads Cloudflare credentials from `.env`.
- [ ] `.env.example` documents `CLOUDFLARE_ACCOUNT_ID`, `CLOUDFLARE_DATABASE_ID`, and `CLOUDFLARE_D1_TOKEN`.
- [ ] `.env` uses the account ID from `pnpm wrangler whoami` and the database ID from `pnpm wrangler d1 create`.
- [ ] `wrangler.jsonc` includes a D1 binding with `migrations_table` and `migrations_dir`.
- [ ] `app/db/schema.ts` exports `schema`.
- [ ] `app/context.ts` exposes `db: DrizzleD1Database<typeof schema>`.
- [ ] `workers/app.ts` creates `drizzle(env.APP_DB, { schema })` and sets it in router context.
- [ ] `README.md` documents the D1 setup, required environment variables, and migration commands.
- [ ] `AGENTS.md` documents database-specific project instructions agents must follow.
- [ ] `pnpm db:generate`, `pnpm db:migrate`, and `pnpm db:local:migrate` work or failures are explained.
