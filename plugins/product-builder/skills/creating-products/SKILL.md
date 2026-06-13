---
name: creating-products
description: Orchestrates Product Builder from a product idea into an approved implementation plan and working product. Use when the user asks to create, build, start, scaffold, or turn a product idea into an application with Product Builder.
---

# Creating Products

This is the Product Builder entry point. It drives four sequential goals that take a product idea from interview through working, verified features. Each phase is a single self-contained goal — it defines the end-state, the approach, and the stop condition in one block.

## Required inputs

Before repository actions, require or derive the same inputs as `preparing-repositories`:

```text
REPOSITORY: <owner>/<repo>
LOCAL_FOLDER: <parent-folder>
PRODUCT_IDEA: <short description>
```

If the repository or local folder is missing, run `preparing-repositories`; it must ask only for missing blocking values. Do not create fallback folders.

## Workflow

Each phase is a single goal. Set the goal and work until it is met before advancing to the next phase.

### Phase 1 — Interview and Classification

```
/goal Complete when the user has approved the PROJECT_COMPLEXITY block and the project scaffolds successfully. Check: the user explicitly confirms the classification and pnpm dev starts without errors in the bootstrapped project directory. Constraint: preserve any existing repo content the user has committed.

Read references/interview-and-classification.md for interview questions, classification tiers, and the approval format. Interview the user, classify the project, and present for approval. Then run preparing-repositories for repo setup and bootstrapping-code for scaffolding.

Between iterations, ask only for the minimum missing value that blocks progress. If the user cannot provide REPOSITORY or LOCAL_FOLDER after being asked, or bootstrapping fails and cannot be resolved, stop and report what is blocking.
```

### Phase 2 — Foundation

```
/goal Complete when all foundation capabilities for the approved classification are installed and documented. Check: read docs/architecture.md and confirm it lists every capability with its integration point, read docs/data-model.md and confirm it reflects all foundation tables, confirm docs/conventions/ contains entries from each skill, and confirm AGENTS.md is updated. Constraint: preserve the bootstrapped app structure and any user-committed code.

Read references/foundation-capabilities.md for the classification-to-skill mapping and dependency order. Run each skill in order, verifying its doc updates before running the next.

If a foundation skill fails repeatedly and cannot be resolved without user input, stop and report the failure and what is needed.
```

### Phase 3 — Feature Planning

```
/goal Complete when every feature has a user-approved spec. Check: read docs/features/manifest.json and confirm every feature has status "ready" (or "blocked" with a documented reason) — no feature has status "listed". Constraint: preserve all foundation code and documentation unchanged.

Read references/feature-manifest.md for the manifest schema, field definitions, and status lifecycle. Propose features that together deliver the first usable version — short title and one-line description each, ordered by dependency. Get user approval before creating the manifest. Create docs/features/manifest.json with all approved features as "listed", then run planning-features for each feature in id order. Each spec follows the planning-features approval flow before moving to "ready".

Between iterations, if the user requests changes, update and re-present for approval. If a feature cannot be finalized after multiple iterations, set it to "blocked" with a reason and continue with remaining features. If all features are blocked, stop and report what decisions are needed.
```

### Phase 4 — Feature Implementation

```
/goal Complete when every feature is verified, E2E tests pass, and the project builds cleanly. Check: read docs/features/manifest.json and confirm every feature has status "verified" (or "blocked" with a documented reason), then run pnpm typecheck, pnpm lint, and pnpm build — all must exit 0. Constraint: preserve all verified features and their specs unchanged while implementing subsequent features.

For each "ready" feature in manifest id order respecting depends_on, run implementing-features then verifying-features. If verification fails, re-run implementing-features targeting the failed acceptance criteria then re-verify. Commit after each verified feature. After the last feature reaches "verified", run testing-features for a comprehensive E2E pass across all features. Then run pnpm typecheck, pnpm lint, and pnpm build — fix any failures and re-run until all pass.

Use implementing-features, verifying-features, and testing-features skills only. Between iterations, if a feature requires user input set its status to "blocked" with a reason and advance to the next eligible feature. If all remaining features are blocked or build/lint/typecheck failures cannot be resolved, stop and report the failures and what is needed.
```

### Final Summary

Commit the final state and summarize: foundation skills used, features implemented, commit hash, verification results, E2E test results, and any open questions from `docs/architecture.md`.
