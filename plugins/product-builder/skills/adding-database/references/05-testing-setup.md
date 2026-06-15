# 05 - Integration Testing Setup

## Contents

- Steps (install Workers test pool, create integration config, create test helper, create migration setup file, create env types, create tsconfig, update root config, update scripts, example test)
- Expected Results

## Steps

1. Check the latest package version and install the Cloudflare Workers Vitest pool.

```sh
pnpm view @cloudflare/vitest-pool-workers version
pnpm add -D @cloudflare/vitest-pool-workers@latest
```

2. Create `tests/integration/vitest.config.ts` with the Workers pool. This config resolves paths to the project root for `wrangler.jsonc` and `db/migrations/` using `import.meta.url`. Migrations are read at config time using Drizzle's `readMigrationFiles()` and passed into the Miniflare worker as a JSON text binding, because the Miniflare worker has a virtual filesystem that doesn't include project files.

```ts
import path from "node:path";
import { fileURLToPath } from "node:url";
import { defineWorkersConfig } from "@cloudflare/vitest-pool-workers/config";
import { readMigrationFiles } from "drizzle-orm/migrator";

const root = path.resolve(
  path.dirname(fileURLToPath(import.meta.url)),
  "../..",
);

const migrations = readMigrationFiles({
  migrationsFolder: path.join(root, "db/migrations"),
});

export default defineWorkersConfig({
  resolve: {
    tsconfigPaths: true,
  },
  test: {
    name: "integration",
    include: ["**/*.test.ts"],
    setupFiles: ["./setup-tests.ts"],
    poolOptions: {
      workers: {
        wrangler: { configPath: path.join(root, "wrangler.jsonc") },
        miniflare: {
          d1Databases: ["APP_DB"],
          bindings: {
            MIGRATIONS: JSON.stringify(migrations),
          },
        },
      },
    },
  },
});
```

Preserve `resolve: { tsconfigPaths: true }` — the `~/` path alias used in test imports depends on it.

3. Create `tests/integration/setup.ts` — the shared test helper for integration tests.

```ts
import { env } from "cloudflare:workers";
import { drizzle } from "drizzle-orm/d1";

import * as schema from "~/db/schema";

export function getTestDb() {
  return drizzle(env.APP_DB, { schema });
}

export async function applyMigrations() {
  const migrations: Array<{ sql: string[] }> = JSON.parse(env.MIGRATIONS);
  for (const migration of migrations) {
    for (const stmt of migration.sql) {
      await env.APP_DB.prepare(stmt).run();
    }
  }
}
```

`cloudflare:workers` is a virtual module provided by `@cloudflare/vitest-pool-workers`. It is only available inside the Workers test pool and must not be imported in application code.

Uses `D1.prepare().run()` instead of `D1.exec()` because `exec()` fails on multi-line statements in Miniflare. Migration tracking is skipped since the test database is ephemeral.

4. Create `tests/integration/setup-tests.ts` — a setup file that applies migrations before each test file. Referenced by the integration vitest config's `setupFiles`, so individual tests don't need to call `applyMigrations()` themselves. This runs inside the Miniflare worker context.

```ts
import { beforeAll } from "vitest";

import { applyMigrations } from "./setup";

beforeAll(applyMigrations);
```

5. Create `tests/integration/env.d.ts` — a type augmentation for the `MIGRATIONS` text binding, scoped to test code.

```ts
declare module "cloudflare:workers" {
  interface Cloudflare {
    Env: {
      APP_DB: D1Database;
      MIGRATIONS: string;
    };
  }
}
```

6. Create `tsconfig.integration.json` at the project root — a non-composite tsconfig for integration tests that extends the app's cloudflare config with Cloudflare vitest types.

```json
{
  "extends": "./tsconfig.cloudflare.json",
  "compilerOptions": {
    "composite": false,
    "noEmit": true,
    "types": [
      "vite/client",
      "node",
      "@cloudflare/vitest-pool-workers",
      "@cloudflare/vitest-pool-workers/types"
    ]
  },
  "include": ["tests/integration/**/*"]
}
```

7. Clean up `tsconfig.cloudflare.json` — remove Cloudflare vitest types so they are scoped to integration tests only. The `types` array should have only `"vite/client"`:

```json
{
  "types": ["vite/client"]
}
```

8. Update the root `vitest.config.ts` to add the integration project.

```ts
import { defineConfig } from "vitest/config";

export default defineConfig({
  test: {
    projects: ["tests/unit", "tests/integration"],
  },
});
```

9. Update npm scripts in `package.json`.

```json
{
  "scripts": {
    "test": "vitest run",
    "test:unit": "vitest run --project unit",
    "test:integration": "vitest run --project integration",
    "typecheck": "wrangler types && tsc -b && tsc -p tsconfig.unit.json && tsc -p tsconfig.integration.json"
  }
}
```

Add the `test:integration` script and update `typecheck` to include the integration tsconfig pass.

10. If the schema has tables, create an example DAO test to verify the integration. Place it at `tests/integration/db/daos/example.dao.test.ts`.

```ts
import { describe, expect, it } from "vitest";

import { getTestDb } from "../../setup";
// Import the DAO class for the first table in the schema
// import { ExampleDao } from '~/db/daos/example.dao'

describe("Example DAO", () => {
  it("connects to the test database", () => {
    const db = getTestDb();
    expect(db).toBeDefined();
  });
});
```

Replace with real DAO tests when DAOs are added. Remove this example file after the first real DAO test is created.

11. Run the tests to confirm the Workers pool setup works.

```sh
pnpm test
```

If any test fails, check that `wrangler.jsonc` has the D1 binding, that migrations have been generated in `db/migrations/`, and that `readMigrationFiles()` can find them.

## Expected Results

- `@cloudflare/vitest-pool-workers` is installed as a development dependency.
- `tests/integration/vitest.config.ts` uses `defineWorkersConfig` with `wrangler.jsonc`, `APP_DB`, and `MIGRATIONS` binding.
- `tests/integration/setup.ts` exports `getTestDb()` and `applyMigrations()`.
- `tests/integration/setup-tests.ts` calls `applyMigrations()` in a `beforeAll` hook.
- `tests/integration/env.d.ts` augments `Cloudflare.Env` with the `MIGRATIONS` binding.
- `tsconfig.integration.json` exists at the project root with Cloudflare vitest types.
- `tsconfig.cloudflare.json` has only `"types": ["vite/client"]`.
- Root `vitest.config.ts` lists both `tests/unit` and `tests/integration` projects.
- `pnpm test` passes — tests run inside the Miniflare Workers runtime with D1 migrations applied.
