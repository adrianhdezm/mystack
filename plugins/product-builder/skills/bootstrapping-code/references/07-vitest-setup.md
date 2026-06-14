# 07 - Vitest Setup

## Contents

- Steps (install Vitest, create config, add scripts, smoke test)
- Expected Results

## Steps

1. Check the latest Vitest package version and install it.

```sh
pnpm view vitest version
pnpm add -D vitest@latest
```

2. Create `vitest.config.ts` with this content. Use a standalone config — do not import from `vite.config.ts` to avoid conflicts with the Cloudflare Vite plugin.

```ts
import { defineConfig } from "vitest/config";

export default defineConfig({
  resolve: {
    tsconfigPaths: true,
  },
  test: {
    include: ["app/**/*.test.{ts,tsx}"],
  },
});
```

3. Add test scripts to `package.json`.

```json
{
  "scripts": {
    "test": "vitest run",
    "test:watch": "vitest",
    "test:ui": "vitest --ui"
  }
}
```

4. Add `vitest.config.ts` to the `include` array in `tsconfig.node.json`. This mirrors the pattern used for other tooling configs like `drizzle.config.ts`.

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

5. Create `app/lib/__tests__/utils.test.ts` with a smoke test that validates the path alias and Vitest setup.

```ts
import { describe, expect, it } from "vitest";

import { cn } from "~/lib/utils";

describe("cn", () => {
  it("merges class names", () => {
    expect(cn("a", "b")).toBe("a b");
  });

  it("handles conditional classes", () => {
    expect(cn("a", false && "b", "c")).toBe("a c");
  });
});
```

6. Run the tests to confirm the setup works.

```sh
pnpm test
```

If any test fails, fix the configuration and rerun until it passes.

## Expected Results

- `vitest` is installed as a development dependency.
- `vitest.config.ts` exists at the project root with `tsconfigPaths` enabled and test includes set to `app/**/*.test.{ts,tsx}`.
- `package.json` includes `test`, `test:watch`, and `test:ui` scripts.
- `tsconfig.node.json` includes `vitest.config.ts`.
- `app/lib/__tests__/utils.test.ts` exists and passes.
- `pnpm test` completes successfully.
