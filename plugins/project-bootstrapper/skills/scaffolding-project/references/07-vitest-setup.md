# 07 - Vitest Setup

## Contents

- Steps (install Vitest and browser deps, install Playwright browsers, create configs, create tsconfig, add scripts, update gitignore, smoke test)
- Expected Results

## Steps

1. Check the latest Vitest package versions and install Vitest with browser mode dependencies.

```sh
pnpm view vitest version
pnpm add -D vitest@latest @vitest/browser@latest vitest-browser-react@latest @vitest/browser-playwright@latest @vitejs/plugin-react@latest
```

2. Install Playwright browsers. `@vitest/browser-playwright` requires a local browser binary.

```sh
npx playwright install chromium
```

3. Create the root `vitest.config.ts`. Use a standalone config — do not import from `vite.config.ts` to avoid conflicts with the Cloudflare Vite plugin.

```ts
import { defineConfig } from "vitest/config";

export default defineConfig({
  test: {
    projects: ["tests/unit"],
  },
});
```

4. Create `tests/unit/vitest.config.ts` with Playwright browser mode. Vitest 4.x requires the `playwright()` function from `@vitest/browser-playwright` — the string-based `provider: 'playwright'` API is removed.

```ts
import react from "@vitejs/plugin-react";
import { playwright } from "@vitest/browser-playwright";
import { defineConfig } from "vitest/config";

export default defineConfig({
  plugins: [react()],
  resolve: {
    tsconfigPaths: true,
  },
  test: {
    name: "unit",
    include: ["**/*.test.ts", "**/*.test.tsx"],
    browser: {
      enabled: true,
      provider: playwright(),
      instances: [{ browser: "chromium" }],
    },
  },
});
```

5. Create `tsconfig.unit.json` — extends the app tsconfig for unit tests. The `app` config name differs by target: `tsconfig.cloudflare.json` (Cloudflare) or `tsconfig.app.json` (docker-postgres). Include `.react-router/types/**/*` so the `+future.ts` augmentation (e.g. `v8_middleware`) is in scope for test files that import route components.

TypeScript 5.0+ allows `composite: true` and `noEmit: true` together, so do not set `composite: false` — doing so would prevent this config from participating in project references.

```json
{
  "extends": "./tsconfig.<cloudflare|app>.json",
  "compilerOptions": {
    "noEmit": true
  },
  "include": [".react-router/types/**/*", "app/**/*", "tests/unit/**/*"]
}
```

6. Add `tsconfig.unit.json` to the root `tsconfig.json` references array so `projectService` discovers unit test files automatically without needing entries in `allowDefaultProject`.

```json
{
  "references": [
    { "path": "./tsconfig.node.json" },
    { "path": "./tsconfig.<cloudflare|app>.json" },
    { "path": "./tsconfig.unit.json" }
  ]
}
```

7. Add `vitest.config.ts` to the `include` array in `tsconfig.node.json`. This mirrors the pattern used for other tooling configs like `drizzle.config.ts`.

```jsonc
{
  "include": [
    "vite.config.ts",
    "vitest.config.ts",
    "eslint.config.js",
    "react-router.config.ts",
  ],
}
```

8. Add test scripts to `package.json`. Because `tsconfig.unit.json` is now a project reference, `tsc -b` covers it — no separate `tsc -p tsconfig.unit.json` pass needed.

```json
{
  "scripts": {
    "test": "vitest run",
    "test:unit": "vitest run --project unit",
    "test:watch": "vitest",
    "test:ui": "vitest --ui",
    "typecheck": "tsc -b"
  }
}
```

For the Cloudflare target, prepend `wrangler types &&` before `tsc -b` so generated Worker types are up to date before typechecking.

8. Update `.gitignore` to use `node_modules/` (any depth) instead of `/node_modules/` (root-only). Vitest browser mode creates a `node_modules/.vite` cache directory inside `tests/unit/` at runtime — the leading-slash pattern doesn't cover it.

```gitignore
node_modules/
```

9. Create `tests/unit/lib/utils.test.ts` with a smoke test that validates the path alias and Vitest setup.

```ts
import { describe, expect, it } from "vitest";

import { cn } from "~/lib/utils";

describe("cn", () => {
  it("merges class names", () => {
    expect(cn("a", "b")).toBe("a b");
  });

  it("handles conditional classes", () => {
    const condition = false;
    expect(cn("a", condition && "b", "c")).toBe("a c");
  });
});
```

10. Run the tests to confirm the setup works.

```sh
pnpm test
```

If any test fails, fix the configuration and rerun until it passes.

## Expected Results

- `vitest`, `@vitest/browser`, `vitest-browser-react`, `@vitest/browser-playwright`, and `@vitejs/plugin-react` are installed as development dependencies.
- Playwright chromium browser is installed locally.
- `vitest.config.ts` exists at the project root with `projects: ["tests/unit"]`.
- `tests/unit/vitest.config.ts` exists with Playwright browser mode using `provider: playwright()` (function form, not string).
- `tsconfig.unit.json` exists at the project root extending the app tsconfig, with `.react-router/types/**/*`, `app/**/*`, and `tests/unit/**/*` in its `include` array. No `composite: false`.
- Root `tsconfig.json` references array includes `tsconfig.unit.json` so `projectService` discovers unit tests without `allowDefaultProject` entries.
- `package.json` includes `test`, `test:unit`, `test:watch`, and `test:ui` scripts. The `typecheck` script is `tsc -b` only (no separate `tsc -p tsconfig.unit.json` pass).
- `tsconfig.node.json` includes `vitest.config.ts`.
- `.gitignore` uses `node_modules/` (any depth).
- `tests/unit/lib/utils.test.ts` exists and passes.
- `pnpm test` completes successfully.
