# 02 - TypeScript

## Contents

- Steps (package installation, tsconfig, source files)
- Expected Results

## Steps

1. Check the latest package versions.

```sh
pnpm view typescript version
pnpm view @types/node version
```

2. Install TypeScript and Node types as development dependencies.

```sh
pnpm add -D typescript@latest @types/node@latest
```

3. Create `tsconfig.json` for shared strict compiler settings and project references. The second reference depends on the deployment target:
   - `cloudflare` → `tsconfig.cloudflare.json`
   - `docker-postgres` → `tsconfig.app.json`

The `tsconfig.unit.json` reference is added in step 5 of `07-vitest-setup.md` once that file exists. For docker-postgres, `tsconfig.integration.json` is added later in `adding-database/05-testing-setup.md`.

```json
{
  "files": [],
  "references": [
    { "path": "./tsconfig.node.json" },
    { "path": "./tsconfig.<cloudflare|app>.json" }
  ],
  "compilerOptions": {
    "checkJs": true,
    "verbatimModuleSyntax": true,
    "skipLibCheck": true,
    "strict": true,
    "noEmit": true,
    "paths": {
      "~/*": ["./app/*"]
    }
  }
}
```

4. Create `tsconfig.node.json` for Vite, tooling, and Node scripts.

```json
{
  "extends": "./tsconfig.json",
  "include": ["vite.config.ts"],
  "compilerOptions": {
    "composite": true,
    "strict": true,
    "types": ["node"],
    "lib": ["ES2022"],
    "target": "ES2022",
    "module": "ES2022",
    "moduleResolution": "bundler"
  }
}
```

5. Create the app runtime tsconfig. The name and includes differ by target:

**Cloudflare target** — create `tsconfig.cloudflare.json`:

```json
{
  "extends": "./tsconfig.json",
  "include": [
    ".react-router/types/**/*",
    "app/**/*",
    "app/**/.server/**/*",
    "app/**/.client/**/*",
    "workers/**/*",
    "worker-configuration.d.ts"
  ],
  "compilerOptions": {
    "composite": true,
    "strict": true,
    "lib": ["DOM", "DOM.Iterable", "ES2022"],
    "types": ["vite/client"],
    "target": "ES2022",
    "module": "ES2022",
    "moduleResolution": "bundler",
    "jsx": "react-jsx",
    "rootDirs": [".", "./.react-router/types"],
    "paths": {
      "~/*": ["./app/*"]
    },
    "esModuleInterop": true,
    "resolveJsonModule": true
  }
}
```

**Docker/Postgres target** — create `tsconfig.app.json`:

```json
{
  "extends": "./tsconfig.json",
  "include": [
    ".react-router/types/**/*",
    "app/**/*",
    "app/**/.server/**/*",
    "app/**/.client/**/*",
    "workers/**/*",
    "server.ts"
  ],
  "exclude": ["build/**/*", "node_modules"],
  "compilerOptions": {
    "composite": true,
    "strict": true,
    "lib": ["DOM", "DOM.Iterable", "ES2022"],
    "types": ["vite/client", "node"],
    "target": "ES2022",
    "module": "ES2022",
    "moduleResolution": "bundler",
    "jsx": "react-jsx",
    "rootDirs": [".", "./.react-router/types"],
    "paths": {
      "~/*": ["./app/*"]
    },
    "esModuleInterop": true,
    "resolveJsonModule": true
  }
}
```

6. Add the `typecheck` script to `package.json`.

```json
{
  "scripts": {
    "typecheck": "tsc --build"
  }
}
```

## Expected Results

- `typescript` and `@types/node` are installed as development dependencies.
- `tsconfig.json` exists with strict shared compiler settings and references to the Node and app-runtime configs.
- `tsconfig.node.json` exists with Node, Vite, and tooling compiler settings.
- `tsconfig.cloudflare.json` (Cloudflare) or `tsconfig.app.json` (Docker/Postgres) exists with React Router, app source, and target-specific includes.
- `tsconfig.app.json` (Docker/Postgres) includes `"exclude": ["build/**/*", "node_modules"]` so compiled output is never type-checked.
- `package.json` includes `"typecheck": "tsc --build"`.
