---
name: creating-products
description: Orchestrates Product Builder from a bootstrapped project into an approved implementation plan and working product. Requires a project bootstrapped by project-bootstrapper. Use when the user asks to create, build, or turn a product idea into an application with Product Builder.
---

# Creating Products

Drives sequential phases from a bootstrapped project to a working, verified, E2E-tested product. Resume signals come from data in `docs/context.json` and `docs/features/manifest.json` — not from skill flags. Read both before each phase to determine what to skip and where to resume.

**Prerequisites:** Run `project-bootstrapper` → `bootstrapping-projects` before this skill. The project must have `project.deployment_target` and `capabilities.*` set in `docs/context.json`.

## Context

At the start of each phase, check the resume signal for that phase. If `docs/context.json` does not exist or is missing `project.deployment_target`, stop and instruct the user to run `project-bootstrapper` → `bootstrapping-projects` first.

## Resume Signals

| Phase | Skip when |
| --- | --- |
| 0 — Bootstrap check | `project.deployment_target` is set in `docs/context.json` AND `project.name` is set |
| 1 — PRD | `docs/prd.md` exists and is non-empty |
| 2 — Feature List | `docs/features/manifest.json` exists and contains at least one non-`listed` feature |
| 3 — Per-Feature Loop | all features in manifest are `verified` or `blocked` |

## Workflow

Each phase is a single goal. Complete all acceptance criteria before advancing.

### Phase 0 — Bootstrap Check

```
/goal Verify project-bootstrapper has run. Complete when all acceptance criteria are met.

Acceptance criteria:
- [ ] docs/context.json exists with project.deployment_target set
- [ ] docs/context.json has project.name set
- [ ] All capabilities.* are "ready" or "skipped" (none are "planned")

If any of these fail, stop with:

"This skill requires a bootstrapped project. Run project-bootstrapper → bootstrapping-projects first,
then re-run creating-products."

Do not attempt to bootstrap the project from this skill.
```

### Phase 1 — PRD

```
/goal Complete when all acceptance criteria are met.

Acceptance criteria:
- [ ] writing-prd completed successfully
- [ ] docs/prd.md exists with product description, user stories, and UI sections

Skip this phase if docs/prd.md exists and is non-empty.

Run writing-prd. It reads the committed code and capabilities from context, interviews the user
about product features and user flows, and writes docs/prd.md. Stop and report if it cannot complete.
```

### Phase 2 — Feature List

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
if it already exists. Derive the feature list from the primary workflow and must-have pages in
docs/prd.md. Propose short title, one-line description, and depends_on for each new feature.
Order features so no feature has a higher id than a feature it depends on. Get user approval
before writing the manifest.

This phase is purely structural — no specs are written here.
```

### Phase 3 — Per-Feature Loop

```
/goal Drive every feature through its full cycle: plan → implement → verify → test.
Complete when all features are "verified" or "blocked".

Read docs/features/manifest.json before each iteration. For each feature in id order whose
depends_on features are all "verified":

  Step 3a — Plan
  Run planning-features for the feature. It writes the spec and populates tasks[] in the manifest.
  Acceptance criteria:
  - [ ] Spec file written to docs/features/
  - [ ] Feature status = "ready", tasks[] populated at "pending" in manifest

  Step 3b — Implement
  Run implementing-features for the feature. It works through tasks in dependency order,
  committing after each task, and derives feature status from task state.
  Acceptance criteria:
  - [ ] All tasks "done", feature status derived to "implemented" in manifest
  - [ ] pnpm typecheck exits 0 after implementation

  Step 3c — Verify
  Run verifying-features for the feature. Checks all task acceptance criteria.
  Acceptance criteria:
  - [ ] Feature status = "verified" in manifest
  - [ ] pnpm typecheck, pnpm lint, pnpm test pass

  Step 3d — Test
  Run testing-features for the feature. Extends docs/e2e/test-plan.md and executes it.
  Acceptance criteria:
  - [ ] Feature section added to docs/e2e/test-plan.md
  - [ ] All E2E steps pass for this feature

  If 3d fails: fix with implementing-features targeting the failed steps, re-run verifying-features,
  then re-run testing-features. Do not advance until 3d passes or the feature is set to "blocked".

  If any other step fails, re-run the failing step before advancing. If a feature requires user
  input, set it to "blocked" and advance to the next eligible feature. Stop if all remaining
  features are blocked.

After all features are in a terminal state, run:
  - pnpm build — fix and re-run until it exits 0
  - pnpm lint  — fix and re-run until it exits 0
```

### Final Summary

Commit the final state and present a summary: capabilities wired, features implemented and verified, E2E results per feature, build/lint results, commit hash, and open questions from `docs/architecture.md`. Do not write the summary to a file.

## References

- **Context schema**: [../../shared/references/context-schema.md](../../shared/references/context-schema.md) (pointer to project-bootstrapper)
- **Feature manifest schema**: [references/feature-manifest.md](references/feature-manifest.md)

## Review Checklist

- [ ] Bootstrap check passed — `project.deployment_target`, `project.name`, all `capabilities.*` ready/skipped.
- [ ] Resume signals checked before each phase.
- [ ] Each phase completed all acceptance criteria before advancing.
- [ ] Feature list approved before manifest was written.
- [ ] Every feature cycled through plan → implement → verify → test in dependency order.
- [ ] Every feature spec was user-approved before implementation.
- [ ] All features are in a terminal state (`verified` or `blocked`) in the manifest.
- [ ] E2E tests pass per feature, `pnpm lint` and `pnpm build` exit 0.
- [ ] Final summary presented to the user with commit hash and open questions.
