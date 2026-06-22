---
name: adding-authentication
description: Adds Better Auth email-and-password authentication to an existing Product Builder Cloudflare Workers, React Router, Drizzle D1, TypeScript, Tailwind, and shadcn/ui project. Use when the user asks to add login, signup/register, logout, auth routes, session handling, Better Auth, or authentication-backed protected routes to a Product Builder project.
---

# Adding Authentication

## Context

Read [context-schema.md](../../shared/references/context-schema.md) for the full `docs/context.json` schema, field reference, and guard pattern.

**Guard** — stop before changing any files if `context.capabilities.database` is not `true` in `docs/context.json`. Stop with:

```text
Stop — docs/context.json is missing capabilities.database = true. Run adding-database first, then re-run this skill.
```

Set `skills.adding-authentication` to `in-progress` at the start of the workflow. On successful completion, write the following and set the status to `done`.

**Writes:**

```json
{
  "capabilities": { "authentication": true },
  "skills": { "adding-authentication": "done" }
}
```

## Required inputs

Work in the target Product Builder project repository. Derive `PROJECT_PATH` from `context.repository.local_path`. If the context file is missing, ask only for the path before changing files.

Derive these values from the project or user prompt when possible:

```text
PROJECT_PATH: <absolute path>
D1_BINDING: APP_DB
AUTH_COOKIE_PREFIX: App
```

## Hard rules

- Load `react-router-patterns` before adding or changing React Router routes, loaders, actions, redirects, forms, protected routes, or app-level route files. Any React Router code must follow those patterns.
- Install `better-auth`, `zod@4`, `@conform-to/react`, and `@conform-to/zod`.
- Generate `AUTH_SECRET` with `openssl rand -base64 32` and write it to `.env` as `AUTH_SECRET=<generated-value>`.
- Do not commit real `.env` secret values. Update `.env.example` with an `AUTH_SECRET=` placeholder.
- Use Better Auth with the Drizzle adapter, SQLite provider, and the existing D1 `APP_DB` binding.
- Keep auth tables in `app/db/schema.ts` with Better Auth-compatible table aliases in the adapter options.
- Generate the auth migration, then migrate both local and remote D1.
- Keep auth endpoints under `app/routes/auth.tsx` at route path `api/auth/*`.
- Add login, signup/register, and logout routes using React Router actions and loaders.
- Preserve existing route, Worker, context, shadcn/ui, and Tailwind patterns.
- Read [worker-architecture.md](../../shared/references/worker-architecture.md) when modifying `workers/app.ts`. New bindings must be wired inline — do not create helper files in `workers/`.

## Gotchas

- Better Auth session cookies use a prefix (`App` by default). If the cookie prefix in the auth config does not match what the client sends, every session check silently returns null — the user appears logged out with no error.
- Better Auth expects its tables to exist before the server starts. If migrations have not been applied, the auth handler throws a D1 "no such table" error on the first request.
- `AUTH_SECRET` must be the same between dev and deployed environments. Generating a new secret invalidates all existing sessions.
- The `api/auth/*` route must be a splat route (`route("api/auth/*", "routes/auth.tsx")`). Using a non-splat path causes Better Auth sub-endpoints like `/api/auth/sign-in/email` to 404.

## Workflow

1. Verify the target project is a Product Builder Cloudflare Workers, React Router, TypeScript, pnpm, D1, and Drizzle project.
2. Install dependencies and configure secrets using [01-dependencies-and-env.md](references/01-dependencies-and-env.md).
3. Replace or extend the Drizzle schema with the required auth tables using [02-auth-schema-and-migrations.md](references/02-auth-schema-and-migrations.md).
4. Wire Better Auth into React Router context and the Worker using [03-server-integration.md](references/03-server-integration.md).
5. Load `react-router-patterns`, then add `api/auth/*`, `login`, `logout`, and `signup` routes using [04-auth-routes-and-forms.md](references/04-auth-routes-and-forms.md).
6. Write unit tests for the login and signup route components using [05-tests.md](references/05-tests.md).
7. Update project documentation using [documentation-updates.md](../../shared/references/documentation-updates.md) with these specifics:
   - **Stack addition**: `Better Auth (email + password)`.
   - **Data model addition**: auth entities (`users`, `sessions`, `accounts`, `verifications`) matching `app/db/schema.ts`.
   - **Convention update**: `docs/conventions/routes.md` — add auth-related route patterns: protected route loader check, login/signup form action with Better Auth API, logout action, safe redirect after auth.
   - **README additions**: auth setup, `AUTH_SECRET`, `pnpm wrangler secret put AUTH_SECRET` for remote deploys, migration commands.
   - **AGENTS.md additions**: auth instructions (environment variables, migration commands).
8. Write `capabilities.authentication = true` and `skills.adding-authentication = "done"` to `docs/context.json`.
9. Run formatting, typecheck, lint, build, and unit tests. If any command fails, fix the issue and re-run until it passes before committing.
10. Commit the generated and updated files using the repository's Conventional Commits format.

## Validation checklist

- [ ] `better-auth`, `zod@4`, `@conform-to/react`, and `@conform-to/zod` are installed.
- [ ] `.env` contains `AUTH_SECRET=<secret generated with openssl rand -base64 32>`.
- [ ] `.env.example` documents `AUTH_SECRET=`.
- [ ] `README.md` documents that remote Cloudflare deployments require users to run `pnpm wrangler secret put AUTH_SECRET` from an authenticated Wrangler session.
- [ ] `docs/architecture.md` includes Better Auth in the Stack section.
- [ ] `docs/data-model.md` includes auth entities (users, sessions, accounts, verifications) matching `app/db/schema.ts`.
- [ ] `docs/conventions/routes.md` includes auth-related route patterns (protected routes, login/signup actions, logout, safe redirect).
- [ ] `AGENTS.md` documents auth setup, environment variables, and migration commands, and references `docs/`.
- [ ] `app/db/schema.ts` exports `users`, `sessions`, `accounts`, `verifications`, their relations, and `schema`.
- [ ] A new Drizzle migration exists under `db/migrations`.
- [ ] Local and remote D1 migrations were applied, or failures are explained.
- [ ] `app/context.ts` exposes `auth: ReturnType<typeof betterAuth>`.
- [ ] `workers/app.ts` constructs Better Auth with `drizzleAdapter`.
- [ ] `app/routes.ts` includes `api/auth/*`, `login`, `logout`, and `signup`.
- [ ] `react-router-patterns` was loaded and followed for auth routes, loaders, actions, redirects, and forms.
- [ ] Route loaders and actions access auth with `context.get(appContext)`.
- [ ] `app/routes/auth.tsx` delegates loader and action to `auth.handler(request)`.
- [ ] Login and signup use Conform, Zod, Better Auth API errors, and safe redirects.
- [ ] Logout signs out through `auth.api.signOut`.
- [ ] `tests/unit/routes/login.test.tsx` exists and all tests pass.
- [ ] `tests/unit/routes/signup.test.tsx` exists and all tests pass.
- [ ] `pnpm format`, `pnpm typecheck`, `pnpm lint`, `pnpm build`, and `pnpm test:unit` pass after fixes.
- [ ] `docs/context.json` guards passed (`capabilities.database = true`).
- [ ] `docs/context.json` was updated with `capabilities.authentication = true` and `skills.adding-authentication = "done"`.
- [ ] Generated and updated files were committed with a Conventional Commit message.
