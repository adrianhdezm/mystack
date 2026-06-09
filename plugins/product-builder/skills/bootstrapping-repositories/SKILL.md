---
name: bootstrapping-repositories
description: Bootstraps a prepared local repository into a pnpm TypeScript, Vite, Cloudflare, React Router, Tailwind, and shadcn/ui project. Use when the user asks to initialize, scaffold, or bootstrap a basic Product Builder repository, especially after managing-github-repositories returns LOCAL_REPOSITORY_PATH.
---

# Bootstrapping Repositories

## Required inputs

Require one of these before taking action:

```text
LOCAL_REPOSITORY_PATH: <absolute path>
```

Or first use `managing-github-repositories` with:

```text
REPOSITORY: <owner>/<repo-name>
LOCAL_FOLDER: <parent-folder>
```

Use the returned `LOCAL_REPOSITORY_PATH` as the working directory.

## Hard rules

- Use `pnpm` for package initialization, package version checks, and package installation.
- Do not trust remembered package versions. Check latest versions with `pnpm view <package> version` before installing, then install with `@latest`.
- Stop before bootstrapping if `LOCAL_REPOSITORY_PATH` already contains files other than repository metadata.
- After bootstrap starts, treat files created by the bootstrap as project source and reuse or update them in later steps.
- Never delete or overwrite user files to force a bootstrap.
- Keep Cloudflare spelled correctly in generated files, package names, and user-facing output.

## Workflow

1. If only `REPOSITORY` and `LOCAL_FOLDER` are provided, use `managing-github-repositories` first.
2. Validate `LOCAL_REPOSITORY_PATH` exists, is a git repository, and contains no pre-existing files other than repository metadata.
3. Initialize pnpm and base files using [01-initialize-pnpm-and-base-files.md](references/01-initialize-pnpm-and-base-files.md).
4. Add TypeScript using [02-typescript.md](references/02-typescript.md).
5. Add Vite, linting, and formatting using [03-vite-linting-formatting.md](references/03-vite-linting-formatting.md).
6. Add Cloudflare using [04-cloudflare.md](references/04-cloudflare.md).
7. Add the React Router page using [05-react-router-page.md](references/05-react-router-page.md).
8. Add Tailwind and shadcn/ui using [06-tailwind-and-shadcn-ui.md](references/06-tailwind-and-shadcn-ui.md).
9. Run final verification using [07-final-verification.md](references/07-final-verification.md).
10. Summarize what was created and list any command that failed.

## Stop message

When stopping because the local repository has pre-existing files, say this directly:

```text
The local repository <path> has pre-existing files, so I stopped before bootstrapping. Remove the existing files or provide a new empty repository.
```

Include the files found when available.

## Validation checklist

- [ ] `LOCAL_REPOSITORY_PATH` is available.
- [ ] Local repository has no pre-existing files beyond repository metadata.
- [ ] `pnpm view` was used for latest package checks.
- [ ] Cloudflare types are generated with `wrangler types`.
- [ ] `pnpm format`, `pnpm typecheck`, `pnpm lint`, and `pnpm build` pass after fixing generated-file issues.
- [ ] Final file structure and `git status --short` were reviewed.
