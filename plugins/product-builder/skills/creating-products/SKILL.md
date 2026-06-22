---
name: creating-products
description: Orchestrates Product Builder from a product idea into an approved implementation plan and working product. Use when the user asks to create, build, start, scaffold, or turn a product idea into an application with Product Builder.
---

# Creating Products

Drives sequential phases from an empty repository to a working, verified, E2E-tested product. Resume signals come from data in `docs/context.json` and `docs/features/manifest.json` — not from skill flags. Read both before each phase to determine what to skip and where to resume.

## Context

At the start of each phase, check the resume signal for that phase (see each phase's skip condition). If `docs/context.json` does not exist, start from Phase 0.

## Resume Signals

| Phase                | Skip when                                                                                 |
| -------------------- | ----------------------------------------------------------------------------------------- |
| 0 — Repository       | `repository.local_path` is set in `docs/context.json` **and** the path exists on disk     |
| 1 — PRD              | `docs/prd.md` exists **and** is non-empty                                                 |
| 2 — Foundation       | `project.name` is set **and** every `capabilities.*` that is `"planned"` is now `"ready"` |
| 3 — Feature List     | `docs/features/manifest.json` exists and contains at least one non-`listed` feature       |
| 4 — Per-Feature Loop | all features in manifest are `verified` or `blocked`                                      |

## Workflow

Each phase is a single goal. Complete all acceptance criteria before advancing.

### Phase 0 — Repository

```
/goal Complete when all acceptance criteria are met.

Acceptance criteria:
- [ ] REPOSITORY and LOCAL_FOLDER are resolved
- [ ] preparing-repositories completed successfully
- [ ] LOCAL_REPOSITORY_PATH is established and the repo is empty
- [ ] repository.local_path is set in docs/context.json

Skip this phase if repository.local_path is set in docs/context.json.

Run preparing-repositories. It will derive REPOSITORY and LOCAL_FOLDER from the user's prompt or
ask for only the missing value. Do not create fallback folders. Stop and report if it cannot complete.
```

### Phase 1 — PRD

```
/goal Complete when all acceptance criteria are met.

Acceptance criteria:
- [ ] writing-prd completed successfully
- [ ] docs/prd.md exists with a Foundation Capabilities table filled in for every capability

Skip this phase if docs/prd.md exists.

Run writing-prd. It will interview the user, determine capabilities, get approval, and write
docs/prd.md. Stop and report if it cannot complete.
```

### Phase 2 — Foundation

```
/goal Complete when all acceptance criteria are met. Constraint: preserve any existing repo content.

Acceptance criteria:
- [ ] scaffolding-project completed successfully
- [ ] pnpm dev starts without errors
- [ ] Every capability with status "planned" has been run and is now "ready"
- [ ] docs/architecture.md lists every capability with its integration point
- [ ] docs/data-model.md reflects all foundation tables
- [ ] docs/conventions/ contains entries from each foundation skill
- [ ] AGENTS.md is updated

Skip scaffolding-project if project.name is already set in docs/context.json. Skip each
foundation capability skill if its capabilities.* is already "ready". Confirm pnpm dev starts before
proceeding to foundation skills.

Run the foundation skill for each capability where `capabilities.* = "planned"`, in dependency order. Skip any
where capabilities.* is already "ready". Run each skill only after all its dependencies have set their
capabilities.* to "ready" in docs/context.json:

| Capability       | Skill                   | Depends On   |
|------------------|-------------------------|--------------|
| database         | adding-database         | —            |
| authentication   | adding-authentication   | database     |
| file_storage     | adding-file-storage     | database     |
| ai               | adding-ai               | —            |
| landing_page     | adding-landing-page     | —            |
| legal_pages      | adding-legal-pages      | landing_page |

All six capabilities follow the same loop — legal_pages is not special-cased. When both
landing_page and authentication are planned, run adding-landing-page before adding-authentication
so the public layout route exists when auth routes are registered inside it. Verify each
skill's doc updates before running the next. Stop and report if a skill fails repeatedly and
cannot be resolved without user input.
```

### Phase 3 — Feature List

```
/goal Approve the full feature list and register all features in the manifest. Complete when all
acceptance criteria are met.

Acceptance criteria:
- [ ] User approved the proposed feature list
- [ ] docs/features/manifest.json exists with all approved features at status "listed", tasks: []
- [ ] depends_on derived from PRD workflow and proposed to user before manifest was written
- [ ] No feature has a higher id than any feature it depends on

Skip this phase if docs/features/manifest.json exists and contains at least one feature that
is not "listed" — meaning planning has already begun.

Read references/feature-manifest.md for the manifest schema. Read docs/features/manifest.json
if it already exists — use any existing entries as the starting point to avoid re-proposing
features already registered. Derive the feature list from the primary workflow and must-have
pages in docs/prd.md. Propose short title, one-line description, and depends_on for each
new feature — depends_on should list the ids of features that must be verified before this
one can be implemented (e.g. a "task detail" feature depends on "task list"). Order features
so no feature has a higher id than a feature it depends on. Get user approval before writing
the manifest. Create or update docs/features/manifest.json with all approved features at
status "listed" and tasks: [].

This phase is purely structural — no specs are written here.
```

### Phase 4 — Per-Feature Loop

```
/goal Drive every feature through its full cycle: plan → implement → verify → test.
Complete when all features are "verified" or "blocked".

Read docs/features/manifest.json before each iteration. For each feature in id order whose
depends_on features are all "verified":

  Step 4a — Plan
  Run planning-features for the feature. It writes the spec and populates tasks[] in the manifest.
  Acceptance criteria:
  - [ ] Spec file written to docs/features/
  - [ ] Feature status = "ready", tasks[] populated at "pending" in manifest

  Step 4b — Implement
  Run implementing-features for the feature. It works through tasks in dependency order,
  committing after each task, and derives feature status from task state.
  Acceptance criteria:
  - [ ] All tasks "done", feature status derived to "implemented" in manifest
  - [ ] pnpm typecheck exits 0 after implementation

  Step 4c — Verify
  Run verifying-features for the feature. Checks all task acceptance criteria.
  Acceptance criteria:
  - [ ] Feature status = "verified" in manifest
  - [ ] pnpm typecheck, pnpm lint, pnpm test pass

  Step 4d — Test
  Run testing-features for the feature. Extends docs/e2e/test-plan.md and executes it.
  Acceptance criteria:
  - [ ] Feature section added to docs/e2e/test-plan.md
  - [ ] All E2E steps pass for this feature

  If 4d fails: fix with implementing-features targeting the failed steps, re-run verifying-features,
  then re-run testing-features. Do not advance to the next feature until 4d passes or the feature
  is explicitly set to "blocked" because user input is required.

  If any other step fails, re-run the failing step (re-implement → re-verify if needed) before
  advancing to the next feature. If a feature requires user input at any step, set it to
  "blocked" and advance to the next eligible feature. Stop and report if all remaining
  features are blocked.

After all features are in a terminal state, run:
  - pnpm build — fix and re-run until it exits 0
  - pnpm lint  — fix and re-run until it exits 0
```

### Final Summary

Commit the final state and present a summary to the user: foundation skills used, features implemented and verified, E2E results per feature, build/lint results, commit hash, and open questions from `docs/architecture.md`. Do not write the summary to a file.

## References

- **Context schema**: [context-schema.md](../../shared/references/context-schema.md)
- **Feature manifest schema**: [references/feature-manifest.md](references/feature-manifest.md)

## Review Checklist

- [ ] Resume signals checked before each phase (data signals, not flags).
- [ ] Each phase completed all acceptance criteria before advancing.
- [ ] Foundation skills run in dependency order; capability flags verified as `"ready"` between steps.
- [ ] Feature list approved before manifest was written.
- [ ] Every feature cycled through plan → implement → verify → test in dependency order.
- [ ] Every feature spec was user-approved before implementation.
- [ ] All features are in a terminal state (`verified` or `blocked`) in the manifest.
- [ ] E2E tests pass per feature, `pnpm lint` and `pnpm build` exit 0.
- [ ] Final summary presented to the user with commit hash and open questions.
