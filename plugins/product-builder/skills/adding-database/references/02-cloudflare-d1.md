# 02 - Cloudflare D1

## Steps

1. Confirm Wrangler authentication and get the Cloudflare account ID.

```sh
pnpm wrangler whoami
```

Use the account ID from this output for `CLOUDFLARE_ACCOUNT_ID` in `.env`.

2. Ensure `.env.example` documents the Cloudflare credentials.

```text
CLOUDFLARE_ACCOUNT_ID=<your-account-id>
CLOUDFLARE_DATABASE_ID=<your-database-id>
CLOUDFLARE_D1_TOKEN=<your-d1-token>
```

3. Create `.env` from the example if it is missing.

```sh
cp .env.example .env
```

4. Create the Cloudflare D1 database when it does not already exist.

Prefer the user's requested database name. If none is supplied, derive a lowercase snake-case name from the project and suffix `_db`.

```sh
pnpm wrangler d1 create <database_name> --binding=APP_DB --update-config
```

Example:

```sh
pnpm wrangler d1 create example_product_db --binding=APP_DB --update-config
```

The command updates `wrangler.jsonc` and prints the database configuration. Use the printed `database_id` for `CLOUDFLARE_DATABASE_ID` in `.env`.

Example output:

```json
{
  "d1_databases": [
    {
      "binding": "APP_DB",
      "database_name": "example_product_db",
      "database_id": "eb3252ea-7e4e-4771-a474-27802be86b8d"
    }
  ]
}
```

5. Configure `.env`.

Populate `.env` with the account ID from `pnpm wrangler whoami`, the database ID from `pnpm wrangler d1 create`, and the user's D1 API token.

| Variable | Description |
| --- | --- |
| `CLOUDFLARE_ACCOUNT_ID` | Cloudflare account ID from `pnpm wrangler whoami` |
| `CLOUDFLARE_DATABASE_ID` | D1 database ID from `pnpm wrangler d1 create` |
| `CLOUDFLARE_D1_TOKEN` | API token with D1 read/write access. Create one at Cloudflare dashboard > My Profile > API Tokens > Create Token, using a custom token with Account / D1 / Edit permission. |

6. Add migration settings to the generated D1 binding in `wrangler.jsonc`.

Do not replace the generated binding, database name, or database ID. Only add `migrations_table` and `migrations_dir`.

```jsonc
{
  "d1_databases": [
    {
      "binding": "APP_DB",
      "database_name": "<database_name>",
      "database_id": "<database_id>",
      "migrations_table": "__migrations__",
      "migrations_dir": "db/migrations",
    },
  ],
}
```

## Expected Results

- A D1 database exists in Cloudflare.
- `.env.example` documents required Cloudflare credentials.
- `.env` contains the account ID from `pnpm wrangler whoami`, the database ID from `pnpm wrangler d1 create`, and the user's D1 token.
- `wrangler.jsonc` binds D1 as `APP_DB` and points migrations to `db/migrations`.
