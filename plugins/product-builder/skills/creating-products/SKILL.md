---
name: creating-products
description: Orchestrates Product Builder from a product idea into an approved implementation plan and working product. Use when the user asks to create, build, start, scaffold, or turn a product idea into an application with Product Builder.
---

# Creating Products

This is the Product Builder entry point. It drives five sequential goals that take a product idea from interview through working, verified features. Each phase is a single self-contained goal — it defines the end-state, the approach, and the stop condition in one block.

## Workflow

Each phase is a single goal. Set the goal and work until it is met before advancing to the next phase.

### Phase 1 — Interview and Classification

```
/goal Complete when all acceptance criteria are met.

Acceptance criteria:
- [ ] User answered all interview questions from references/interview-and-classification.md
- [ ] PROJECT_COMPLEXITY block is populated with tier, justification, and capabilities
- [ ] User explicitly approved the PROJECT_COMPLEXITY block

Read references/interview-and-classification.md for interview questions, classification tiers, and the approval format. Interview the user, classify the project, and present for approval.

Between iterations, ask only for the minimum missing value that blocks progress.
```

### Phase 2 — Foundation

```
/goal Complete when all acceptance criteria are met. Constraint: preserve any existing repo content the user has committed.

Acceptance criteria:
- [ ] REPOSITORY, LOCAL_FOLDER, and PRODUCT_IDEA are resolved
- [ ] preparing-repositories completed successfully
- [ ] bootstrapping-code completed successfully
- [ ] pnpm dev starts without errors
- [ ] Each foundation skill for the classification ran successfully
- [ ] docs/architecture.md lists every capability with its integration point
- [ ] docs/data-model.md reflects all foundation tables
- [ ] docs/conventions/ contains entries from each foundation skill
- [ ] AGENTS.md is updated

First, require or derive REPOSITORY, LOCAL_FOLDER, and PRODUCT_IDEA. If the repository or local folder is missing, run preparing-repositories — it must ask only for missing blocking values. Do not create fallback folders. Then run bootstrapping-code for scaffolding. Confirm pnpm dev starts without errors before proceeding.

Then read references/foundation-capabilities.md for the classification-to-skill mapping and dependency order. Run each skill in order, verifying its doc updates before running the next.

If the user cannot provide REPOSITORY or LOCAL_FOLDER after being asked, bootstrapping fails and cannot be resolved, or a foundation skill fails repeatedly and cannot be resolved without user input, stop and report what is blocking.
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

Read references/feature-manifest.md for the manifest schema, field definitions, and status lifecycle. Propose features that together deliver the first usable version — short title and one-line description each, ordered by dependency. Get user approval before creating the manifest. Create docs/features/manifest.json with all approved features as "listed", then run planning-features for each feature in id order. Each spec follows the planning-features approval flow before moving to "ready".

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
/goal Complete when all acceptance criteria are met. Constraint: both verifying-features and testing-features are mandatory — do not skip either.

Acceptance criteria:
- [ ] verifying-features ran for each "implemented" feature
- [ ] Every feature in manifest.json has status "verified" or "blocked" with a documented reason
- [ ] testing-features ran for a comprehensive E2E pass
- [ ] E2E tests pass
- [ ] pnpm typecheck exits 0
- [ ] pnpm lint exits 0
- [ ] pnpm build exits 0

For each "implemented" feature in manifest id order, run verifying-features. If verification fails, re-run implementing-features targeting the failed acceptance criteria then re-verify. After all features reach "verified", run testing-features for a comprehensive E2E pass across all features. If E2E tests fail, fix the issues with implementing-features and re-run testing-features. Then run pnpm typecheck, pnpm lint, and pnpm build — fix any failures and re-run until all pass.

Use verifying-features, testing-features, and implementing-features skills only. Between iterations, if a feature requires user input set its status to "blocked" with a reason and advance to the next eligible feature. If all remaining features are blocked or build/lint/typecheck failures cannot be resolved, stop and report the failures and what is needed.
```

### Final Summary

Commit the final state and summarize: foundation skills used, features implemented, commit hash, verification results, E2E test results, and any open questions from `docs/architecture.md`.
