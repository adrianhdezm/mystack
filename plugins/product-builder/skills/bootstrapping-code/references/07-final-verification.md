# 07 - Final Verification

## Steps

1. Install dependencies and run postinstall scripts.

```sh
pnpm install
```

2. Run formatting.

```sh
pnpm format
```

If formatting changes files, review the changed files before continuing.

3. Run TypeScript checks.

```sh
pnpm typecheck
```

If typecheck fails, fix the generated source or configuration errors and rerun `pnpm typecheck` until it passes.

4. Run linting.

```sh
pnpm lint
```

If linting fails, fix the generated source or configuration errors and rerun `pnpm lint` until it passes.

5. Run the production build.

```sh
pnpm build
```

If the build fails, fix the generated source or configuration errors and rerun `pnpm build` until it passes.

6. Display the final project file structure, excluding dependency and generated output folders.

```sh
find . \
  -path './.git' -prune -o \
  -path './node_modules' -prune -o \
  -path './build' -prune -o \
  -path './.react-router' -prune -o \
  -path './.wrangler' -prune -o \
  -print | sort
```

Compare the output against this expected structure:

```text
.
./.gitignore
./.prettierrc
./AGENTS.md
./README.md
./app
./app/app.css
./app/components
./app/components/ui
./app/components/ui/button.tsx
./app/entry.server.tsx
./app/lib
./app/lib/utils.ts
./app/root.tsx
./app/routes
./app/routes/home.tsx
./app/routes.ts
./components.json
./eslint.config.js
./package.json
./pnpm-lock.yaml
./public
./public/favicon.ico
./react-router.config.ts
./tsconfig.cloudflare.json
./tsconfig.json
./tsconfig.node.json
./vite.config.ts
./worker-configuration.d.ts
./workers
./workers/app.ts
./wrangler.jsonc
```

7. Review git status.

```sh
git status --short
```

## Expected Results

- `pnpm install` succeeds and runs `postinstall`, including `wrangler types`.
- `pnpm format` completes, and any formatting changes are kept.
- `pnpm typecheck` passes after any generated TypeScript or Cloudflare type issues are fixed.
- `pnpm lint` passes after any generated lint issues are fixed.
- `pnpm build` passes.
- The final file structure is displayed in the summary.
- `git status --short` is reviewed so the summary can list the created and modified files.

Report any command that still fails after attempted fixes with the exact command and the relevant error summary.
