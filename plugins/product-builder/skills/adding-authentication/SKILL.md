---
name: adding-authentication
description: Adds Better Auth email-and-password authentication to an existing Product Builder Cloudflare Workers, React Router, Drizzle D1, TypeScript, Tailwind, and shadcn/ui project. Use when the user asks to add login, signup/register, logout, auth routes, session handling, Better Auth, or authentication-backed protected routes to a Product Builder project.
---

# Adding Authentication

## Required inputs

Work in the target Product Builder project repository. If the project path is
unclear, ask only for the path before changing files.

Require an existing Product Builder-style project that already has D1 and
Drizzle configured. If D1 is missing, run the `adding-database` skill first.

Derive these values from the project or user prompt when possible:

```text
PROJECT_PATH: <absolute path>
D1_BINDING: APP_DB
AUTH_COOKIE_PREFIX: App
```

## Hard rules

- Use `pnpm` for package installation and project commands.
- Install `better-auth`, `zod`, `@conform-to/react`, and `@conform-to/zod`.
- Generate `AUTH_SECRET` with `openssl rand -base64 32` and write it to
  `.env` as `AUTH_SECRET=<generated-value>`.
- Do not commit real `.env` secret values. Update `.env.example` with an
  `AUTH_SECRET=` placeholder.
- Use Better Auth with the Drizzle adapter, SQLite provider, and the existing
  D1 `APP_DB` binding.
- Keep auth tables in `app/db/schema.ts` with Better Auth-compatible table
  aliases in the adapter options.
- Generate the auth migration, then migrate both local and remote D1.
- Keep auth endpoints under `app/routes/auth.tsx` at route path `api/auth/*`.
- Add login, signup/register, and logout routes using React Router actions and
  loaders.
- Preserve existing route, Worker, context, shadcn/ui, and Tailwind patterns.

## Workflow

1. Verify the target project is a Product Builder Cloudflare Workers, React
   Router, TypeScript, pnpm, D1, and Drizzle project.
2. Install dependencies and configure secrets using
   [01-dependencies-and-env.md](references/01-dependencies-and-env.md).
3. Replace or extend the Drizzle schema with the required auth tables using
   [02-auth-schema-and-migrations.md](references/02-auth-schema-and-migrations.md).
4. Wire Better Auth into React Router context and the Worker using
   [03-server-integration.md](references/03-server-integration.md).
5. Add `api/auth/*`, `login`, `logout`, and `signup` routes using
   [04-auth-routes-and-forms.md](references/04-auth-routes-and-forms.md).
6. Update `README.md` and `AGENTS.md` with auth setup, required environment
   variables, local development notes, and migration commands.
7. Run formatting, typecheck, lint, build, and available migration commands.
8. Commit the generated and updated files using the repository's Conventional
   Commits format.

## Validation checklist

- [ ] `better-auth`, `zod`, `@conform-to/react`, and `@conform-to/zod` are installed.
- [ ] `.env` contains `AUTH_SECRET=<secret generated with openssl rand -base64 32>`.
- [ ] `.env.example` documents `AUTH_SECRET=`.
- [ ] Remote Cloudflare secret setup is documented or completed with `pnpm wrangler secret put AUTH_SECRET`.
- [ ] `app/db/schema.ts` exports `users`, `sessions`, `accounts`, `verifications`, their relations, and `schema`.
- [ ] A new Drizzle migration exists under `db/migrations`.
- [ ] Local and remote D1 migrations were applied, or failures are explained.
- [ ] `app/context.ts` exposes `auth: ReturnType<typeof betterAuth>`.
- [ ] `workers/app.ts` constructs Better Auth with `drizzleAdapter`.
- [ ] `app/routes.ts` includes `api/auth/*`, `login`, `logout`, and `signup`.
- [ ] Route loaders and actions access auth with `context.get(appContext)`.
- [ ] `app/routes/auth.tsx` delegates loader and action to `auth.handler(request)`.
- [ ] Login and signup use Conform, Zod, Better Auth API errors, and safe redirects.
- [ ] Logout signs out through `auth.api.signOut`.
- [ ] `pnpm format`, `pnpm typecheck`, `pnpm lint`, and `pnpm build` pass after fixes.
- [ ] Generated and updated files were committed with a Conventional Commit message.
