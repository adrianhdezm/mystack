---
name: managing-github-repositories
description: Prepares a GitHub repository for Product Builder work by validating inputs, creating or finding the remote with gh, reusing an existing local clone when safe, or cloning an empty repo. Use when the user provides REPOSITORY and LOCAL_FOLDER values or asks to create, inspect, validate, clone, or prepare a GitHub repository.
---

# Managing GitHub Repositories

## Required inputs

Require these values before taking action:

```text
REPOSITORY: <owner>/<repo-name>
LOCAL_FOLDER: <parent-folder>
```

Validate `REPOSITORY` as exactly `owner/repo`, with no URL, branch, spaces, or extra path parts. Expand `LOCAL_FOLDER` to an absolute parent folder. Derive the expected local path as `<LOCAL_FOLDER>/<repo-name>`.

## Hard rules

- Use the GitHub CLI (`gh`) for GitHub operations: auth checks, repository lookup, repository creation, remote inspection, and cloning.
- Stop if `gh auth status` fails.
- Stop before returning a repository path if the local target contains pre-existing app files or user files.
- Stop before cloning if the remote repository has any tracked files, including only `README.md`, `.gitignore`, license, or other starter files.
- Never delete, overwrite, or clean user files to make a repository usable.

## Workflow

1. Validate `REPOSITORY` as exactly `owner/repo`. Reject URLs, branches, spaces, empty segments, and extra path parts.
2. Expand `LOCAL_FOLDER` to an absolute parent folder and derive `LOCAL_REPOSITORY_PATH` as `<LOCAL_FOLDER>/<repo-name>`.
3. Verify required local tools and GitHub authentication:

   ```sh
   command -v gh
   gh auth status
   ```

   Stop if either command fails.

4. If the local target already exists, verify it using [01-existing-local-target.md](references/01-existing-local-target.md); if safe, return `existing-local`.
5. If the local target does not exist, verify or create the remote using [02-missing-local-target.md](references/02-missing-local-target.md).
6. Confirm the remote is empty using [03-empty-remote-check.md](references/03-empty-remote-check.md).
7. Clone the empty remote repository:

   ```sh
   gh repo clone "$REPOSITORY" "$LOCAL_REPOSITORY_PATH"
   cd "$LOCAL_REPOSITORY_PATH"
   ```

8. Return the output contract below with `REPOSITORY_STATUS: cloned | created-and-cloned`.

## Output contract

Always end with these values when successful:

```text
LOCAL_REPOSITORY_PATH: <absolute path>
REPOSITORY_STATUS: existing-local | cloned | created-and-cloned
```

Downstream skills should use `LOCAL_REPOSITORY_PATH` as their working directory.

## Stop message

When stopping because a repository is not empty, say this directly:

```text
The repository <owner>/<repo-name> is not empty, so I stopped before preparing it. Remove the existing files or provide a new empty repository.
```

Include the local or remote files found when available.

## Validation checklist

- [ ] `gh auth status` succeeds.
- [ ] `REPOSITORY` and `LOCAL_FOLDER` are valid.
- [ ] Existing local clone, when present, points to `REPOSITORY`.
- [ ] Local target has no pre-existing files beyond repository metadata before handoff.
- [ ] Remote exists or was created with `gh repo create`.
- [ ] Remote has zero tracked files before clone.
- [ ] Output contract includes `LOCAL_REPOSITORY_PATH` and `REPOSITORY_STATUS`.
