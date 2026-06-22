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

- Install `better-auth`, `zod@4`, `@conform-to/react`, and `@conform-to/zod`.
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

**Cloudflare target only:**
- Read [worker-architecture.md](../../shared/references/worker-architecture.md) before modifying `workers/app.ts`. Wire bindings inline — no helper files under `workers/`.
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

**Cloudflare target:**
- [references/cloudflare/01-dependencies-and-env.md](references/cloudflare/01-dependencies-and-env.md)
- [references/cloudflare/03-server-integration.md](references/cloudflare/03-server-integration.md)
- [shared/references/worker-architecture.md](../../shared/references/worker-architecture.md)

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

# Adding Authentication

Installs Better Auth with the Drizzle adapter, extends the D1 schema with auth tables, wires auth into the Worker and app context, and adds login, signup, and logout routes with Conform + Zod forms.

## Context

**Guard** — stop before changing any files if `context.capabilities.database` is not `"ready"`:

```text
Stop — docs/context.json is missing capabilities.database = "ready". Run adding-database first, then re-run this skill.
```

Derive `PROJECT_PATH` from `context.repository.local_path`. On success write:

```json
{
  "capabilities": { "authentication": "ready" }
}
```

Default D1 binding: `APP_DB`. Default auth cookie prefix: `App`.

## Rules

- Install `better-auth`, `zod@4`, `@conform-to/react`, and `@conform-to/zod`.
- Generate `AUTH_SECRET` with `openssl rand -base64 32` and write it to `.env`. Add an empty placeholder to `.env.example`. Never commit the real value.
- Use Better Auth with the Drizzle adapter, SQLite provider, and the existing D1 `APP_DB` binding.
- Keep auth tables in `app/db/schema.ts` with Better Auth-compatible table aliases in the adapter options.
- Keep auth endpoints under `app/routes/auth.tsx` at route path `api/auth/*` — it must be a splat route (`route("api/auth/*", ...)`); a non-splat path causes sub-endpoints like `/api/auth/sign-in/email` to 404.
- Generate the auth migration, then migrate both local and remote D1.
- Load `react-router-patterns` before adding or changing any route, loader, action, redirect, or form.
- Read [worker-architecture.md](../../shared/references/worker-architecture.md) before modifying `workers/app.ts`. Wire bindings inline — no helper files under `workers/`.
- Preserve existing route, Worker, context, shadcn/ui, and Tailwind patterns.
- If a public layout route already exists (e.g. from `adding-landing-page`), register `login`, `signup`, and `logout` routes **outside** that layout — auth routes must not be nested under the public layout. Register them at the root level in `app/routes.ts`.
- The cookie prefix in the Better Auth config must match what the client sends — mismatch causes sessions to silently return null (user appears logged out).
- Better Auth tables must exist before the server starts — unapplied migrations produce a D1 "no such table" error on the first request.
- `AUTH_SECRET` must be the same across dev and deployed environments — a new secret invalidates all existing sessions.

## Workflow

1. Read `docs/context.json`. Confirm `capabilities.database = "ready"`. Derive `PROJECT_PATH` from `context.repository.local_path`.
2. Install dependencies and configure secrets using [01-dependencies-and-env.md](references/01-dependencies-and-env.md).
3. Extend the Drizzle schema with auth tables and generate the migration using [02-auth-schema-and-migrations.md](references/02-auth-schema-and-migrations.md).
4. Wire Better Auth into React Router context and the Worker using [03-server-integration.md](references/03-server-integration.md).
5. Load `react-router-patterns`, then add `api/auth/*`, `login`, `logout`, and `signup` routes using [04-auth-routes-and-forms.md](references/04-auth-routes-and-forms.md).
6. Write unit tests for the login and signup route components using [05-tests.md](references/05-tests.md).
7. Update project documentation using [documentation-updates.md](../../shared/references/documentation-updates.md): stack entry (`Better Auth`), data model auth entities, auth route patterns in `docs/conventions/routes.md`, README and AGENTS.md additions.
8. Write `capabilities.authentication = "ready"` to `docs/context.json`.
9. Run `pnpm format`, `pnpm typecheck`, `pnpm lint`, `pnpm build`, and `pnpm test:unit`. Fix any failures before committing.
10. Commit using the repository's Conventional Commits format.

## References

- **Dependencies and env**: [references/01-dependencies-and-env.md](references/01-dependencies-and-env.md)
- **Auth schema and migrations**: [references/02-auth-schema-and-migrations.md](references/02-auth-schema-and-migrations.md)
- **Server integration**: [references/03-server-integration.md](references/03-server-integration.md)
- **Auth routes and forms**: [references/04-auth-routes-and-forms.md](references/04-auth-routes-and-forms.md)
- **Tests**: [references/05-tests.md](references/05-tests.md)
- **Documentation updates**: [documentation-updates.md](../../shared/references/documentation-updates.md)
- **Worker architecture**: [worker-architecture.md](../../shared/references/worker-architecture.md)

## Review Checklist

- [ ] `docs/context.json` guard passed (`capabilities.database = "ready"`).
- [ ] `better-auth`, `zod@4`, `@conform-to/react`, `@conform-to/zod` installed.
- [ ] `AUTH_SECRET` generated with `openssl rand -base64 32`; `.env` has the value; `.env.example` has empty placeholder.
- [ ] `app/db/schema.ts` exports `users`, `sessions`, `accounts`, `verifications`, their relations, and `schema`.
- [ ] Migration generated and applied to both local and remote D1.
- [ ] `app/context.ts` exposes `auth: ReturnType<typeof betterAuth>`.
- [ ] `workers/app.ts` constructs Better Auth with `drizzleAdapter` inline.
- [ ] `api/auth/*` is a splat route in `app/routes.ts`.
- [ ] Login, signup, and logout routes use Conform, Zod, Better Auth API errors, and safe redirects.
- [ ] `tests/unit/routes/login.test.tsx` and `signup.test.tsx` exist and pass.
- [ ] `docs/data-model.md` includes auth entities.
- [ ] `docs/conventions/routes.md` includes auth route patterns.
- [ ] `pnpm format`, `pnpm typecheck`, `pnpm lint`, `pnpm build`, and `pnpm test:unit` pass.
- [ ] `docs/context.json` updated with `capabilities.authentication = "ready"`.
- [ ] Changes committed with Conventional Commit message.
