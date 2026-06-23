# 08 - Final Verification

## Contents

- Steps (dependency install, formatting, typecheck, lint, test, build, file review)
- Expected Results

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

5. Run tests.

```sh
pnpm test
```

If any test fails, fix the generated source or configuration errors and rerun `pnpm test` until it passes.

6. Run the production build.

```sh
pnpm build
```

If the build fails, fix the generated source or configuration errors and rerun `pnpm build` until it passes.

6a. _(Docker/Postgres target only)_ Verify the dev server starts without errors. Docker Compose must be running and `.env` must exist before this step.

```sh
docker compose up -d --wait
node --env-file=.env server.ts &
SERVER_PID=$!
sleep 5
kill $SERVER_PID 2>/dev/null
wait $SERVER_PID 2>/dev/null
```

If the server process exits within 5 seconds (non-zero exit), investigate the error output before continuing.

7. Display the final project file structure, excluding dependency and generated output folders.

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
./app/components/ui/card.tsx
./app/components/ui/input.tsx
./app/components/ui/label.tsx
./app/context.ts
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
./tests
./tests/unit
./tests/unit/lib
./tests/unit/lib/utils.test.ts
./tests/unit/vitest.config.ts
./tsconfig.json
./tsconfig.node.json
./tsconfig.unit.json
./vitest.config.ts
./vite.config.ts
./worker-configuration.d.ts
./workers
./workers/app.ts
./wrangler.jsonc
```

8. Review git status.

```sh
git status --short
```

## Expected Results

- `pnpm install` succeeds and runs `postinstall`, including `wrangler types`.
- `pnpm format` completes, and any formatting changes are kept.
- `pnpm typecheck` passes after any generated TypeScript or Cloudflare type issues are fixed.
- `pnpm lint` passes after any generated lint issues are fixed.
- `pnpm test` passes with the smoke test in `tests/unit/lib/`.
- `pnpm build` passes.
- The final file structure is displayed in the summary.
- `git status --short` is reviewed so the summary can list the created and modified files.

Report any command that still fails after attempted fixes with the exact command and the relevant error summary.
