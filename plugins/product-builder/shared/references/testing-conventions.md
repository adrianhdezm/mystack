# Testing Conventions

## Directory Structure

All tests live under a top-level `tests/` directory, split by type. The `tests/unit/` tree mirrors the `app/` structure for routes, components, and utilities. The `tests/integration/` tree mirrors the `app/` structure for database and service code.

```text
tests/
  unit/
    lib/
      utils.test.ts
    routes/
      home.test.tsx
      login.test.tsx
  integration/
    setup.ts
    env.d.ts
    db/daos/
      user.dao.test.ts
    db/queries/
      order-line-items.query.test.ts
    services/
      order.service.test.ts
```

Unit tests import source via the `~/` path alias (e.g., `import Home from '~/routes/home'`).

## Test Type Inference

Test type is determined by directory. All test files use `.test.ts` or `.test.tsx` — no type suffix in the filename.

| Location | Test Type | Runner | What It Tests |
| --- | --- | --- | --- |
| `tests/integration/db/daos/**` | Integration | Miniflare D1 | DAO CRUD operations against a real database |
| `tests/integration/db/queries/**` | Integration | Miniflare D1 | Cross-table reads with seeded data |
| `tests/integration/services/**` | Integration | Miniflare D1 | Business workflows and atomic write boundaries |
| `tests/unit/lib/**` | Unit | Playwright browser | Pure functions, utilities, transforms |
| `tests/unit/components/**` | Unit | Playwright browser | React component render, interaction, assertion |
| `tests/unit/routes/**` | Unit | Playwright browser | Route component behavior with stubbed loaders/actions |

## Vitest Configuration

A root `vitest.config.ts` uses Vitest's [projects](https://vitest.dev/guide/projects.html) feature to combine project configs. Each project has its own `vitest.config.ts` inside its directory.

```ts
// vitest.config.ts
import { defineConfig } from "vitest/config";

export default defineConfig({
  test: {
    projects: ["tests/unit", "tests/integration"],
  },
});
```

| Config | Environment | Include |
| --- | --- | --- |
| `tests/unit/vitest.config.ts` | Playwright browser (chromium) | `**/*.test.ts`, `**/*.test.tsx` |
| `tests/integration/vitest.config.ts` | `@cloudflare/vitest-pool-workers` | `**/*.test.ts` |

Each config's `include` patterns are relative to its own directory. The integration config resolves paths to the project root (for `wrangler.jsonc` and `db/migrations/`) using `import.meta.url`.

A single `pnpm test` runs both projects. Individual projects can be run with `--project`:

```bash
pnpm test                     # runs all projects
pnpm test:unit                # vitest run --project unit
pnpm test:integration         # vitest run --project integration
```

The unit config uses Playwright browser mode — a real browser instead of jsdom. Pure-function unit tests run fine in chromium alongside component tests. No setup file needed — `vitest-browser-react` handles cleanup automatically.

The root `vitest.config.ts` is separate from `vite.config.ts` because the app's `vite.config.ts` loads the `cloudflare()` Vite plugin, which sets `resolve.external` on its Worker environments. Vitest rejects that option at startup with an incompatibility error.

### Vitest Configuration Progression

Projects start with a root `vitest.config.ts` and `tests/unit/vitest.config.ts` at bootstrap time. When `adding-database` runs, it adds `tests/integration/vitest.config.ts` and updates the root config to include both projects.

## TypeScript Configuration

Two standalone test tsconfigs — one per test type:

```text
tsconfig.unit.json            # extends cloudflare, includes tests/unit/**/*
tsconfig.integration.json     # extends cloudflare, includes tests/integration/**/*
```

`tsconfig.unit.json` extends `tsconfig.cloudflare.json` and adds `tests/unit/**/*` to its include. No extra types needed — unit tests run in a browser and only import app code via `~/`.

`tsconfig.integration.json` extends `tsconfig.cloudflare.json` and adds `tests/integration/**/*`. It carries the Cloudflare vitest types:

```json
{
  "types": [
    "vite/client",
    "node",
    "@cloudflare/vitest-pool-workers",
    "@cloudflare/vitest-pool-workers/types"
  ]
}
```

`tsconfig.cloudflare.json` has only `"types": ["vite/client"]` — Cloudflare vitest types are scoped to integration tests.

Both test tsconfigs are non-composite with `noEmit: true`. TypeScript composite project references don't work well with `~/*` path aliases that point across project boundaries — the `app/` files resolve via the path alias into the cloudflare project's source, which composite mode rejects unless those files are explicitly listed in the test project too.

The typecheck script runs all three:

```bash
tsc -b && tsc -p tsconfig.unit.json && tsc -p tsconfig.integration.json
```

## Dependencies

Unit and component tests use:

| Package                      | Role                                    |
| ---------------------------- | --------------------------------------- |
| `vitest-browser-react`       | Component rendering with auto-cleanup   |
| `@vitest/browser-playwright` | Playwright browser provider for vitest  |
| `@vitejs/plugin-react`       | React transform for vitest browser mode |

Integration tests use:

| Package                           | Role                      |
| --------------------------------- | ------------------------- |
| `@cloudflare/vitest-pool-workers` | Miniflare D1 test runtime |

## Integration Test Database Helper

After `adding-database`, integration tests use `getTestDb` and `applyMigrations` from `tests/integration/setup.ts`.

Migrations are read from `db/migrations/` at config time using Drizzle's `readMigrationFiles()`, then passed into the Miniflare worker as a JSON text binding. The Miniflare worker has a virtual filesystem that doesn't include project files, so `migrate()` from `drizzle-orm/d1/migrator` can't read migration files at runtime. The split — read in Node.js config, apply in the worker — works around this.

```ts
// tests/integration/setup.ts
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

Uses `D1.prepare().run()` instead of `D1.exec()` because `exec()` fails on multi-line statements in Miniflare. Migration tracking is skipped since the test database is ephemeral.

A separate `tests/integration/setup-tests.ts` setup file calls `applyMigrations()` in a `beforeAll` hook. The integration vitest config references it via `setupFiles`, so individual tests don't need to call `applyMigrations()` themselves — migrations are applied automatically before each test file runs.

```ts
// tests/integration/setup-tests.ts
import { beforeAll } from "vitest";

import { applyMigrations } from "./setup";

beforeAll(applyMigrations);
```

The `MIGRATIONS` binding is typed via a `Cloudflare.Env` augmentation in `tests/integration/env.d.ts`, keeping it scoped to test code.

After a schema update, run `pnpm db:generate` as usual. The new migration SQL file lands in `db/migrations/`, and `readMigrationFiles()` picks it up automatically on the next test run. No manual edits to test setup code.

## Component Test Patterns

### Rendering route components

Use `createRoutesStub` with `loader()` stubs — data flows through the router the same way it does in production:

```tsx
import { createRoutesStub } from "react-router";
import { render } from "vitest-browser-react";

function renderHome(loaderData) {
  const Stub = createRoutesStub([
    {
      path: "/",
      Component: Home,
      loader: () => loaderData,
    },
  ]);
  return render(<Stub initialEntries={["/"]} />);
}
```

For testing action errors with Conform forms, stub the `action` and simulate a real form submission. The action must return a Conform `SubmissionResult` shape — `initialValue` must be present or Conform silently ignores the result:

```tsx
function renderLoginWithAction(actionFn: () => unknown) {
  const Stub = createRoutesStub([
    {
      path: "/login",
      Component: Login,
      action: actionFn,
    },
  ]);
  return render(<Stub initialEntries={["/login"]} />);
}

it("shows form-level error from action", async () => {
  await renderLoginWithAction(() => ({
    status: "error",
    initialValue: { email: "test@example.com", password: "wrongpassword" },
    error: { "": ["Incorrect username or password"] },
  }));

  await page.getByLabelText("Email").fill("test@example.com");
  await page.getByLabelText("Password").fill("wrongpassword");
  await page.getByRole("button", { name: /Log in/ }).click();

  await expect.element(page.getByRole("alert")).toBeInTheDocument();
});
```

The `error` key `''` (empty string) represents form-level errors in Conform's `SubmissionResult` type — field-level errors use the field name as key.

For forms where required inputs cannot be filled programmatically (e.g., `type="file"`), use `hydrationData` to pre-populate `actionData` without form submission:

```tsx
render(
  <Stub
    initialEntries={["/upload"]}
    hydrationData={{ actionData: { upload: { error: "message" } } }}
  />,
);
```

### Querying elements

Use `page` from `vitest/browser` — Playwright locators, strict by default (throws on multiple matches):

```tsx
page.getByText("Welcome");
page.getByLabelText("Password", { exact: true }); // disambiguate "Password" from "Confirm Password"
page.getByRole("button", { name: /Upload/ }).first(); // pick one when multiple exist
page.getByPlaceholder("e.g., La Trattoria"); // no "Text" suffix
page.getByRole("alert"); // use negative assertion instead of null check
```

### Assertions

Use async `expect.element()` with auto-retry — waits for the DOM to settle:

```tsx
await expect.element(page.getByText("Welcome")).toBeInTheDocument();
await expect.element(page.getByRole("alert")).not.toBeInTheDocument();
await expect
  .element(page.getByText("Sign up"))
  .toHaveAttribute("href", expect.stringContaining("redirect"));
```

All test functions must be `async`.

### Cleanup

Automatic — `vitest-browser-react` handles cleanup between tests. No setup file needed.

## What to Test at Each Layer

### DAOs

Test each standard CRUD method: `create`, `get`, `getAll`, `update`, `delete`, `deleteMany`. Test `getAll` with filter combinations that represent business rules. Do not test Drizzle internals — test that the DAO contract returns the expected data shapes.

### Queries

Seed data using DAOs (not raw SQL), then test `get()` and `getAll()`. Verify that composite types include nested relations. Test `getAll()` with filters and verify items array and total count.

### Services

Test each business workflow method end-to-end. Assert state via DAOs after service calls — do not inspect service internals. Test error states that are surfaced as thrown errors. Focus on the happy path and meaningful edge cases.

### Route Components

Test loader data rendering, action error display, form interactions, and navigation links. Use `createRoutesStub` with loader/action stubs. For Conform forms, stub the action to return `SubmissionResult` shapes with `initialValue` present. For forms with inputs that cannot be filled programmatically (e.g., `type="file"`), use `hydrationData` to pre-populate `actionData`.

## Gitignore

The `.gitignore` entry for `node_modules/` must use `node_modules/` (any depth), not `/node_modules/` (root-only). Vitest browser mode creates a `node_modules/.vite` cache directory inside `tests/unit/` at runtime — the leading-slash pattern doesn't cover it.

## Project Documentation

After `adding-database` sets up integration testing, create `docs/conventions/testing.md` in the target project using the convention template. Seed it with the directory structure, test type inference table, `applyMigrations`/`getTestDb` import patterns, component test patterns, and layer-specific testing guidance from this reference.
