# 05 - Integration Testing Setup (docker-postgres target)

Sets up Vitest integration tests that run against a real Docker Compose Postgres instance using standard Vitest node runner.

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

3. Create `tests/integration/vitest.config.ts` — standard Vitest node runner, connects to Docker Postgres.

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

4. Create `tests/integration/db-test-utils.ts`.

```ts
import { drizzle } from 'drizzle-orm/node-postgres';
import { migrate } from 'drizzle-orm/node-postgres/migrator';
import { Pool } from 'pg';

import * as schema from '~/db/schema';

const connectionString = process.env.DATABASE_URL!;

export function getTestDb() {
  const pool = new Pool({ connectionString, max: 1 });
  return drizzle(pool, { schema });
}

export async function applyMigrations() {
  const pool = new Pool({ connectionString, max: 1 });
  const db = drizzle(pool);
  await migrate(db, { migrationsFolder: 'db/migrations' });
  await pool.end();
}
```

5. Create `tests/integration/setup-tests.ts`.

```ts
import { beforeAll } from 'vitest';
import { applyMigrations } from './db-test-utils';

beforeAll(applyMigrations);
```

6. Update the root `vitest.config.ts` to include the integration project.

```ts
import { defineConfig } from 'vitest/config';

export default defineConfig({
  test: {
    projects: ['tests/unit', 'tests/integration'],
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

8. Update `tsconfig.integration.json` (or create if missing) to extend `tsconfig.app.json` and include integration tests. Do not add an explicit `types` array — let TypeScript use automatic type discovery so `vite-tsconfig-paths` and other tooling types resolve correctly.

```json
{
  "extends": "./tsconfig.app.json",
  "include": [".react-router/types/**/*", "tests/integration/**/*"],
  "compilerOptions": {
    "noEmit": true
  }
}
```

## Expected Results

- `tests/integration/vitest.config.ts` exists with the node environment and `setup-tests.ts` registered.
- `tests/integration/db-test-utils.ts` exports `getTestDb()` and `applyMigrations()`.
- `tests/integration/setup-tests.ts` calls `applyMigrations()` in `beforeAll`.
- Root `vitest.config.ts` includes both `tests/unit` and `tests/integration` projects.
- `tsconfig.integration.json` extends `tsconfig.app.json`, includes `.react-router/types/**/*` and `tests/integration/**/*`, and has no explicit `types` override.
- Running `pnpm test:integration` with Docker Compose running passes.
