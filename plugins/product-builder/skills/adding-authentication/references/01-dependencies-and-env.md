# Dependencies and Environment

## Verify the project

Work from `PROJECT_PATH`. Confirm the project already has:

- `package.json` with `pnpm` scripts.
- `app/db/schema.ts`.
- `drizzle.config.ts`.
- `wrangler.jsonc` with a D1 binding, normally `APP_DB`.
- `workers/app.ts` or the existing Worker entrypoint.

If D1 or Drizzle is absent, stop and run the `adding-database` skill first.

## Install packages

Check current package versions when the project's existing skills require latest
package resolution. Install the auth and form dependencies:

```sh
pnpm add better-auth zod@4 @conform-to/react @conform-to/zod
```

If the project does not already include the UI components used by the auth
forms, add them through the existing shadcn/ui workflow:

```sh
pnpm dlx shadcn@latest add button card input label
```

Use the project's existing icon package when available. If no icon package is
present, render plain text validation messages instead of adding a new icon
dependency only for auth forms.

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

For remote Cloudflare deployments, do not set the secret from the agent
workflow. Document this requirement in the target project's `README.md`:

```sh
pnpm wrangler secret put AUTH_SECRET
```

Use wording like:

````md
### Remote Cloudflare deployment

Before deploying to Cloudflare, set `AUTH_SECRET` in the remote Worker
environment from an authenticated Wrangler session:

```sh
pnpm wrangler secret put AUTH_SECRET
```
````

Explain that the application requires this remote secret before Cloudflare
deployments can run successfully.
