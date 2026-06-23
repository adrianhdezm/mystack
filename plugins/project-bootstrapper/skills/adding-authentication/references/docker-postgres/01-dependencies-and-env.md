# 01 - Dependencies and Environment (docker-postgres target)

## Verify the project

Work from `PROJECT_PATH`. Confirm the project already has:

- `package.json` with `pnpm` scripts.
- `app/db/schema.ts`.
- `drizzle.config.ts`.
- `docker-compose.yml` with a Postgres service.
- `workers/app.ts` — the Hono server entrypoint.

If the database is absent, stop and run the `adding-database` skill first.

## Install packages

Check current package versions when the project's existing skills require latest package resolution. Install the auth and form dependencies:

```sh
pnpm add better-auth zod@4 @conform-to/react @conform-to/zod
```

If the project does not already include the UI components used by the auth forms, add them through the existing shadcn/ui workflow:

```sh
pnpm dlx shadcn@latest add button card input label
```

## Generate AUTH_SECRET

Generate the secret exactly with OpenSSL:

```sh
openssl rand -base64 32
```

Write the generated value to `.env`:

```env
AUTH_SECRET=<generated-secret>
```

Update `.env.example` with a placeholder, not the real value:

```env
AUTH_SECRET=
```

For production Docker deployments, document in the target project's `README.md` that `AUTH_SECRET` must be set as an environment variable in the deployment configuration (Docker Compose environment section, Kubernetes secret, etc.):

```md
### Production deployment

Set `AUTH_SECRET` in your deployment environment configuration. Never commit the real value to the repository.
```
