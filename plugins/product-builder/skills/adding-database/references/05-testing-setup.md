# 05 - Integration Testing Setup

## Contents

- Steps (install Workers test pool, upgrade Vitest config, create test helper, example test)
- Expected Results

## Steps

1. Check the latest package version and install the Cloudflare Workers Vitest pool.

```sh
pnpm view @cloudflare/vitest-pool-workers version
pnpm add -D @cloudflare/vitest-pool-workers@latest
```

2. Replace `vitest.config.ts` with a Workers-aware config using `defineWorkersConfig`. This replaces the plain config from bootstrapping — the Workers pool runs tests inside the Miniflare runtime with real D1 bindings.

```ts
import { defineWorkersConfig } from "@cloudflare/vitest-pool-workers/config";

export default defineWorkersConfig({
  resolve: {
    tsconfigPaths: true,
  },
  test: {
    include: ["app/**/*.test.{ts,tsx}"],
    poolOptions: {
      workers: {
        wrangler: { configPath: "./wrangler.jsonc" },
        miniflare: {
          d1Databases: ["APP_DB"],
        },
      },
    },
  },
});
```

Preserve `resolve: { tsconfigPaths: true }` from the bootstrap config — the `~/` path alias used in test imports depends on it.

Migrations are applied automatically because `wrangler.jsonc` declares `migrations_dir` and `migrations_table` in the D1 binding. No manual migration step is needed in tests.

3. Create `app/db/__tests__/setup.ts` — the shared test helper for integration tests.

```ts
import { env } from "cloudflare:test";
import { drizzle } from "drizzle-orm/d1";

import * as schema from "../schema";

export function getTestDb() {
  return drizzle(env.APP_DB, { schema });
}
```

The `cloudflare:test` module is a virtual module provided by `@cloudflare/vitest-pool-workers`. It is only available inside the Workers test pool and must not be imported in application code.

4. If the schema has tables, create an example DAO test to verify the integration. Place it at `app/db/daos/__tests__/example.dao.test.ts`.

```ts
import { describe, expect, it } from "vitest";

import { getTestDb } from "~/db/__tests__/setup";
// Import the DAO class for the first table in the schema
// import { ExampleDao } from '../example.dao'

describe("Example DAO", () => {
  it("connects to the test database", () => {
    const db = getTestDb();
    expect(db).toBeDefined();
  });
});
```

Replace with real DAO tests when DAOs are added. Remove this example file after the first real DAO test is created.

5. Run the tests to confirm the Workers pool setup works.

```sh
pnpm test
```

If any test fails, check that `wrangler.jsonc` has the D1 binding with `migrations_dir` and `migrations_table`, and that migrations have been generated.

## Expected Results

- `@cloudflare/vitest-pool-workers` is installed as a development dependency.
- `vitest.config.ts` uses `defineWorkersConfig` with `wrangler.jsonc` and `APP_DB`.
- `app/db/__tests__/setup.ts` exports `getTestDb()`.
- `pnpm test` passes — tests run inside the Miniflare Workers runtime with D1 migrations applied.
