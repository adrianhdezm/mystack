---
name: creating-products
description: Orchestrates Product Builder from a product idea into an approved implementation plan and working product. Use when the user asks to create, build, start, scaffold, or turn a product idea into an application with Product Builder.
---

# Creating Products

This is the Product Builder entry point. It drives seven sequential phases that take a product idea from an empty repository through working, verified features. Each phase is a single self-contained goal — it defines the end-state, the approach, and the stop condition in one block.

## Workflow

Each phase is a single goal. Set the goal and work until it is met before advancing to the next phase.

### Phase 0 — Repository

```
/goal Complete when all acceptance criteria are met.

Acceptance criteria:
- [ ] REPOSITORY and LOCAL_FOLDER are resolved
- [ ] preparing-repositories completed successfully
- [ ] LOCAL_REPOSITORY_PATH is established and the repo is empty

Run preparing-repositories. It will derive REPOSITORY and LOCAL_FOLDER from the user's prompt or ask for only the missing value. Do not create fallback folders. Stop and report if preparing-repositories cannot be completed.
```

### Phase 1 — PRD

```
/goal Complete when all acceptance criteria are met.

Acceptance criteria:
- [ ] writing-prd completed successfully
- [ ] docs/prd.md exists in the repository
- [ ] docs/prd.md contains a Foundation Capabilities table with Value and Rationale filled in for every capability

Run writing-prd. It will interview the user, determine foundation capabilities, present them for approval, and write docs/prd.md. Stop and report if writing-prd cannot be completed.
```

### Phase 2 — Foundation

```
/goal Complete when all acceptance criteria are met. Constraint: preserve any existing repo content.

Acceptance criteria:
- [ ] scaffolding-project completed successfully
- [ ] pnpm dev starts without errors
- [ ] Each foundation skill for the approved capabilities ran successfully
- [ ] docs/architecture.md lists every capability with its integration point
- [ ] docs/data-model.md reflects all foundation tables
- [ ] docs/conventions/ contains entries from each foundation skill
- [ ] AGENTS.md is updated

Read docs/prd.md and extract the Foundation Capabilities table. Run scaffolding-project for scaffolding. Confirm pnpm dev starts without errors before proceeding.

Then run the foundation skill for each capability where `Value=yes`, in dependency order derived from the `Depends On` column:

| Capability | Skill | Depends On |
| --- | --- | --- |
| `database` | `adding-database` | — |
| `authentication` | `adding-authentication` | `database` |
| `file_storage` | `adding-file-storage` | `database` |
| `ai` | `adding-ai` | — |
| `landing_page` | `adding-landing-page` | — |
| `legal_pages` | `adding-legal-pages` | `landing_page` |

Run each skill only after all its dependencies have completed. Verify each skill's doc updates before running the next.

If bootstrapping fails and cannot be resolved, or a foundation skill fails repeatedly and cannot be resolved without user input, stop and report what is blocking.
```

### Phase 3 — Feature Planning

```
/goal Complete when all acceptance criteria are met. Constraint: preserve all foundation code and documentation unchanged.

Acceptance criteria:
- [ ] User approved the proposed feature list
- [ ] docs/features/manifest.json exists with all approved features
- [ ] planning-features ran for each feature in id order
- [ ] Each feature spec was approved by the user
- [ ] Every feature in manifest.json has status "ready" or "blocked" with a documented reason
- [ ] No feature has status "listed"

Read references/feature-manifest.md for the manifest schema, field definitions, and status lifecycle. Derive the feature list from the primary workflow and must-have pages in docs/prd.md. Each feature should be an end-to-end deliverable of one step in that workflow. Propose short title and one-line description each, ordered by dependency. Get user approval before creating the manifest. Create docs/features/manifest.json with all approved features as "listed", then run planning-features for each feature in id order. Each spec follows the planning-features approval flow before moving to "ready".

Between iterations, if the user requests changes, update and re-present for approval. If a feature cannot be finalized after multiple iterations, set it to "blocked" with a reason and continue with remaining features. If all features are blocked, stop and report what decisions are needed.
```

### Phase 4 — Feature Implementation

```
/goal Complete when all acceptance criteria are met. Constraint: preserve all implemented features and their specs unchanged while implementing subsequent features.

Acceptance criteria:
- [ ] implementing-features ran for each "ready" feature in dependency order
- [ ] Each implemented feature was committed
- [ ] Every feature in manifest.json has status "implemented" or "blocked" with a documented reason
- [ ] No feature has status "ready"

For each "ready" feature in manifest id order respecting depends_on, run implementing-features. Commit after each implemented feature.

Use implementing-features only. Between iterations, if a feature requires user input set its status to "blocked" with a reason and advance to the next eligible feature. If all remaining features are blocked, stop and report what is needed.
```

### Phase 5 — Verification

```
/goal Complete when all acceptance criteria are met.

Acceptance criteria:
- [ ] verifying-features ran for each "implemented" feature
- [ ] Every feature in manifest.json has status "verified" or "blocked" with a documented reason

For each "implemented" feature in manifest id order, run verifying-features. If verification fails, re-run implementing-features targeting the failed acceptance criteria then re-verify.

Use verifying-features and implementing-features skills only. Between iterations, if a feature requires user input set its status to "blocked" with a reason and advance to the next eligible feature. If all remaining features are blocked, stop and report what is needed.
```

### Phase 6 — Testing

```
/goal Complete when all acceptance criteria are met. Constraint: do not skip testing-features — it is mandatory.

Acceptance criteria:
- [ ] testing-features ran for a comprehensive E2E pass
- [ ] E2E tests pass
- [ ] pnpm typecheck exits 0
- [ ] pnpm lint exits 0
- [ ] pnpm build exits 0

Run testing-features for a comprehensive E2E pass across all verified features. If E2E tests fail, fix the issues with implementing-features and re-run testing-features. Then run pnpm typecheck, pnpm lint, and pnpm build — fix any failures and re-run until all pass.

Use testing-features and implementing-features skills only. If build/lint/typecheck failures cannot be resolved without user input, stop and report the failures and what is needed.
```

### Final Summary

Commit the final state and summarize: foundation skills used, features implemented, commit hash, verification results, E2E test results, build/lint/typecheck results, and any open questions from `docs/architecture.md`. Output this summary directly to the user. Do not write it to a file.
