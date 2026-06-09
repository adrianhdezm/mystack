---
name: bootstrapping-code
description: Bootstraps a prepared local repository into a pnpm TypeScript, Vite, Cloudflare, React Router, Tailwind, and shadcn/ui project. Use after preparing-repositories has returned LOCAL_REPOSITORY_PATH and REPOSITORY_STATUS, when the user asks to initialize, scaffold, or bootstrap the basic Product Builder codebase.
---

# Bootstrapping Code

## Required inputs

Require the successful output from `preparing-repositories` before taking action:

```text
LOCAL_REPOSITORY_PATH: <absolute path>
REPOSITORY_STATUS: existing-local | cloned | created-and-cloned
```

If those values are missing, stop before bootstrapping and prepare the
repository first.

Use the returned `LOCAL_REPOSITORY_PATH` as the working directory.

## Hard rules

- Use `pnpm` for package initialization, package version checks, and package installation.
- Do not trust remembered package versions. Check latest versions with `pnpm view <package> version` before installing, then install with `@latest`.
- Stop before bootstrapping if `preparing-repositories` has not completed successfully.
- Stop before bootstrapping if `LOCAL_REPOSITORY_PATH` already contains files other than repository metadata.
- After bootstrap starts, treat files created by the bootstrap as project source and reuse or update them in later steps.
- Never delete or overwrite user files to force a bootstrap.
- Keep Cloudflare spelled correctly in generated files, package names, and user-facing output.

## Workflow

1. Confirm `preparing-repositories` returned `LOCAL_REPOSITORY_PATH` and `REPOSITORY_STATUS`.
2. If `LOCAL_REPOSITORY_PATH` and `REPOSITORY_STATUS` are missing, stop before bootstrapping and prepare the repository first.
3. Validate `LOCAL_REPOSITORY_PATH` exists, is a git repository, and contains no pre-existing files other than repository metadata.
4. Initialize pnpm and base files using [01-initialize-pnpm-and-base-files.md](references/01-initialize-pnpm-and-base-files.md).
5. Add TypeScript using [02-typescript.md](references/02-typescript.md).
6. Add Vite, linting, and formatting using [03-vite-linting-formatting.md](references/03-vite-linting-formatting.md).
7. Add Cloudflare using [04-cloudflare.md](references/04-cloudflare.md).
8. Add the React Router page using [05-react-router-page.md](references/05-react-router-page.md).
9. Add Tailwind and shadcn/ui using [06-tailwind-and-shadcn-ui.md](references/06-tailwind-and-shadcn-ui.md).
10. Run final verification using [07-final-verification.md](references/07-final-verification.md).
11. Update the project `README.md` so it reflects the bootstrapped application, including the stack, local development commands, verification commands, and Cloudflare deployment target.
12. Commit the generated and updated files in the repository using the repository's Conventional Commits format.
13. Summarize what was created, include the commit hash, and list any command that failed.

## Stop message

When stopping because the local repository has pre-existing files, say this directly:

```text
The local repository <path> has pre-existing files, so I stopped before bootstrapping. Remove the existing files or provide a new empty repository.
```

Include the files found when available.

## Validation checklist

- [ ] `preparing-repositories` completed successfully.
- [ ] `LOCAL_REPOSITORY_PATH` and `REPOSITORY_STATUS` are available.
- [ ] Local repository has no pre-existing files beyond repository metadata.
- [ ] `pnpm view` was used for latest package checks.
- [ ] Cloudflare types are generated with `wrangler types`.
- [ ] `pnpm format`, `pnpm typecheck`, `pnpm lint`, and `pnpm build` pass after fixing generated-file issues.
- [ ] Final file structure and `git status --short` were reviewed.
- [ ] `README.md` documents the bootstrapped app, commands, and Cloudflare target.
- [ ] Generated and updated files were committed with a Conventional Commit message.
