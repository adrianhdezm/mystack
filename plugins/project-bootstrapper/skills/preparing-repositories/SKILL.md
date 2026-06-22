---
name: preparing-repositories
description: Prepares a GitHub repository for Product Builder work by deriving or validating repository inputs, creating or finding the remote with gh, reusing an existing local clone when safe, or cloning an empty repo. Use before scaffolding-project when the user asks to create, inspect, validate, clone, prepare, or bootstrap a GitHub repository.
---

# Preparing Repositories

Derives a `<owner>/<repo>` slug and a local parent folder from the user's prompt, creates or validates the remote repository with `gh`, verifies it is empty, and clones it. Writes the result to `docs/context.json` for downstream skills.

## Rules

- Use the GitHub CLI (`gh`) for all GitHub operations — auth checks, repository lookup, creation, remote inspection, and cloning.
- Stop if `gh auth status` fails.
- `REPOSITORY` must be exactly `<owner>/<repo>` — reject branches, spaces, empty segments, and extra path parts.
- Derive `LOCAL_FOLDER` only from explicit prompt content ("in `~/Code`", "clone to `~/Code/<repo>`"). Never derive it from the current working directory, repository name, GitHub owner, or nearby folders.
- Stop before returning a path if the local target contains pre-existing app files or user files.
- Stop before cloning if the remote has any tracked files (including `README.md`, `.gitignore`, or license files).
- Never delete, overwrite, or clean user files to make a repository usable.
- Never create a local-only Product Builder app — a GitHub repository and an explicit local destination are mandatory.
- Missing `REPOSITORY` or `LOCAL_FOLDER` is blocking — never fall back to `work/`, a temp directory, or any agent-chosen location.

## Workflow

1. Derive `REPOSITORY` and `LOCAL_FOLDER` from the user's prompt:
   - `REPOSITORY` from: an explicit `<owner>/<repo>` slug, a GitHub URL (`https://github.com/...` or `git@github.com:...` — normalize to `<owner>/<repo>`), or a repo name plus a clear GitHub owner in the prompt.
   - `LOCAL_FOLDER` from: an explicit parent folder, a requested local path (use the parent), or path-indicating words ("in", "under", "clone to", "create at") followed by a local path.
   - If either value cannot be derived with high confidence, ask for only the missing value and wait.
2. Validate `REPOSITORY` as exactly `<owner>/<repo>`. Expand `LOCAL_FOLDER` to an absolute path. Derive `LOCAL_REPOSITORY_PATH` as `<LOCAL_FOLDER>/<repo>`.
3. Verify tools and auth:
   ```sh
   command -v gh
   gh auth status
   ```
   Stop if either command fails.
4. If the local target already exists, verify it using [01-existing-local-target.md](references/01-existing-local-target.md); if safe, return `existing-local`.
5. If the local target does not exist, verify or create the remote using [02-missing-local-target.md](references/02-missing-local-target.md).
6. Confirm the remote is empty using [03-empty-remote-check.md](references/03-empty-remote-check.md). Stop if any tracked files are found.
7. Clone the empty remote:
   ```sh
   gh repo clone "$REPOSITORY" "$LOCAL_REPOSITORY_PATH"
   ```
8. Create `<LOCAL_REPOSITORY_PATH>/docs/` if it does not exist, then write `<LOCAL_REPOSITORY_PATH>/docs/context.json` (using the default template from [context-schema.md](../../shared/references/context-schema.md) if creating from scratch):
   ```json
   {
     "repository": {
       "local_path": "<LOCAL_REPOSITORY_PATH>",
       "status": "<cloned | created-and-cloned | existing-local>",
       "github_slug": "<REPOSITORY>"
     }
   }
   ```
   All subsequent skills read and write `docs/context.json` relative to `repository.local_path`.
9. Output the contract:
   ```text
   LOCAL_REPOSITORY_PATH: <absolute path>
   REPOSITORY_STATUS: existing-local | cloned | created-and-cloned
   ```

## References

- **Existing local target**: [references/01-existing-local-target.md](references/01-existing-local-target.md)
- **Missing local target**: [references/02-missing-local-target.md](references/02-missing-local-target.md)
- **Empty remote check**: [references/03-empty-remote-check.md](references/03-empty-remote-check.md)
- **Context schema**: [context-schema.md](../../shared/references/context-schema.md)

## Review Checklist

- [ ] `gh auth status` succeeded.
- [ ] `REPOSITORY` and `LOCAL_FOLDER` derived from prompt or requested when missing — no fallback folders invented.
- [ ] `REPOSITORY` validated as exactly `<owner>/<repo>`.
- [ ] Existing local clone (if present) points to `REPOSITORY`.
- [ ] Local target had no pre-existing files beyond repository metadata.
- [ ] Remote existed or was created with `gh repo create`.
- [ ] Remote had zero tracked files before clone.
- [ ] `docs/` directory created inside `LOCAL_REPOSITORY_PATH` and `docs/context.json` written with `repository.*`.
- [ ] Output contract emitted with `LOCAL_REPOSITORY_PATH` and `REPOSITORY_STATUS`.
