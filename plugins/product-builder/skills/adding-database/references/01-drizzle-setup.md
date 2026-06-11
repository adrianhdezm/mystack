# 01 - Drizzle Setup

## Steps

1. Check the latest Drizzle package versions before installing.

```sh
pnpm view drizzle-orm version
pnpm view drizzle-kit version
pnpm view drizzle-zod version
```

2. Install Drizzle packages.

```sh
pnpm add drizzle-orm@latest
pnpm add drizzle-zod@latest
pnpm add -D drizzle-kit@latest
```

3. Add database scripts to `package.json`.

```json
{
  "scripts": {
    "db:migrate": "node --env-file=.env --import=tsx ./node_modules/drizzle-kit/bin.cjs migrate --config=drizzle.config.ts",
    "db:generate": "node --env-file=.env --import=tsx ./node_modules/drizzle-kit/bin.cjs generate --config=drizzle.config.ts",
    "db:local:migrate": "wrangler d1 migrations apply --local APP_DB"
  }
}
```

4. Create `drizzle.config.ts`.

```ts
import type { Config } from "drizzle-kit";

function requiredEnv(name: string): string {
  const value = process.env[name];

  if (!value) {
    throw new Error(`Missing environment variable: ${name}`);
  }

  return value;
}

export default {
  out: "./db/migrations",
  schema: "./app/db/schema.ts",
  dialect: "sqlite",
  driver: "d1-http",
  dbCredentials: {
    accountId: requiredEnv("CLOUDFLARE_ACCOUNT_ID"),
    databaseId: requiredEnv("CLOUDFLARE_DATABASE_ID"),
    token: requiredEnv("CLOUDFLARE_D1_TOKEN"),
  },
  migrations: {
    prefix: "timestamp",
    table: "__migrations__",
  },
} satisfies Config;
```

## Expected Results

- `drizzle-orm`, `drizzle-zod`, and `drizzle-kit` are installed.
- `package.json` has D1 migration and generation scripts.
- `drizzle.config.ts` uses `.env` credentials and writes migrations to `db/migrations`.
