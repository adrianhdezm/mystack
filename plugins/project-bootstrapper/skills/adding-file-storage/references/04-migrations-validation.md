# 04 - Migrations and Validation

## Steps

1. Generate a migration for the new `files` table.

```sh
pnpm db:generate
```

2. Apply migrations. The commands differ by deployment target:

**Cloudflare target:**

```sh
pnpm db:migrate        # remote D1
pnpm db:local:migrate  # local D1
```

**Docker/Postgres target:**

```sh
pnpm db:migrate
```

For Docker/Postgres, Docker Compose must be running before applying migrations.

3. Regenerate types (Cloudflare target only).

```sh
pnpm cf-typegen
```

If the project does not have `cf-typegen`, run:

```sh
pnpm wrangler types
```

4. Run the project's normal verification commands.

```sh
pnpm format
pnpm typecheck
pnpm lint
pnpm build
```

## Failure Handling

- If the project has no database setup, stop and run the `adding-database` skill first.
- If `pnpm db:migrate` fails because `.env` is missing credentials, confirm `.env.example` is correct and tell the user which variables are missing.
- If `pnpm wrangler r2 bucket create` fails because the bucket already exists, keep the existing bucket and manually add or verify the `APP_FILES` binding in `wrangler.jsonc`.
- If Cloudflare type generation fails because Wrangler is not authenticated, report the exact command that failed and leave source changes in place.
- If `pnpm db:migrate` fails for Docker/Postgres because the database does not exist, ensure Docker Compose is running and the init script created the project database.

## Expected Results

- SQL migration files exist under `db/migrations`.
- **Cloudflare:** Remote and local D1 migrations apply; generated `Env` types include `APP_FILES`.
- **Docker/Postgres:** Migration applies against the running Docker Compose Postgres instance.
- Project verification commands pass or failures are explained.
