# 04 - Migrations And Validation

## Steps

1. Generate migrations from `app/db/schema.ts`.

```sh
pnpm db:generate
```

2. Apply migrations to the remote D1 database.

```sh
pnpm db:migrate
```

3. Apply migrations to the local D1 database.

```sh
pnpm db:local:migrate
```

4. Regenerate Cloudflare types after adding the D1 binding.

```sh
pnpm cf-typegen
```

If the project does not have `cf-typegen`, run:

```sh
pnpm wrangler types
```

5. Run the project's normal verification commands when present.

```sh
pnpm format
pnpm typecheck
pnpm lint
pnpm build
```

## Failure Handling

- If `pnpm db:migrate` fails because `.env` is missing credentials, stop after
  confirming `.env.example` is correct and tell the user which variables are
  missing.
- If `pnpm db:local:migrate` fails because migrations have not been generated,
  run `pnpm db:generate` first.
- If Cloudflare type generation fails because Wrangler is not authenticated,
  report the exact command that failed and leave source changes in place.

## Expected Results

- SQL migration files exist under `db/migrations`.
- Remote migrations apply with `pnpm db:migrate` when Cloudflare credentials are
  present.
- Local migrations apply with `pnpm db:local:migrate`.
- Generated `Env` types include `APP_DB`.
