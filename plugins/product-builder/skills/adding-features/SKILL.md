---
name: adding-features
description: Drives the full post-launch cycle for a single new feature — update the PRD, add the feature to the manifest, plan the spec, implement, verify, and test. Use when the user wants to add one feature to an existing Product Builder product after the first version is live.
---

# Adding Features

Drives the cycle for adding a single feature to an already-launched Product Builder product. Updates `docs/prd.md` as a living document, adds one entry to `docs/features/manifest.json`, produces a numbered spec with tasks, implements the full vertical slice, verifies against acceptance criteria, and runs the test suite. The feature follows the same `listed → ready → implementing → implemented → verified` lifecycle as the initial build.

**Scope**: one feature per run. To add multiple features, run this skill once per feature.

## Context

**Guard** — stop before proceeding if any of these conditions are not met:

- `project.name` is set in `docs/context.json`
- No capability is stuck at `"planned"` — every capability must be either `"ready"` or `"skipped"`

```text
Stop — foundation setup is not complete. project.name must be set and every capability must
be "ready" or "skipped" (none stuck at "planned") in docs/context.json.
Run creating-products first, then re-run this skill.
```

Progress for the new feature is tracked in `docs/features/manifest.json`. Do not write any fields to `docs/context.json` from this skill.

## Input

A feature described in user terms — e.g. "Let users export their data as CSV." If not provided:

1. Read `docs/features/manifest.json`.
2. Find the first `listed` feature whose `depends_on` features are all `verified`.
3. If a candidate exists, propose it — the user can accept or describe a different new feature instead.
4. If the user accepts an existing `listed` feature, skip Phase 1 (PRD already covers it) and Phase 2 (already in manifest) and jump to Phase 3.
5. If the user rejects the candidate, ask them to describe the new feature and proceed from Phase 1.
6. If no `listed` feature exists and no description is given, ask the user to describe the new feature.

If the description is vague, ask up to three clarifying questions before proceeding: who triggers this and what outcome do they expect? Is new data involved? What should be excluded from this addition?

## Workflow

Each phase must complete all acceptance criteria before the next begins.

### Phase 1 — Update PRD

```
/goal Extend docs/prd.md with the new feature. Complete when all acceptance criteria are met.

Acceptance criteria:
- [ ] docs/prd.md exists and was read in full before interviewing
- [ ] docs/features/manifest.json read to understand current feature scope and numbering
- [ ] User interviewed about the new feature only — settled sections not revisited
- [ ] New user stories, UI sections, Out of Scope, and Success Metrics additions drafted
- [ ] Additions presented to user and approved before writing
- [ ] docs/prd.md updated — existing content intact, new content appended with feature markers

Run writing-prd in update mode, passing the feature description already gathered as the
starting point so the skill does not re-ask for a description the user already provided.
writing-prd will focus the interview on scoping, edge cases, and exclusions — not on
re-establishing what the feature is. Do not proceed until approved content is written to docs/prd.md.
```

### Phase 2 — Add to Manifest

```
/goal Register the new feature in docs/features/manifest.json at status "listed".
Complete when all acceptance criteria are met.

Acceptance criteria:
- [ ] Feature title and one-line description proposed and approved by user
- [ ] depends_on derived from PRD content and proposed to user before writing
- [ ] New entry added to manifest.json with status "listed", tasks: [], continuing the id sequence
- [ ] No feature has a higher id than any feature it depends_on

Read the existing manifest to determine the next id. Propose a short title, one-line description,
and depends_on for the new feature — depends_on should list the ids of features that must be
verified before this one can be implemented (derive from data dependencies and user-flow
ordering described in the PRD). Get user approval before writing to the manifest.
tasks[] is left as an empty array — planning-features will populate it in Phase 3.

After the manifest entry is written and approved, commit:
- docs/prd.md
- docs/features/manifest.json

Commit message: `feat: ✨ Register <feature-title> in manifest`
```

### Phase 3 — Plan Spec

```
/goal Write a numbered feature spec to docs/features/. Complete when all acceptance criteria are met.

Acceptance criteria:
- [ ] User approved the proposed spec
- [ ] Spec file written to docs/features/ continuing the existing numbering sequence
- [ ] Spec contains a Tasks section with numbered tasks, layers, depends_on, and acceptance criteria
- [ ] Feature status updated to "ready" in manifest.json
- [ ] tasks[] in manifest.json populated with all tasks at status "pending"

Run planning-features with the feature description derived from Phase 1. It will read existing
specs and codebase, write the spec with a task breakdown, get user approval, and update the manifest.
```

### Phase 4 — Implement

```
/goal Build the full vertical slice task by task. Complete when all acceptance criteria are met.

Acceptance criteria:
- [ ] implementing-features ran for the new spec
- [ ] Tasks implemented in dependency order; each task committed individually
- [ ] Integration tests exist and pass for every DAO, Query, and Service
- [ ] Unit tests exist and pass for every route component
- [ ] docs/data-model.md reflects current schema
- [ ] docs/architecture.md Implementation Log updated
- [ ] pnpm typecheck exits 0
- [ ] pnpm test exits 0
- [ ] All tasks are "done" and feature status derived to "implemented" in manifest

Run implementing-features for the new spec. It will work through tasks in dependency order,
setting each task from "pending" to "implementing" to "done" and committing after each.
If a task requires user input, set it to "blocked" and report.
```

### Phase 5 — Verify

```
/goal Confirm the feature works against its acceptance criteria. Complete when all criteria are met.

Acceptance criteria:
- [ ] All tasks confirmed "done" in the manifest before verification starts
- [ ] verifying-features ran for the feature
- [ ] Feature has status "verified" in the manifest

Run verifying-features for the feature. If verification fails:
- Re-run implementing-features targeting only the failed criteria, then re-verify.
- If the second verification also fails, set the feature to "blocked", document the failure
  in docs/architecture.md as an open question, and stop. Do not loop more than twice without
  user input — repeated failure signals a spec ambiguity or environment issue that requires
  human decision.
- Set to "blocked" immediately if user input is required.
```

### Phase 6 — Test

```
/goal Confirm E2E behavior is correct and the build is clean. Complete when all criteria are met.

Acceptance criteria:
- [ ] testing-features ran and E2E steps pass for this feature
- [ ] pnpm build exits 0

Run testing-features for the feature. If E2E steps fail:
- Re-run implementing-features targeting the failed steps.
- Re-run verifying-features (feature goes back to "implemented" → re-verify → "verified").
- Re-run testing-features.
- If the second E2E run also fails, set the feature to "blocked" and stop.

Run pnpm build after E2E passes — this is the final clean-build confirmation. typecheck, lint,
and test were already confirmed in Phase 4 and Phase 5; do not re-run them unless a Phase 6
fix introduced new code changes.

Once E2E and build pass (or the feature is set to "blocked"), commit the feature's complete state:
- The feature spec file in docs/features/
- docs/features/manifest.json
- docs/e2e/test-plan.md
- Any source files changed for this feature

Commit message: `feat(<feature-title>): ✨ Implement, verify, and test <feature-title>`
```

### Final Summary

Present a summary: feature name, spec file, what was built task by task, verification result, test result, and any open questions from `docs/architecture.md`. Do not write the summary to a file.

## References

- **Feature manifest schema**: [references/feature-manifest.md](../creating-products/references/feature-manifest.md)
- **Context schema**: [context-schema.md](../../shared/references/context-schema.md)

## Review Checklist

- [ ] Guard passed — `project.name` set, no capability stuck at `"planned"`.
- [ ] Phase 1: PRD updated with new content appended, existing sections untouched; feature description passed to writing-prd — not re-asked.
- [ ] Phase 2: One feature added to manifest at "listed"; `depends_on` derived and approved; id sequence continues correctly; tasks: [].
- [ ] Phase 3: Spec file written with Tasks section; manifest updated to "ready" with tasks[] populated.
- [ ] Phase 4: Full vertical slice built task by task; each task committed; tests exist and pass; pnpm typecheck and pnpm test pass; feature "implemented".
- [ ] Phase 5: Feature verified; if failed, re-implemented and re-verified at most once before blocking.
- [ ] Phase 6: E2E steps pass; if failed, re-implement → re-verify → re-test at most once before blocking; pnpm build exits 0.
- [ ] Phase 2 commit landed after manifest entry written (PRD + manifest).
- [ ] Phase 6 commit landed after E2E and build pass (spec, manifest, source, test plan).
