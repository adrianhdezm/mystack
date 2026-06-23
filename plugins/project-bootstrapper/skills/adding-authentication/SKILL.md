---
name: adding-authentication
description: Adds Better Auth email-and-password authentication to a bootstrapped project. Dispatches Cloudflare or Docker/Postgres server integration based on deployment_target. Use when capabilities.authentication is planned and adding-database has run.
---

# Adding Authentication

Installs Better Auth with the Drizzle adapter, extends the schema with auth tables, wires auth into the server and app context, and adds login, signup, and logout routes with Conform + Zod forms.

## Context

**Guard** — stop before changing any files if `context.capabilities.database` is not `"ready"`:

```text
Stop — docs/context.json is missing capabilities.database = "ready". Run adding-database first, then re-run this skill.
```

Derive `PROJECT_PATH` from `context.repository.local_path`. Derive `DEPLOYMENT_TARGET` from `context.project.deployment_target`.

On success write:

```json
{
  "capabilities": { "authentication": "ready" }
}
```

Default DB binding: `APP_DB`. Default auth cookie prefix: `App`.

## Rules

- Install `better-auth`, `zod@4`, `@conform-to/react`, and `@conform-to/zod`. In route files, import `parseWithZod` from `@conform-to/zod/v4` and `z` from `zod/v4` — the top-level `@conform-to/zod` import is the v3 API and does not work with zod v4.
- Generate `AUTH_SECRET` with `openssl rand -base64 32` and write it to `.env`. Add an empty placeholder to `.env.example`. Never commit the real value.
- Use Better Auth with the Drizzle adapter and the existing database.
- Keep auth tables in `app/db/schema.ts` with Better Auth-compatible table aliases in the adapter options.
- Keep auth endpoints under `app/routes/auth.tsx` at route path `api/auth/*` — it must be a splat route; a non-splat path causes sub-endpoints to 404.
- Load `react-router-patterns` before adding or changing any route, loader, action, redirect, or form.
- Preserve existing route, context, shadcn/ui, and Tailwind patterns.
- If a public layout route already exists, register `login`, `signup`, and `logout` routes **outside** that layout — auth routes must not be nested under the public layout.
- The cookie prefix in the Better Auth config must match what the client sends — mismatch causes sessions to silently return null.
- Better Auth tables must exist before the server starts — unapplied migrations produce a "no such table" error on the first request.
- `AUTH_SECRET` must be the same across dev and deployed environments — a new secret invalidates all existing sessions.
- Read [app-architecture.md](../../shared/references/app-architecture.md) before modifying `workers/app.ts`. Wire capabilities inline — no helper files under `workers/`.

**Cloudflare target only:**
- Use the SQLite provider with Better Auth's Drizzle adapter.
- Better Auth must be constructed per request (inside `fetch`) — Cloudflare Workers only expose `env` bindings inside the `fetch` handler.
- Generate and apply migration to both local and remote D1.

**Docker/Postgres target only:**
- Use the Postgres provider with Better Auth's Drizzle adapter.
- Auth can be constructed once at module scope (Node.js has a stable connection pool).
- Run `pnpm db:migrate` to apply the auth migration to Docker Postgres.

## Workflow

1. Read `docs/context.json`. Confirm guard passes. Derive `PROJECT_PATH` and `DEPLOYMENT_TARGET`.
2. **Install dependencies and configure secrets:**
   - `cloudflare` → [references/cloudflare/01-dependencies-and-env.md](references/cloudflare/01-dependencies-and-env.md)
   - `docker-postgres` → [references/docker-postgres/01-dependencies-and-env.md](references/docker-postgres/01-dependencies-and-env.md)
3. Extend the Drizzle schema with auth tables and generate the migration using [references/02-auth-schema-and-migrations.md](references/02-auth-schema-and-migrations.md).
4. **Wire Better Auth into app context and the server:**
   - `cloudflare` → [references/cloudflare/03-server-integration.md](references/cloudflare/03-server-integration.md)
   - `docker-postgres` → [references/docker-postgres/03-server-integration.md](references/docker-postgres/03-server-integration.md)
5. Load `react-router-patterns`, then add `api/auth/*`, `login`, `logout`, and `signup` routes using [references/04-auth-routes-and-forms.md](references/04-auth-routes-and-forms.md).
6. Write unit tests for the login and signup route components using [references/05-tests.md](references/05-tests.md).
7. Update project documentation using [documentation-updates.md](../../shared/references/documentation-updates.md).
8. Write `capabilities.authentication = "ready"` to `docs/context.json`.
9. Run `pnpm format`, `pnpm typecheck`, `pnpm lint`, `pnpm build`, and `pnpm test:unit`. Fix any failures before proceeding.

## References

**Shared (both targets):**
- [references/02-auth-schema-and-migrations.md](references/02-auth-schema-and-migrations.md)
- [references/04-auth-routes-and-forms.md](references/04-auth-routes-and-forms.md)
- [references/05-tests.md](references/05-tests.md)
- [shared/references/documentation-updates.md](../../shared/references/documentation-updates.md)
- [shared/references/app-architecture.md](../../shared/references/app-architecture.md)

**Cloudflare target:**
- [references/cloudflare/01-dependencies-and-env.md](references/cloudflare/01-dependencies-and-env.md)
- [references/cloudflare/03-server-integration.md](references/cloudflare/03-server-integration.md)

**Docker/Postgres target:**
- [references/docker-postgres/01-dependencies-and-env.md](references/docker-postgres/01-dependencies-and-env.md)
- [references/docker-postgres/03-server-integration.md](references/docker-postgres/03-server-integration.md)

## Review Checklist

- [ ] Guard passed — `capabilities.database = "ready"` in `docs/context.json`.
- [ ] `better-auth`, `zod@4`, `@conform-to/react`, `@conform-to/zod` installed.
- [ ] `AUTH_SECRET` generated; `.env` has value; `.env.example` has empty placeholder.
- [ ] `app/db/schema.ts` exports auth tables (`users`, `sessions`, `accounts`, `verifications`) with relations.
- [ ] Migration generated and applied.
- [ ] `app/context.ts` exposes `auth: ReturnType<typeof betterAuth>`.
- [ ] Server entry constructs Better Auth with Drizzle adapter.
- [ ] `api/auth/*` is a splat route in `app/routes.ts`.
- [ ] Login, signup, and logout routes use Conform, Zod, Better Auth API errors, and safe redirects.
- [ ] `tests/unit/routes/login.test.tsx` and `signup.test.tsx` exist and pass.
- [ ] `pnpm format`, `pnpm typecheck`, `pnpm lint`, `pnpm build`, and `pnpm test:unit` pass.
- [ ] `docs/context.json` updated with `capabilities.authentication = "ready"`.
