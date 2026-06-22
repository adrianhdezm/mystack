---
name: creating-products
description: Orchestrates Product Builder from a product idea into an approved implementation plan and working product. Use when the user asks to create, build, start, scaffold, or turn a product idea into an application with Product Builder.
---

# Creating Products

Drives seven sequential phases from an empty repository to a working, verified, E2E-tested product. Reads `docs/context.json` before each phase to skip already-completed skills and resume interrupted runs.

## Context

At the start of each phase, read `docs/context.json` and check `skills.*`. **Skip any skill where `skills.<name> = "done"`.**

If `docs/context.json` does not exist, treat all statuses as `pending` and start from Phase 0.

## Workflow

Each phase is a single goal. Complete all acceptance criteria before advancing.

### Phase 0 — Repository

```
/goal Complete when all acceptance criteria are met.

Acceptance criteria:
- [ ] REPOSITORY and LOCAL_FOLDER are resolved
- [ ] preparing-repositories completed successfully
- [ ] LOCAL_REPOSITORY_PATH is established and the repo is empty
- [ ] docs/context.json exists with skills.preparing-repositories = "done"

Skip this phase if docs/context.json shows skills.preparing-repositories = "done".

Run preparing-repositories. It will derive REPOSITORY and LOCAL_FOLDER from the user's prompt or
ask for only the missing value. Do not create fallback folders. Stop and report if it cannot complete.
```

### Phase 1 — PRD

```
/goal Complete when all acceptance criteria are met.

Acceptance criteria:
- [ ] writing-prd completed successfully
- [ ] docs/prd.md exists with a Foundation Capabilities table filled in for every capability
- [ ] docs/context.json shows skills.writing-prd = "done"

Skip this phase if docs/context.json shows skills.writing-prd = "done".

Run writing-prd. It will interview the user, determine capabilities, get approval, and write
docs/prd.md. Stop and report if it cannot complete.
```

### Phase 2 — Foundation

```
/goal Complete when all acceptance criteria are met. Constraint: preserve any existing repo content.

Acceptance criteria:
- [ ] scaffolding-project completed successfully
- [ ] pnpm dev starts without errors
- [ ] Each foundation skill for approved capabilities ran successfully
- [ ] docs/architecture.md lists every capability with its integration point
- [ ] docs/data-model.md reflects all foundation tables
- [ ] docs/conventions/ contains entries from each foundation skill
- [ ] AGENTS.md is updated

Skip scaffolding-project if skills.scaffolding-project = "done". Confirm pnpm dev starts before
proceeding to foundation skills.

Run the foundation skill for each capability where Value=yes, in dependency order. Skip any skill
where skills.<name> = "done". Run each skill only after all its dependencies have set their
capabilities.* flags to true in docs/context.json:

| Capability       | Skill                   | Depends On  |
|------------------|-------------------------|-------------|
| database         | adding-database         | —           |
| authentication   | adding-authentication   | database    |
| file_storage     | adding-file-storage     | database    |
| ai               | adding-ai               | —           |
| landing_page     | adding-landing-page     | —           |
| legal_pages      | adding-legal-pages      | landing_page|

Verify each skill's doc updates before running the next. Stop and report if a skill fails
repeatedly and cannot be resolved without user input.
```

### Phase 3 — Feature Planning

```
/goal Complete when all acceptance criteria are met. Constraint: preserve all foundation code and
documentation unchanged.

Acceptance criteria:
- [ ] User approved the proposed feature list
- [ ] docs/features/manifest.json exists with all approved features
- [ ] planning-features ran for each feature in id order
- [ ] Each feature spec was approved by the user
- [ ] Every feature in manifest.json has status "ready" or "blocked" with a documented reason
- [ ] docs/context.json shows skills.planning-features = "done"

Skip this phase if docs/context.json shows skills.planning-features = "done".

Read references/feature-manifest.md for the manifest schema and status lifecycle. Derive the
feature list from the primary workflow and must-have pages in docs/prd.md. Propose short title
and one-line description for each, ordered by dependency. Get user approval before creating the
manifest. Create docs/features/manifest.json with all approved features as "listed", then run
planning-features for each feature in id order.

If a feature cannot be finalized, set it to "blocked" with a reason and continue. If all features
are blocked, stop and report what decisions are needed.
```

### Phase 4 — Feature Implementation

```
/goal Complete when all acceptance criteria are met. Constraint: preserve all implemented features
and their specs unchanged while implementing subsequent features.

Acceptance criteria:
- [ ] implementing-features ran for each "ready" feature in dependency order
- [ ] Each implemented feature was committed
- [ ] Every feature in manifest.json has status "implemented" or "blocked" with a documented reason
- [ ] docs/context.json shows skills.implementing-features = "done"

Skip this phase if docs/context.json shows skills.implementing-features = "done".

For each "ready" feature in manifest id order respecting depends_on, run implementing-features.
Commit after each feature. If a feature requires user input, set it to "blocked" and advance.
Stop and report if all remaining features are blocked.
```

### Phase 5 — Verification

```
/goal Complete when all acceptance criteria are met.

Acceptance criteria:
- [ ] verifying-features ran for each "implemented" feature
- [ ] Every feature in manifest.json has status "verified" or "blocked" with a documented reason
- [ ] docs/context.json shows skills.verifying-features = "done"

Skip this phase if docs/context.json shows skills.verifying-features = "done".

For each "implemented" feature in manifest id order, run verifying-features. If verification fails,
re-run implementing-features targeting the failed criteria then re-verify. Set to "blocked" if user
input is required. Stop and report if all remaining features are blocked.
```

### Phase 6 — Testing

```
/goal Complete when all acceptance criteria are met. Constraint: do not skip testing-features.

Acceptance criteria:
- [ ] testing-features ran for a comprehensive E2E pass
- [ ] E2E tests pass
- [ ] pnpm typecheck exits 0
- [ ] pnpm lint exits 0
- [ ] pnpm build exits 0
- [ ] docs/context.json shows skills.testing-features = "done"

Skip this phase if docs/context.json shows skills.testing-features = "done".

Run testing-features for a comprehensive E2E pass. If tests fail, fix with implementing-features
and re-run. Then run pnpm typecheck, pnpm lint, and pnpm build — fix failures and re-run until all
pass. Stop and report if failures cannot be resolved without user input.
```

### Final Summary

Commit the final state and present a summary to the user: foundation skills used, features implemented, commit hash, verification results, E2E results, build/lint/typecheck results, and open questions from `docs/architecture.md`. Do not write the summary to a file.

## References

- **Context schema**: [context-schema.md](../../shared/references/context-schema.md)
- **Feature manifest schema**: [references/feature-manifest.md](references/feature-manifest.md)

## Review Checklist

- [ ] `docs/context.json` read before each phase; completed skills skipped.
- [ ] Each phase completed all acceptance criteria before advancing.
- [ ] Foundation skills run in dependency order with capability flags verified between steps.
- [ ] Every feature spec was user-approved before implementation.
- [ ] All features are in a terminal state (`implemented`, `verified`, or `blocked`) in the manifest.
- [ ] E2E tests pass, `pnpm typecheck`, `pnpm lint`, and `pnpm build` exit 0.
- [ ] Final summary presented to the user with commit hash and open questions.
