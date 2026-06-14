# Testing Conventions

## Directory-Based Test Type Inference

Test type is determined by what the source file does, inferred from its location in the project. All test files use `.test.ts` or `.test.tsx` — no type suffix in the filename.

| Source Path | Test Type | Runner | What It Tests |
| --- | --- | --- | --- |
| `app/db/daos/**` | Integration | Miniflare D1 | DAO CRUD operations against a real database |
| `app/db/queries/**` | Integration | Miniflare D1 | Cross-table reads with seeded data |
| `app/services/**` | Integration | Miniflare D1 | Business workflows and atomic write boundaries |
| `app/lib/**` | Unit | Node / Vite | Pure functions, utilities, transforms |
| `app/components/**` | Component | Playwright browser | React component render, interaction, assertion |
| `app/routes/**` | Component | Playwright browser | Route component behavior |

## File Placement

Place tests in a `__tests__/` subdirectory next to the source file:

```text
app/db/daos/
  user.dao.ts
  __tests__/
    user.dao.test.ts

app/db/queries/
  order-line-items.query.ts
  __tests__/
    order-line-items.query.test.ts

app/services/
  order.service.ts
  __tests__/
    order.service.test.ts

app/lib/
  utils.ts
  __tests__/
    utils.test.ts
```

Test file name mirrors the source file: `user.dao.ts` → `user.dao.test.ts`.

## Vitest Configuration Progression

Projects start with a single `vitest.config.ts` for unit tests at bootstrap time. When `adding-database` runs, it upgrades the config to `defineWorkersConfig` from `@cloudflare/vitest-pool-workers` for integration tests against Miniflare D1.

When component tests are introduced later, add a Vitest workspace:

```text
vitest.workspace.ts           — registers both configs
vitest.config.ts              — Workers pool (integration tests)
vitest.browser.config.ts      — Playwright browser pool (component tests)
```

The workspace globs separate test environments by path:

```ts
// vitest.workspace.ts
export default [
  {
    test: {
      name: "integration",
      include: ["app/db/**/*.test.ts", "app/services/**/*.test.ts"],
    },
  },
  {
    test: {
      name: "unit",
      include: ["app/lib/**/*.test.ts"],
    },
  },
  {
    test: {
      name: "components",
      include: ["app/components/**/*.test.tsx", "app/routes/**/*.test.tsx"],
      browser: { enabled: true },
    },
  },
];
```

## Test Database Helper

After `adding-database`, integration tests use `getTestDb` from `app/db/__tests__/setup.ts`:

```ts
import { env } from "cloudflare:test";
import { drizzle } from "drizzle-orm/d1";
import * as schema from "../schema";

export function getTestDb() {
  return drizzle(env.APP_DB, { schema });
}
```

`cloudflare:test` is a virtual module provided by `@cloudflare/vitest-pool-workers` — it is only available inside the Workers test pool. Migrations are applied automatically via the `wrangler.jsonc` config.

## What to Test at Each Layer

### DAOs

Test each standard CRUD method: `create`, `get`, `getAll`, `update`, `delete`, `deleteMany`. Test `getAll` with filter combinations that represent business rules. Do not test Drizzle internals — test that the DAO contract returns the expected data shapes.

### Queries

Seed data using DAOs (not raw SQL), then test `get()` and `getAll()`. Verify that composite types include nested relations. Test `getAll()` with filters and verify items array and total count.

### Services

Test each business workflow method end-to-end. Assert state via DAOs after service calls — do not inspect service internals. Test error states that are surfaced as thrown errors. Focus on the happy path and meaningful edge cases.

## Project Documentation

After `adding-database` sets up integration testing, create `docs/conventions/testing.md` in the target project using the convention template. Seed it with the directory-based type inference table, the `__tests__/` co-location rule, the `getTestDb` import pattern, and the layer-specific testing guidance from this reference.
