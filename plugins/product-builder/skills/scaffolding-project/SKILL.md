---
name: scaffolding-project
description: Scaffolds a prepared local repository into a pnpm TypeScript, Vite, Cloudflare, React Router, Tailwind, and shadcn/ui project. Use after preparing-repositories has returned LOCAL_REPOSITORY_PATH and REPOSITORY_STATUS, when the user asks to initialize, scaffold, or bootstrap the basic Product Builder codebase.
---

# Scaffolding Project

Installs and wires the full Product Builder base stack — pnpm, TypeScript, Vite, Cloudflare Workers, React Router v7, Tailwind, shadcn/ui, and Vitest — into an empty cloned repository, and seeds the initial `docs/` documentation.

## Context

**Guards** — stop before bootstrapping if either field is missing from `docs/context.json`:

- `context.repository.local_path` must be present
- `docs/prd.md` must exist

```text
I need docs/context.json to contain repository.local_path and docs/prd.md to exist before I can bootstrap the Product Builder project.
```

Use `context.repository.local_path` as the working directory.

## Rules

- Use `pnpm` for all package operations. Never use npm or yarn.
- Do not trust remembered package versions — check with `pnpm view <package> version` before installing, then install with `@latest`.
- Load `react-router-patterns` before generating any React Router code.
- Read [worker-architecture.md](../../shared/references/worker-architecture.md) before creating `workers/app.ts`. All binding initialization, auth setup, and `RouterContextProvider` wiring must be inline in `fetch` — no helper files under `workers/`.
- Stop before bootstrapping if `LOCAL_REPOSITORY_PATH` already contains files other than repository metadata.
- Never delete or overwrite user files to force a bootstrap.
- Never create a local-only app in `work/`, a temporary directory, or any agent-chosen folder.
- Keep "Cloudflare" spelled correctly in all generated files and output.
- Re-run `pnpm wrangler types` after any change to `wrangler.jsonc` bindings — the generated `Env` interface goes stale otherwise.
- `cloudflareDevProxy()` must come before `reactRouter()` in the Vite plugins array — wrong order serves raw source in dev.
- shadcn/ui `init` modifies `tailwind.config.ts` and `app/styles/globals.css` — check the diff after running it if those files were already customized.
- `app/root.tsx` must export both a default component and a `Layout` — missing either causes a blank page with no browser console error.

## Workflow

1. Read `docs/context.json`. Confirm guards pass (`repository.local_path` present, `docs/prd.md` exists). Derive `PROJECT_PATH` from `context.repository.local_path`.
2. Validate `context.repository.local_path` exists, is a git repository, and contains no pre-existing files other than repository metadata. Stop with a file list if pre-existing files are found.
3. Initialize pnpm and base files using [01-initialize-pnpm-and-base-files.md](references/01-initialize-pnpm-and-base-files.md).
4. Add TypeScript using [02-typescript.md](references/02-typescript.md).
5. Add Vite, linting, and formatting using [03-vite-linting-formatting.md](references/03-vite-linting-formatting.md).
6. Add Cloudflare using [04-cloudflare.md](references/04-cloudflare.md).
7. Load `react-router-patterns`, then add the React Router page using [05-react-router-page.md](references/05-react-router-page.md).
8. Add Tailwind and shadcn/ui using [06-tailwind-and-shadcn-ui.md](references/06-tailwind-and-shadcn-ui.md).
9. Set up Vitest using [07-vitest-setup.md](references/07-vitest-setup.md).
10. Run final verification using [08-final-verification.md](references/08-final-verification.md).
11. Create initial project documentation:
    - `docs/architecture.md` from [architecture-template.md](../../shared/templates/architecture-template.md): fill Overview with the product description; Stack lists only the base stack; Structure reflects the bootstrapped layout; add a single Routes convention link.
    - `docs/conventions/routes.md` from [convention-template.md](../../shared/templates/convention-template.md): seed with — route filenames describe role not URL syntax; middleware only for cross-cutting request work; keep mutations in actions; ownership checks in the route/action that owns the resource param.
12. Update `README.md` with a basic overview: stack, local dev command, verification commands, Cloudflare deployment target.
13. Update `AGENTS.md` with agent instructions, bootstrapped project structure, a Project Documentation section referencing `docs/architecture.md`, and React Router guidance.
14. Write `project.*` to `docs/context.json`:
    ```json
    {
      "project": {
        "name": "<repo name derived from local_path>",
        "worker_name": "<worker name from wrangler.jsonc>",
        "cloudflare_account_id": "<account ID from wrangler whoami>"
      }
    }
    ```
15. Run `pnpm format`, `pnpm typecheck`, `pnpm lint`, `pnpm test`, and `pnpm build`. Fix any failures before committing.
16. Commit using the repository's Conventional Commits format. Summarize what was created and include the commit hash.

## References

- **pnpm and base files**: [references/01-initialize-pnpm-and-base-files.md](references/01-initialize-pnpm-and-base-files.md)
- **TypeScript**: [references/02-typescript.md](references/02-typescript.md)
- **Vite, linting, formatting**: [references/03-vite-linting-formatting.md](references/03-vite-linting-formatting.md)
- **Cloudflare**: [references/04-cloudflare.md](references/04-cloudflare.md)
- **React Router page**: [references/05-react-router-page.md](references/05-react-router-page.md)
- **Tailwind and shadcn/ui**: [references/06-tailwind-and-shadcn-ui.md](references/06-tailwind-and-shadcn-ui.md)
- **Vitest**: [references/07-vitest-setup.md](references/07-vitest-setup.md)
- **Final verification**: [references/08-final-verification.md](references/08-final-verification.md)
- **Worker architecture**: [worker-architecture.md](../../shared/references/worker-architecture.md)

## Review Checklist

- [ ] `docs/context.json` guards passed (`repository.local_path` present, `docs/prd.md` exists).
- [ ] Local repository had no pre-existing files beyond repository metadata.
- [ ] `pnpm view` used for all package version checks.
- [ ] `react-router-patterns` loaded before React Router code was generated.
- [ ] `pnpm wrangler types` run after `wrangler.jsonc` bindings were set.
- [ ] Vitest installed; `vitest.config.ts`, `tests/unit/vitest.config.ts`, and `tsconfig.unit.json` exist.
- [ ] `docs/architecture.md` created with base stack, structure, and Routes convention link.
- [ ] `docs/conventions/routes.md` created with seed React Router patterns.
- [ ] `README.md` and `AGENTS.md` updated with stack, commands, and Project Documentation section.
- [ ] `pnpm format`, `pnpm typecheck`, `pnpm lint`, `pnpm test`, and `pnpm build` pass.
- [ ] `docs/context.json` updated with `project.*`.
- [ ] Changes committed with Conventional Commit message.
