---
name: scaffolding-project
description: Scaffolds a prepared local repository into a full-stack project. Dispatches to the correct reference set based on deployment_target in docs/context.json. Use after selecting-capabilities, when the user asks to initialize, scaffold, or bootstrap the project.
---

# Scaffolding Project

Installs and wires the full base stack — pnpm, TypeScript, Vite, React Router v7, Tailwind, shadcn/ui, and Vitest — into an empty cloned repository. Installs deployment-target infrastructure (Cloudflare Workers or Docker/Postgres server), and seeds the initial `docs/` documentation.

## Context

**Guards** — stop before bootstrapping if any of these fields are missing from `docs/context.json`:

- `repository.local_path` — working directory for all operations
- `project.deployment_target` — determines which infrastructure references to follow

```text
Stop — docs/context.json is missing repository.local_path or project.deployment_target.
Run preparing-repositories then selecting-capabilities first.
```

Use `context.repository.local_path` as the working directory for all commands.

## Rules

- Use `pnpm` for all package operations. Never use npm or yarn.
- Do not trust remembered package versions — check with `pnpm view <package> version` before installing, then install with `@latest`.
- Load `react-router-patterns` before generating any React Router code.
- Stop before bootstrapping if the repository already contains files other than repository metadata.
- Never delete or overwrite user files to force a bootstrap.
- Never create a local-only app in `work/`, a temporary directory, or any agent-chosen folder.
- `app/root.tsx` must export both a default component and a `Layout` — missing either causes a blank page with no browser console error.
- shadcn/ui `init` modifies `tailwind.config.ts` and `app/styles/globals.css` — check the diff after running it if those files were already customized.

**Cloudflare target only:**
- Read [worker-architecture.md](../../shared/references/worker-architecture.md) before creating `workers/app.ts`. All binding initialization, auth setup, and `RouterContextProvider` wiring must be inline in `fetch` — no helper files under `workers/`.
- Re-run `pnpm wrangler types` after any change to `wrangler.jsonc` bindings — the generated `Env` interface goes stale otherwise.
- `cloudflareDevProxy()` must come before `reactRouter()` in the Vite plugins array — wrong order serves raw source in dev.
- Keep "Cloudflare" spelled correctly in all generated files and output.

## Workflow

1. Read `docs/context.json`. Confirm guards pass. Derive `PROJECT_PATH` from `repository.local_path` and `DEPLOYMENT_TARGET` from `project.deployment_target`.
2. Validate the repository exists, is a git repo, and contains no pre-existing files beyond repository metadata. Stop with a file list if pre-existing files are found.
3. Initialize pnpm and base files using [references/01-initialize-pnpm-and-base-files.md](references/01-initialize-pnpm-and-base-files.md).
4. Add TypeScript using [references/02-typescript.md](references/02-typescript.md).
5. Add Vite, linting, and formatting using [references/03-vite-linting-formatting.md](references/03-vite-linting-formatting.md).
6. **Dispatch on deployment target:**
   - `cloudflare` → Add Cloudflare runtime using [references/cloudflare/04-cloudflare.md](references/cloudflare/04-cloudflare.md)
   - `docker-postgres` → Add Docker/Postgres server using [references/docker-postgres/04-docker-server.md](references/docker-postgres/04-docker-server.md)
7. Load `react-router-patterns`, then add the React Router page using the target-specific reference:
   - `cloudflare` → [references/05-react-router-page.md](references/05-react-router-page.md)
   - `docker-postgres` → [references/docker-postgres/05-react-router-page.md](references/docker-postgres/05-react-router-page.md)
8. Add Tailwind and shadcn/ui using [references/06-tailwind-and-shadcn-ui.md](references/06-tailwind-and-shadcn-ui.md).
9. Set up Vitest using [references/07-vitest-setup.md](references/07-vitest-setup.md).
10. Run final verification using [references/08-final-verification.md](references/08-final-verification.md).
11. Create initial project documentation:
    - `docs/architecture.md` from [architecture-template.md](../../shared/templates/architecture-template.md): fill Overview with the product idea from `project.idea`; Stack lists only the base stack and deployment target; Structure reflects the bootstrapped layout; add a single Routes convention link.
    - `docs/conventions/routes.md` from [convention-template.md](../../shared/templates/convention-template.md): seed with — route filenames describe role not URL syntax; middleware only for cross-cutting request work; keep mutations in actions; ownership checks in the route/action that owns the resource param.
12. Update `README.md` with a basic overview: stack, deployment target, local dev command, verification commands.
13. Update `AGENTS.md` with agent instructions, bootstrapped project structure, a Project Documentation section referencing `docs/architecture.md`, and React Router guidance.
14. Write `project.*` to `docs/context.json` (preserve all existing fields, only add/overwrite these):
    - **Cloudflare:**
      ```json
      { "project": { "name": "<repo name>", "worker_name": "<name from wrangler.jsonc>", "cloudflare_account_id": "<from wrangler whoami>" } }
      ```
    - **Docker/Postgres:**
      ```json
      { "project": { "name": "<repo name>" } }
      ```
15. Run `pnpm format`, `pnpm typecheck`, `pnpm lint`, `pnpm test`, and `pnpm build`. Fix any failures before proceeding.

## References

**Shared (both targets):**
- [references/01-initialize-pnpm-and-base-files.md](references/01-initialize-pnpm-and-base-files.md)
- [references/02-typescript.md](references/02-typescript.md)
- [references/03-vite-linting-formatting.md](references/03-vite-linting-formatting.md)
- [references/06-tailwind-and-shadcn-ui.md](references/06-tailwind-and-shadcn-ui.md)
- [references/07-vitest-setup.md](references/07-vitest-setup.md)
- [references/08-final-verification.md](references/08-final-verification.md)

**Cloudflare target:**
- [references/cloudflare/04-cloudflare.md](references/cloudflare/04-cloudflare.md)
- [references/05-react-router-page.md](references/05-react-router-page.md)
- [shared/references/worker-architecture.md](../../shared/references/worker-architecture.md)

**Docker/Postgres target:**
- [references/docker-postgres/04-docker-server.md](references/docker-postgres/04-docker-server.md)
- [references/docker-postgres/05-react-router-page.md](references/docker-postgres/05-react-router-page.md)

## Review Checklist

- [ ] Guards passed — `repository.local_path` and `project.deployment_target` set in `docs/context.json`.
- [ ] Repository had no pre-existing files beyond repository metadata.
- [ ] `pnpm view` used for all package version checks.
- [ ] `react-router-patterns` loaded before React Router code was generated.
- [ ] Target-specific infrastructure step executed (Cloudflare or Docker/Postgres).
- [ ] Cloudflare only: `pnpm wrangler types` run after `wrangler.jsonc` bindings set.
- [ ] Vitest installed; `vitest.config.ts`, `tests/unit/vitest.config.ts`, and `tsconfig.unit.json` exist.
- [ ] `docs/architecture.md` created with base stack, deployment target, structure, and Routes convention link.
- [ ] `docs/conventions/routes.md` created with seed React Router patterns.
- [ ] `README.md` and `AGENTS.md` updated with stack, commands, and Project Documentation section.
- [ ] `pnpm format`, `pnpm typecheck`, `pnpm lint`, `pnpm test`, and `pnpm build` pass.
- [ ] `docs/context.json` updated with `project.*` fields.
