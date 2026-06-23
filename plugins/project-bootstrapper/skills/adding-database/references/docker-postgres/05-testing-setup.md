# 05 - Integration Testing Setup (docker-postgres target)

Sets up Vitest integration tests that run against a real Postgres instance managed by Testcontainers. A single container starts before the test suite and stops after — no external Docker Compose setup required.

## Steps

1. Add `@vitejs/plugin-react` for the integration test environment if not already installed:

```sh
pnpm view @vitejs/plugin-react version
pnpm add -D @vitejs/plugin-react@latest
```

2. Install `vite-tsconfig-paths` if not already present. If the package appears in the lockfile but isn't found by TypeScript after install, run `pnpm install` again — pnpm occasionally skips symlinking on the first install.

```sh
pnpm add -D vite-tsconfig-paths@latest
```

3. Install Testcontainers and the PostgreSQL module.

```sh
pnpm view testcontainers version
pnpm view @testcontainers/postgresql version
pnpm add -D testcontainers@latest @testcontainers/postgresql@latest
```

4. Create `tests/integration/vitest.config.ts` — standard Vitest node runner.

```ts
import { defineConfig } from 'vitest/config';
import tsconfigPaths from 'vite-tsconfig-paths';

export default defineConfig({
  plugins: [tsconfigPaths()],
  test: {
    name: 'integration',
    environment: 'node',
    include: ['**/*.test.ts'],
    setupFiles: ['./setup-tests.ts'],
  },
});
```

5. Create `tests/integration/db-test-utils.ts`. The container starts once, migrations run once against it, and the connection string is exposed for test files to use.

```ts
import { PostgreSqlContainer, type StartedPostgreSqlContainer } from '@testcontainers/postgresql';
import { drizzle, type NodePgDatabase } from 'drizzle-orm/node-postgres';
import { migrate } from 'drizzle-orm/node-postgres/migrator';
import { Pool } from 'pg';

import { schema } from '~/db/schema';

let container: StartedPostgreSqlContainer;
let pool: Pool;
let _db: NodePgDatabase<typeof schema>;

export async function startTestDb() {
  container = await new PostgreSqlContainer('postgres:16-alpine').start();
  pool = new Pool({ connectionString: container.getConnectionUri() });
  const migrationDb = drizzle(pool);
  await migrate(migrationDb, { migrationsFolder: 'db/migrations' });
  _db = drizzle(pool, { schema }) as NodePgDatabase<typeof schema>;
}

export async function stopTestDb() {
  await pool.end();
  await container.stop();
}

export function getTestDb(): NodePgDatabase<typeof schema> {
  return _db;
}
```

6. Create `tests/integration/setup-tests.ts`. The container is shared across all tests in the run. Each test is responsible for cleaning up the data it creates.

```ts
import { afterAll, beforeAll } from 'vitest';
import { startTestDb, stopTestDb } from './db-test-utils';

beforeAll(startTestDb);
afterAll(stopTestDb);
```

7. Update the root `vitest.config.ts` to include the integration project.

```ts
import { defineConfig } from 'vitest/config';

export default defineConfig({
  test: {
    projects: ['tests/unit', 'tests/integration'],
  },
});
```

8. Update `package.json` with integration test scripts.

```json
{
  "scripts": {
    "test:unit": "vitest run --project unit",
    "test:integration": "vitest run --project integration"
  }
}
```

9. Update `tsconfig.integration.json` (or create if missing) to extend `tsconfig.app.json` and include integration tests. Do not add an explicit `types` array — let TypeScript use automatic type discovery so `vite-tsconfig-paths` and other tooling types resolve correctly.

```json
{
  "extends": "./tsconfig.app.json",
  "include": [".react-router/types/**/*", "tests/integration/**/*"],
  "compilerOptions": {
    "noEmit": true
  }
}
```

## Test conventions

- Call `getTestDb()` inside tests to get the shared Drizzle client.
- Each test must clean up its own data — use `afterEach` to delete rows inserted during the test, or wrap writes in a pattern that deletes by a known test-scoped identifier.
- Do not truncate tables in `afterAll` — other test files in the same run share the container.

## Expected Results

- `testcontainers` and `@testcontainers/postgresql` are installed as development dependencies.
- `tests/integration/vitest.config.ts` exists with the node environment and `setup-tests.ts` registered.
- `tests/integration/db-test-utils.ts` exports `startTestDb()`, `stopTestDb()`, and `getTestDb()`.
- `tests/integration/setup-tests.ts` calls `startTestDb()` in `beforeAll` and `stopTestDb()` in `afterAll`.
- Root `vitest.config.ts` includes both `tests/unit` and `tests/integration` projects.
- `tsconfig.integration.json` extends `tsconfig.app.json`, includes `.react-router/types/**/*` and `tests/integration/**/*`, and has no explicit `types` override.
- Running `pnpm test:integration` passes without any external Docker Compose setup.
