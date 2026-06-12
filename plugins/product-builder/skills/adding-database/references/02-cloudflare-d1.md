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

Populate `.env` with the account ID from `pnpm wrangler whoami`, the database ID from `pnpm wrangler d1 create`, and the D1 API token.

Retrieve the D1 API token from the macOS Keychain:

```sh
security find-generic-password -s CLOUDFLARE_D1_TOKEN -w
```

If the command succeeds, use the returned value for `CLOUDFLARE_D1_TOKEN` in `.env`. If it fails (token not stored or not on macOS), ask the user to provide the token.

| Variable | Source |
| --- | --- |
| `CLOUDFLARE_ACCOUNT_ID` | `pnpm wrangler whoami` |
| `CLOUDFLARE_DATABASE_ID` | `pnpm wrangler d1 create` |
| `CLOUDFLARE_D1_TOKEN` | macOS Keychain (`security find-generic-password -s CLOUDFLARE_D1_TOKEN -w`), or ask the user |

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
- `.env` contains the account ID from `pnpm wrangler whoami`, the database ID from `pnpm wrangler d1 create`, and the D1 token from the macOS Keychain or the user.
- `wrangler.jsonc` binds D1 as `APP_DB` and points migrations to `db/migrations`.
