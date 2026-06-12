---
name: creating-products
description: Orchestrates Product Builder from a product idea into an approved implementation plan and working product. Use when the user asks to create, build, start, scaffold, or turn a product idea into an application with Product Builder.
---

# Creating Products

This is the Product Builder entry point. It interviews the user, classifies project complexity, prepares the foundation, then plans and implements features.

## Required inputs

Before repository actions, require or derive the same inputs as `preparing-repositories`:

```text
REPOSITORY: <owner>/<repo>
LOCAL_FOLDER: <parent-folder>
PRODUCT_IDEA: <short description>
```

If the repository or local folder is missing, run `preparing-repositories`; it must ask only for missing blocking values. Do not create fallback folders.

## Workflow

### Phase 1 — Interview and Foundation

1. Interview the user using [interview-and-decisions.md](references/interview-and-decisions.md). Ask only for information that cannot be inferred and materially changes the foundation or product design.
2. Classify the project and select foundation capabilities using the classification matrix in [interview-and-decisions.md](references/interview-and-decisions.md).
3. Prepare the repository by running `preparing-repositories`.
4. Bootstrap the app by running `bootstrapping-code` with the returned `LOCAL_REPOSITORY_PATH` and `REPOSITORY_STATUS`.
5. Add foundation capabilities in dependency order based on project classification:
   - `simple`: skip `adding-database`, `adding-authentication`, and `adding-file-storage`.
   - `standard`: run `adding-database`, then `adding-authentication`; skip `adding-file-storage`.
   - `advanced`: run `adding-database`, then `adding-authentication`, then `adding-file-storage`.

   Each foundation skill updates `docs/architecture.md`, `docs/data-model.md`, `docs/conventions/`, and `AGENTS.md` with its additions. After all foundation skills complete, `docs/architecture.md` should reflect the full stack, structure, and active conventions. Verify this before moving to Phase 2.

### Phase 2 — Feature Planning

6. Based on the interview and product idea, propose a list of features that together deliver the first usable version. Present each feature as a short title and one-line description. Order them by dependency — foundational features first.
7. Ask the user to approve, reorder, add, or remove features before proceeding.
8. Run `planning-features` for each approved feature, in order. Each run produces numbered spec files in `docs/features/`.

### Phase 3 — Feature Implementation Loop

9. For each planned feature spec in `docs/features/`, in order: a. Run `implementing-features` with the spec. b. Run `verifying-features` with the same spec. c. If verification passes, commit and move to the next feature. d. If verification finds issues, run `implementing-features` again to address them, then re-verify. Repeat until the spec passes or the issue requires user input. e. Summarize the feature result before starting the next one.

### Phase 4 — Final Verification

10. Run formatting, typecheck, lint, and build across the full project. If any command fails, fix the issue and re-run until it passes.
11. If any failure traces back to a specific feature (e.g., a type error in a route, a broken E2E step), return to Phase 3 for that feature: run `implementing-features` to fix the issue, then `verifying-features` to re-verify. Repeat until all features pass or the issue requires user input.
12. Once all checks pass, commit the final state and summarize: foundation skills used, features implemented, commit hash, verification results, E2E test results, and any open questions from `docs/architecture.md`.

## Approval gate

Do not treat the initial product idea as approval for specific features. The user must approve the proposed feature list before planning begins, and each feature spec must follow the `planning-features` approval flow before implementation.

If the user requests a change during review, update the proposal and ask for approval again before implementing.

## Validation checklist

- [ ] Interview captured the core users, workflow, data, privacy, uploads, and collaboration needs.
- [ ] Complexity and matrix-derived capabilities are stated before foundation work.
- [ ] Repository preparation and bootstrapping completed before add-on skills.
- [ ] Database was added before file storage or authentication when required.
- [ ] After foundation phase, `docs/architecture.md` reflects the full stack, structure, and active conventions.
- [ ] After foundation phase, `docs/data-model.md` reflects all entities from foundation skills.
- [ ] After foundation phase, `AGENTS.md` includes a Project Documentation section referencing `docs/`.
- [ ] Feature list was proposed and approved by the user before planning.
- [ ] `planning-features` was run for each approved feature.
- [ ] `implementing-features` and `verifying-features` were run for each feature spec.
- [ ] `docs/architecture.md` was maintained throughout.
- [ ] Formatting, typecheck, lint, and build pass after all features.
- [ ] Final summary includes features implemented, commit hash, verification and E2E test results, and open questions.
