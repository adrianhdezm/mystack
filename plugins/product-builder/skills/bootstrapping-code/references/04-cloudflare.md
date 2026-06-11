# 04 - Cloudflare

## Steps

1. Check the latest Cloudflare package versions.

```sh
pnpm view @cloudflare/vite-plugin version
pnpm view wrangler version
```

2. Install the Cloudflare Vite plugin and Wrangler as development dependencies.

```sh
pnpm add -D @cloudflare/vite-plugin@latest wrangler@latest
```

3. Create `wrangler.jsonc`, replacing `<project-name>` with the package/project name.

```jsonc
{
  "$schema": "node_modules/wrangler/config-schema.json",
  "name": "<project-name>-app",
  "compatibility_date": "2026-06-11",
  "compatibility_flags": ["nodejs_compat"],
  "main": "./workers/app.ts",
  "vars": {
    "APP_NAME": "<project-name>",
  },
  "assets": {
    "directory": "./build/client/",
  },
  "observability": {
    "enabled": true,
  },
}
```

Use this fixed `compatibility_date`. Do not replace it with today's date or a
dynamic value. The date pins the Workers runtime behavior to a known-good
baseline so builds stay reproducible. Upgrade the date intentionally when the
project is ready to adopt newer compatibility flags.

4. Create `workers/app.ts` with this content:

```ts
export default {
  async fetch(request) {
    return Response.json({});
  },
} satisfies ExportedHandler<Env>;
```

5. Add Cloudflare type generation scripts to `package.json` and update `typecheck` to generate Wrangler types before TypeScript checks.

```json
{
  "scripts": {
    "cf-typegen": "wrangler types",
    "postinstall": "wrangler types",
    "typecheck": "wrangler types && tsc -b"
  }
}
```

6. Update `vite.config.ts` to import and use the Cloudflare Vite plugin.

```ts
import { cloudflare } from "@cloudflare/vite-plugin";
import { defineConfig } from "vite";

export default defineConfig({
  plugins: [cloudflare({ viteEnvironment: { name: "ssr" } })],
  resolve: {
    tsconfigPaths: true,
  },
});
```

## Expected Results

- `@cloudflare/vite-plugin` and `wrangler` are installed as development dependencies.
- `wrangler.jsonc` exists with the Worker name set to `<project-name>-app`, Worker entry point, assets directory, compatibility settings, vars, and observability enabled.
- `workers/app.ts` exists with a minimal JSON response handler.
- `package.json` includes `"cf-typegen": "wrangler types"`, `"postinstall": "wrangler types"`, and `"typecheck": "wrangler types && tsc -b"`.
- `vite.config.ts` imports `cloudflare` from `@cloudflare/vite-plugin` and uses `cloudflare({ viteEnvironment: { name: "ssr" } })` in the plugin list.
