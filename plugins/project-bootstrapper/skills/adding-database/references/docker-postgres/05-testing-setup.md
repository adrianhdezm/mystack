# 05 - Integration Testing Setup (docker-postgres target)

Sets up Vitest integration tests that run against a real Postgres instance managed by Testcontainers. Each test file gets its own container — no shared state between suites, no external Docker Compose setup required.

## Steps

1. Add `@vitejs/plugin-react` for the integration test environment if not already installed:

```sh
pnpm view @vitejs/plugin-react version
pnpm add -D @vitejs/plugin-react@latest
```

2. Remove `vite-tsconfig-paths` if previously installed — Vite 6+ supports tsconfig path resolution natively via `resolve.tsconfigPaths: true`.

3. Install Testcontainers and the PostgreSQL module. Testcontainers pulls in `ssh2` and `cpu-features` which run native build scripts — add them to `pnpm-workspace.yaml` before installing to avoid a blocked-build error.

Add to `pnpm-workspace.yaml`:

```yaml
allowBuilds:
  cpu-features: true
  esbuild: true
  protobufjs: true
  ssh2: true
```

Then install:

```sh
pnpm view testcontainers version
pnpm view @testcontainers/postgresql version
pnpm add -D testcontainers@latest @testcontainers/postgresql@latest
```

4. Create `tests/integration/vitest.config.ts` — standard Vitest node runner. Use `resolve.tsconfigPaths: true` instead of the `vite-tsconfig-paths` plugin.

```ts
import { defineConfig } from "vitest/config";

export default defineConfig({
  resolve: {
    tsconfigPaths: true,
  },
  test: {
    name: "integration",
    environment: "node",
    include: ["**/*.test.ts"],
  },
});
```

5. Create `tests/integration/db-test-utils.ts`. Each test file calls `setupTestDb()` in `beforeAll` and `teardownTestDb()` in `afterAll` — every suite gets its own container and migrated database.

```ts
import {
  PostgreSqlContainer,
  type StartedPostgreSqlContainer,
} from "@testcontainers/postgresql";
import { drizzle, type NodePgDatabase } from "drizzle-orm/node-postgres";
import { migrate } from "drizzle-orm/node-postgres/migrator";
import { Pool } from "pg";

import { schema } from "~/db/schema";

export interface TestDb {
  db: NodePgDatabase<typeof schema>;
  teardown: () => Promise<void>;
}

export async function setupTestDb(): Promise<TestDb> {
  const container: StartedPostgreSqlContainer = await new PostgreSqlContainer(
    "postgres:17-alpine",
  ).start();
  const pool = new Pool({ connectionString: container.getConnectionUri() });
  const migrationDb = drizzle(pool);
  await migrate(migrationDb, { migrationsFolder: "db/migrations" });
  const db = drizzle(pool, { schema }) as NodePgDatabase<typeof schema>;

  return {
    db,
    teardown: async () => {
      await pool.end();
      await container.stop();
    },
  };
}
```

6. Update the root `vitest.config.ts` to include the integration project.

```ts
import { defineConfig } from "vitest/config";

export default defineConfig({
  test: {
    projects: ["tests/unit", "tests/integration"],
  },
});
```

7. Update `package.json` with integration test scripts.

```json
{
  "scripts": {
    "test:unit": "vitest run --project unit",
    "test:integration": "vitest run --project integration"
  }
}
```

8. Update `tsconfig.integration.json` (or create if missing) to extend `tsconfig.app.json` and include integration tests. Do not add an explicit `types` array — let TypeScript use automatic type discovery.

The `include` array **replaces** (does not merge with) the parent's `include`. Always re-list `app/**/*` so test utilities that import from `~/db/schema`, `~/context`, etc. can resolve types.

```json
{
  "extends": "./tsconfig.app.json",
  "include": [".react-router/types/**/*", "app/**/*", "tests/integration/**/*"],
  "compilerOptions": {
    "noEmit": true
  }
}
```

## Test conventions

Each test file owns its full container lifecycle:

```ts
import { afterAll, beforeAll } from "vitest";
import { setupTestDb, type TestDb } from "../db-test-utils";

let testDb: TestDb;

beforeAll(async () => {
  testDb = await setupTestDb();
});

afterAll(async () => {
  await testDb.teardown();
});
```

- Use `testDb.db` inside tests — it is a fully migrated Drizzle client.
- Each test must clean up its own rows in `afterEach` — insert by a known test-scoped identifier and delete by it after the test.
- Do not rely on container isolation as a substitute for cleanup — isolation is between suites, not between tests within a suite.

## Expected Results

- `testcontainers` and `@testcontainers/postgresql` are installed as development dependencies.
- `pnpm-workspace.yaml` approves `cpu-features`, `protobufjs`, and `ssh2` builds.
- `tests/integration/vitest.config.ts` exists with the node environment using `resolve.tsconfigPaths: true` (no `vite-tsconfig-paths` plugin).
- `tests/integration/db-test-utils.ts` exports `setupTestDb()` returning `{ db, teardown }`.
- Root `vitest.config.ts` includes both `tests/unit` and `tests/integration` projects.
- `tsconfig.integration.json` extends `tsconfig.app.json`, includes `.react-router/types/**/*`, `app/**/*`, and `tests/integration/**/*`, and has no explicit `types` override.
- Running `pnpm test:integration` passes without any external Docker Compose setup.
