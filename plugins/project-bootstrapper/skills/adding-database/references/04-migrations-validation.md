# 04 - Migrations and Validation

## Steps

1. Generate migrations from `app/db/schema.ts`.

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

For Docker/Postgres, Docker Compose must be running before applying migrations. If not already running:

```sh
docker compose up -d
```

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
pnpm test
pnpm build
```

## Failure Handling

- If `pnpm db:migrate` fails because `.env` is missing credentials, stop after confirming `.env.example` is correct and tell the user which variables are missing.
- If `pnpm db:local:migrate` fails because migrations have not been generated, run `pnpm db:generate` first.
- If Cloudflare type generation fails because Wrangler is not authenticated, report the exact command that failed and leave source changes in place.
- If `pnpm db:migrate` fails for Docker/Postgres because the database does not exist, ensure Docker Compose is running and the init script created the project database.

## Expected Results

- SQL migration files exist under `db/migrations`.
- **Cloudflare:** Remote migrations apply with `pnpm db:migrate`; local migrations apply with `pnpm db:local:migrate`; generated `Env` types include `APP_DB`.
- **Docker/Postgres:** Migrations apply with `pnpm db:migrate` against the running Docker Compose Postgres instance.
