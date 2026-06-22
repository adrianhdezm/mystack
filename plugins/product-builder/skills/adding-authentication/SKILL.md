---
name: adding-authentication
description: Adds Better Auth email-and-password authentication to an existing Product Builder Cloudflare Workers, React Router, Drizzle D1, TypeScript, Tailwind, and shadcn/ui project. Use when the user asks to add login, signup/register, logout, auth routes, session handling, Better Auth, or authentication-backed protected routes to a Product Builder project.
---

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
