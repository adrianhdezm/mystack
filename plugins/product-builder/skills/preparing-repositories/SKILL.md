---
name: preparing-repositories
description: Prepares a GitHub repository for Product Builder work by deriving or validating repository inputs, creating or finding the remote with gh, reusing an existing local clone when safe, or cloning an empty repo. Use before scaffolding-project when the user asks to create, inspect, validate, clone, prepare, or bootstrap a GitHub repository.
---

# Preparing Repositories

## Input discovery

Derive these values from the user's prompt before taking action:

```text
REPOSITORY: <owner>/<repo>
LOCAL_FOLDER: <parent-folder>
```

Prefer inference over asking. The user does not need to provide explicit `REPOSITORY:` or `LOCAL_FOLDER:` labels when the prompt contains enough information.

Derive `REPOSITORY` from:

- An explicit `<owner>/<repo>` GitHub repository slug.
- A GitHub repository URL such as `https://github.com/<owner>/<repo>` or `git@github.com:<owner>/<repo>.git`; normalize it to `<owner>/<repo>`.
- A repository name plus a clear GitHub owner or account in the prompt.

Derive `LOCAL_FOLDER` from:

- An explicit parent folder such as `~/Code`.
- A requested local repository path such as `~/Code/<repo>`; use the parent folder as `LOCAL_FOLDER`.
- Wording such as "in", "under", "inside", "clone to", or "create at" followed by a local path.

If `REPOSITORY` cannot be derived with high confidence, ask the user for only the repository before taking repository actions.

If `LOCAL_FOLDER` cannot be derived with high confidence, ask the user where the code should be located before taking repository actions. Do not derive `LOCAL_FOLDER` from the current working directory, the repository name, the GitHub owner, or nearby existing folders.

If a derived value is ambiguous, state the candidates and ask the user to choose. Do not invent a GitHub owner or local folder.

Missing repository or local target information is blocking, not optional. Never continue by creating a fallback folder such as `work/`, `./work`, the current workspace, a temporary directory, or any other agent-chosen location. Never say that the missing repository or destination will not block the work. Ask for the missing value and wait.

Validate the final `REPOSITORY` as exactly `<owner>/<repo>`, with no branch, spaces, empty segments, or extra path parts. Expand `LOCAL_FOLDER` to an absolute parent folder. Derive the expected local path as `<LOCAL_FOLDER>/<repo>`.

## Hard rules

- Use the GitHub CLI (`gh`) for GitHub operations: auth checks, repository lookup, repository creation, remote inspection, and cloning.
- Stop if `gh auth status` fails.
- Stop before creating files, scaffolding code, or bootstrapping if either `REPOSITORY` or `LOCAL_FOLDER` is missing or ambiguous.
- Stop before returning a repository path if the local target contains pre-existing app files or user files.
- Stop before cloning if the remote repository has any tracked files, including only `README.md`, `.gitignore`, license, or other starter files.
- Never delete, overwrite, or clean user files to make a repository usable.
- Never create a local-only Product Builder app. Product Builder must prepare a GitHub repository and an explicit local destination first.

## Workflow

1. Derive `REPOSITORY` and `LOCAL_FOLDER` from the user's prompt using the input discovery rules above.
2. If either value is missing or ambiguous, ask for only the missing or ambiguous value and wait before continuing.
3. Validate `REPOSITORY` as exactly `<owner>/<repo>`. Reject branches, spaces, empty segments, and extra path parts after URL normalization.
4. Expand `LOCAL_FOLDER` to an absolute parent folder and derive `LOCAL_REPOSITORY_PATH` as `<LOCAL_FOLDER>/<repo>`.
5. Verify required local tools and GitHub authentication:

   ```sh
   command -v gh
   gh auth status
   ```

   Stop if either command fails.

6. If the local target already exists, verify it using [01-existing-local-target.md](references/01-existing-local-target.md); if safe, return `existing-local`.
7. If the local target does not exist, verify or create the remote using [02-missing-local-target.md](references/02-missing-local-target.md).
8. Confirm the remote is empty using [03-empty-remote-check.md](references/03-empty-remote-check.md).
9. Clone the empty remote repository:

   ```sh
   gh repo clone "$REPOSITORY" "$LOCAL_REPOSITORY_PATH"
   cd "$LOCAL_REPOSITORY_PATH"
   ```

10. Return the output contract below with `REPOSITORY_STATUS: cloned | created-and-cloned`.

## Output contract

Always end with these values when successful:

```text
LOCAL_REPOSITORY_PATH: <absolute path>
REPOSITORY_STATUS: existing-local | cloned | created-and-cloned
```

Downstream skills, especially `scaffolding-project`, should use `LOCAL_REPOSITORY_PATH` as their working directory and preserve `REPOSITORY_STATUS` in their context.

## Stop message

When stopping because the prompt does not identify a repository or destination, ask only for the missing value:

```text
I need the GitHub repository and local parent folder before I can prepare the Product Builder project. Please provide the missing value.
```

Do not use this kind of fallback:

```text
No GitHub repository or destination folder was provided, so I will create the application locally inside work/.
```

When stopping because a repository is not empty, say this directly:

```text
The repository <owner>/<repo> is not empty, so I stopped before preparing it. Remove the existing files or provide a new empty repository.
```

Include the local or remote files found when available.

## Validation checklist

- [ ] `gh auth status` succeeds.
- [ ] `REPOSITORY` and `LOCAL_FOLDER` were derived from the prompt or requested only when missing.
- [ ] `REPOSITORY` and `LOCAL_FOLDER` are valid.
- [ ] Existing local clone, when present, points to `REPOSITORY`.
- [ ] Local target has no pre-existing files beyond repository metadata before handoff.
- [ ] Remote exists or was created with `gh repo create`.
- [ ] Remote has zero tracked files before clone.
- [ ] Output contract includes `LOCAL_REPOSITORY_PATH` and `REPOSITORY_STATUS`.
