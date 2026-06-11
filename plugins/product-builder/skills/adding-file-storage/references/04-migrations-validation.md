# 04 - Migrations And Validation

## Steps

1. Generate a migration for the new `files` table.

```sh
pnpm db:generate
```

2. Apply migrations to the remote D1 database when credentials are present.

```sh
pnpm db:migrate
```

3. Apply migrations to the local D1 database.

```sh
pnpm db:local:migrate
```

4. Re-run Cloudflare type generation to ensure `Env` types are current after all
   binding and migration changes.

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

- If the project has no Drizzle/D1 setup, stop and run the `adding-database`
  skill first.
- If `pnpm db:migrate` fails because `.env` is missing credentials, confirm
  `.env.example` is correct and tell the user which variables are missing.
- If `pnpm wrangler r2 bucket create` fails because the bucket already exists,
  keep the existing bucket and manually add or verify the `APP_FILES` binding.
- If Cloudflare type generation fails because Wrangler is not authenticated,
  report the exact command that failed and leave source changes in place.

## Expected Results

- SQL migration files exist under `db/migrations`.
- Remote and local D1 migrations apply when credentials are available.
- Generated `Env` types include `APP_FILES`.
- Project verification commands pass or failures are explained.
