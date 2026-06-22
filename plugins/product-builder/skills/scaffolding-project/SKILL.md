---
name: scaffolding-project
description: Scaffolds a prepared local repository into a pnpm TypeScript, Vite, Cloudflare, React Router, Tailwind, and shadcn/ui project. Use after preparing-repositories has returned LOCAL_REPOSITORY_PATH and REPOSITORY_STATUS, when the user asks to initialize, scaffold, or bootstrap the basic Product Builder codebase.
---

# Bootstrapping Code

## Required inputs

Read [context-schema.md](../../shared/references/context-schema.md) for the full `docs/context.json` schema, field reference, and guard pattern.

**Guards** — stop before bootstrapping if either field is missing from `docs/context.json`:

- `context.repository.local_path` must be present
- `context.skills.preparing-repositories` must be `"done"`

Set `skills.scaffolding-project` to `in-progress` at the start of the workflow. On successful completion, write the following fields and set the status to `done`.

**Writes:**

```json
{
  "project": {
    "name": "<repo name derived from local_path>",
    "worker_name": "<worker name from wrangler.jsonc>",
    "cloudflare_account_id": "<account ID from wrangler whoami>"
  },
  "skills": {
    "scaffolding-project": "done"
  }
}
```

Use `context.repository.local_path` as the working directory and `context.repository.status` for scaffolding decisions. Do not choose a fallback directory.

## Hard rules

- Use `pnpm` for package initialization, package version checks, and package installation.
- Do not trust remembered package versions. Check latest versions with `pnpm view <package> version` before installing, then install with `@latest`.
- Load `react-router-patterns` before adding or changing React Router code. Any generated React Router code must follow those patterns.
- Stop before bootstrapping if `context.repository.local_path` is missing from `docs/context.json` or `skills.preparing-repositories` is not `"done"`.
- Stop before bootstrapping if the repository or local destination was missing from the user's request and `preparing-repositories` has not resolved it.
- Stop before bootstrapping if `LOCAL_REPOSITORY_PATH` already contains files other than repository metadata.
- After bootstrap starts, treat files created by the bootstrap as project source and reuse or update them in later steps.
- Never delete or overwrite user files to force a bootstrap.
- Never create a local-only Product Builder app in `work/`, `./work`, a temporary directory, the current workspace, or any agent-chosen folder.
- Keep Cloudflare spelled correctly in generated files, package names, and user-facing output.
- Read [worker-architecture.md](../../shared/references/worker-architecture.md) before creating `workers/app.ts`. The worker must follow the single-file pattern: all binding initialization, auth setup, and `RouterContextProvider` wiring inline in `fetch`. Do not extract helpers into separate files under `workers/`.

## Gotchas

- `pnpm wrangler types` must be re-run after any change to `wrangler.jsonc` bindings. Skipping this causes TypeScript errors in `workers/app.ts` because the generated `Env` interface is stale.
- shadcn/ui `init` modifies `tailwind.config.ts` and `app/styles/globals.css`. If these files were already customized, the init may overwrite changes. Check the diff after running it.
- React Router in framework mode requires `app/root.tsx` to export a default component and a `Layout`. Missing either causes a blank page with no error in the browser console.
- Vite config must use `cloudflareDevProxy()` before `reactRouter()` in the plugins array. Wrong order causes the dev server to serve raw source instead of compiled output.

## Workflow

1. Read `docs/context.json`. Confirm `repository.local_path` is present and `skills.preparing-repositories` is `"done"`. Stop if either check fails.
2. Set `skills.scaffolding-project` to `in-progress` in `docs/context.json`.
3. Validate `context.repository.local_path` exists, is a git repository, and contains no pre-existing files other than repository metadata.
4. Initialize pnpm and base files using [01-initialize-pnpm-and-base-files.md](references/01-initialize-pnpm-and-base-files.md).
5. Add TypeScript using [02-typescript.md](references/02-typescript.md).
6. Add Vite, linting, and formatting using [03-vite-linting-formatting.md](references/03-vite-linting-formatting.md).
7. Add Cloudflare using [04-cloudflare.md](references/04-cloudflare.md).
8. Load `react-router-patterns`, then add the React Router page using [05-react-router-page.md](references/05-react-router-page.md).
9. Add Tailwind and shadcn/ui using [06-tailwind-and-shadcn-ui.md](references/06-tailwind-and-shadcn-ui.md).
10. Set up Vitest using [07-vitest-setup.md](references/07-vitest-setup.md).
11. Run final verification using [08-final-verification.md](references/08-final-verification.md).
12. Create initial project documentation in `docs/`:
    - Create `docs/architecture.md` using the template in [architecture-template.md](../../shared/templates/architecture-template.md). Fill in the Overview with the product description. The Stack section should list only the base stack: Cloudflare Workers, TypeScript; React Router v7 (framework mode, SSR); Tailwind CSS, shadcn/ui. The Structure section should reflect the bootstrapped directory layout. Add a single convention link for Routes: `**[Routes](conventions/routes.md)** — loader/action structure, protected routes, navigation`.
    - Create `docs/conventions/routes.md` using the template in [convention-template.md](../../shared/templates/convention-template.md). Seed it with key React Router patterns: route filenames describe role not URL syntax; use middleware only for cross-cutting request work; keep mutations in actions; ownership checks in the route/action that owns the resource param.
13. Update the project `README.md` with a very basic overview of the bootstrapped application, including the stack, local development command, verification commands, and Cloudflare deployment target.
14. Update the project `AGENTS.md` with basic agent instructions and the bootstrapped project structure. Include:
    - Repository purpose, common commands (including `pnpm test`), and where the main application, routes, UI components, Cloudflare worker, and configuration files live.
    - A **Project Documentation** section that directs agents to read `docs/architecture.md` first for project context, then follow links to conventions and data model for detail. List the docs structure:
      - `docs/architecture.md` — stack, structure, conventions index, and implementation log.
      - `docs/conventions/` — project-specific patterns and anti-patterns.
      - `docs/features/` — feature specs (added during planning).
      - `docs/e2e/` — E2E test plans and browser screenshots (added during testing).
    - React Router guidance: route filenames describe role, not URL syntax; use middleware only for cross-cutting request work such as auth, logging, shared context, and headers; keep mutations in actions and ownership checks in the route/action that owns the resource param.
15. Write `project.*` and `skills.scaffolding-project = "done"` to `docs/context.json`.
16. Commit the generated and updated files in the repository using the repository's Conventional Commits format.
17. Summarize what was created, include the commit hash, and list any command that failed.

## Stop message

When stopping because context guards are not satisfied, say this directly:

```text
I need docs/context.json to contain repository.local_path and skills.preparing-repositories = "done" before I can bootstrap the Product Builder project.
```

When stopping because the local repository has pre-existing files, say this directly:

```text
The local repository <path> has pre-existing files, so I stopped before bootstrapping. Remove the existing files or provide a new empty repository.
```

Include the files found when available.

## Validation checklist

- [ ] `docs/context.json` was read and guards passed (`repository.local_path` present, `skills.preparing-repositories = "done"`).
- [ ] `pnpm view` was used for latest package checks.
- [ ] `react-router-patterns` was loaded before React Router code was generated, and the generated code follows those patterns.
- [ ] Cloudflare types are generated with `wrangler types`.
- [ ] `vitest` is installed, root `vitest.config.ts` and `tests/unit/vitest.config.ts` exist, and `tsconfig.unit.json` exists.
- [ ] `pnpm format`, `pnpm typecheck`, `pnpm lint`, `pnpm test`, and `pnpm build` pass after fixing generated-file issues.
- [ ] Final file structure and `git status --short` were reviewed.
- [ ] `docs/architecture.md` was created with the base stack, bootstrapped structure, and a Routes convention link.
- [ ] `docs/conventions/routes.md` was created with seed React Router patterns.
- [ ] `README.md` gives a very basic overview of the bootstrapped app, commands, and Cloudflare target.
- [ ] `AGENTS.md` includes basic agent instructions, the bootstrapped project structure, a Project Documentation section referencing `docs/`, and React Router guidance.
- [ ] `docs/context.json` was updated with `project.*` fields and `skills.scaffolding-project = "done"`.
- [ ] Generated and updated files were committed with a Conventional Commit message.
