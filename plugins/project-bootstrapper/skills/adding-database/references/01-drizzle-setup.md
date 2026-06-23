# 01 - Drizzle Setup

> **Node ≥ 24 compatibility:** The `drizzle-kit` shell shim (`pnpm drizzle-kit` / `npx drizzle-kit`) does not work correctly on Node 24+ due to ESM/CJS resolution changes. Always invoke the CJS binary directly: `node --env-file=.env ./node_modules/drizzle-kit/bin.cjs <command>`. The `02-postgres-setup.md` and `02-cloudflare-d1.md` target references provide the correct script forms — the generic forms below are for reference only.

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
pnpm add -D drizzle-kit@latest tsx@latest
```

3. Add database scripts to `package.json`. The scripts depend on the deployment target:

**Cloudflare target:**

```json
{
  "scripts": {
    "db:generate": "node --env-file=.env --import=tsx ./node_modules/drizzle-kit/bin.cjs generate --config=drizzle.config.ts",
    "db:migrate": "node --env-file=.env --import=tsx ./node_modules/drizzle-kit/bin.cjs migrate --config=drizzle.config.ts",
    "db:local:migrate": "wrangler d1 migrations apply --local APP_DB"
  }
}
```

**Docker/Postgres target** — `drizzle.config.ts` handles connection, so the scripts are simpler. The `02-postgres-setup.md` step replaces these with the correct versions; skip this sub-step for Docker/Postgres.

4. Add `drizzle.config.ts` to the `include` array in `tsconfig.node.json`.

5. The `drizzle.config.ts` file is created in the target-specific step (step 3 of the main workflow). Skip this step here.

## Expected Results

- `drizzle-orm`, `drizzle-zod`, `drizzle-kit`, and `tsx` are installed.
- `drizzle.config.ts` is included in `tsconfig.node.json`.
