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

3. Create `tsconfig.json` for shared strict compiler settings and project references.

```json
{
  "files": [],
  "references": [
    { "path": "./tsconfig.node.json" },
    { "path": "./tsconfig.cloudflare.json" }
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

5. Create `tsconfig.cloudflare.json` for Cloudflare Worker/client runtime settings.

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
- `tsconfig.json` exists with strict shared compiler settings and references to the Node and Cloudflare configs.
- `tsconfig.node.json` exists with Node, Vite, and tooling compiler settings.
- `tsconfig.cloudflare.json` exists with React Router, Cloudflare Worker, Vite client, and app source includes.
- `package.json` includes `"typecheck": "tsc --build"`.
