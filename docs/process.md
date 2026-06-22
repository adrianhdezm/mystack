# Product Builder: Creating Products Process

End-to-end process for turning a product idea into a working application. The [`creating-products`](../plugins/product-builder/skills/creating-products/SKILL.md) skill orchestrates seven phases by invoking all other skills in sequence.

---

## Orchestrator

### `creating-products`

**Goal:** Drive the full product lifecycle across seven phases.

**Inputs**
- Product idea or problem description (from the user)
- Resolved outputs from each sub-skill as phases complete

**Outputs**
- Fully bootstrapped, documented, and verified project in a local git repository
- `docs/features/manifest.json` — all approved features set to `listed`
- Final summary: foundation skills used, features implemented, commit hash, verification and E2E results, open questions

**Side effects**
- All `docs/` updates produced by the sub-skills it invokes

---

## Phase 0 — Repository

**Goal:** Establish an empty GitHub repository and a local clone before any product work begins.

### `preparing-repositories`

**Inputs**
- `REPOSITORY` — `<owner>/<repo>` GitHub slug or full URL
- `LOCAL_FOLDER` — parent directory for the local clone

**Outputs**
- `LOCAL_REPOSITORY_PATH` — absolute path to the prepared local repository
- `REPOSITORY_STATUS` — one of `existing-local`, `cloned`, or `created-and-cloned`

**Phase complete when** `LOCAL_REPOSITORY_PATH` is established and the repository is empty.

---

## Phase 1 — PRD

**Goal:** Interview the user, determine foundation capabilities, and write `docs/prd.md` into the repository.

The interview covers: target users, primary workflow, data persistence, privacy model, accounts/roles, file uploads, must-have pages, external services, v1 exclusions, and success metrics. Product Builder prefers inference over questions — it only asks when the answer materially changes the product or its implementation.

After the interview, `writing-prd` derives each capability flag and presents them for user approval.

### `writing-prd`

**Inputs**
- Product idea or problem description (from the user)
- User answers to interview questions
- Existing `docs/prd.md` if updating (optional)

**Outputs**
- `docs/prd.md` — product overview, user personas, problem statement, primary workflow, entry-point flow, must-have pages, data ownership model, and approved Foundation Capabilities table

**Phase complete when** `docs/prd.md` exists and contains an approved `Foundation Capabilities` section.

---

## Phase 2 — Foundation

**Goal:** Scaffold the base project and install all enabled foundation capabilities.

Foundation skills run in dependency order based on the Foundation Capabilities table in `docs/prd.md`. Environment variables required before starting foundation skills:
- `adding-database` → `CLOUDFLARE_ACCOUNT_ID`, `CLOUDFLARE_DATABASE_ID`, `CLOUDFLARE_D1_TOKEN`
- `adding-authentication` → `AUTH_SECRET` (generate with `openssl rand -base64 32`)
- `adding-ai` → `OPENAI_API_KEY`

Phase 2 blocks at the relevant skill if any secret is missing.

### `scaffolding-project`

**Inputs**
- `LOCAL_REPOSITORY_PATH` — from `preparing-repositories`
- `REPOSITORY_STATUS` — from `preparing-repositories`

**Outputs**
- Full project tree: `package.json`, `pnpm-lock.yaml`, `tsconfig.json`, `vite.config.ts`, `wrangler.jsonc`, `tailwind.config.ts`, `components.json`, `app/root.tsx`, `app/routes.ts`, `app/styles/globals.css`, `workers/app.ts`, `public/`, `README.md`, `AGENTS.md`
- `docs/architecture.md` — initial stack and structure documentation
- `docs/conventions/routes.md` — initial routing conventions

---

### `adding-database` _(when database=yes)_

Adds Cloudflare D1 with Drizzle ORM, migrations, and Worker context integration.

**Inputs**
- `PROJECT_PATH`
- `D1_DATABASE_NAME` — auto-derived if omitted
- `D1_BINDING` (default: `APP_DB`)
- `.env`: `CLOUDFLARE_ACCOUNT_ID`, `CLOUDFLARE_DATABASE_ID`, `CLOUDFLARE_D1_TOKEN`

**Outputs**
- `drizzle.config.ts`, `app/db/schema.ts`, `app/context.ts` — Drizzle config, initial schema, app context with `db: DrizzleD1Database`
- `db/migrations/` — initial migration files
- `tsconfig.integration.json`, `tsconfig.cloudflare.json`, `tests/integration/vitest.config.ts`
- `docs/data-model.md` — entities and relationships from the initial schema
- `docs/conventions/data-access.md` — DAO, query, and service patterns
- `docs/conventions/testing.md` — directory structure, test type inference, `applyMigrations`/`getTestDb` patterns, and layer-specific testing guidance

**Side effects**
- Updates `docs/architecture.md` — D1 integration point and binding

---

### `adding-authentication` _(when authentication=yes)_

Adds Better Auth email-and-password authentication with protected routes and session handling.

**Inputs**
- `PROJECT_PATH`
- `D1_BINDING` (default: `APP_DB`)
- `AUTH_COOKIE_PREFIX` (default: `App`)
- `AUTH_SECRET` — generated via `openssl rand -base64 32`

**Outputs**
- `app/services/auth.service.ts`, `app/routes/auth.tsx`, `app/routes/login.tsx`, `app/routes/signup.tsx`, `app/routes/logout.tsx`
- `db/migrations/<auth-migration>` — auth tables migration
- `tests/unit/routes/login.test.tsx`, `tests/unit/routes/signup.test.tsx`

**Side effects**
- Updates `docs/architecture.md` — auth integration and session handling
- Updates `docs/data-model.md` — `users`, `sessions`, `accounts`, `verifications` tables
- Updates `docs/conventions/routes.md` — protected route patterns

---

### `adding-file-storage` _(when file_storage=yes)_

Adds Cloudflare R2 object storage with file metadata in D1 and a transactional file service.

**Inputs**
- `PROJECT_PATH`
- `R2_BUCKET_NAME` (default: `<project-name>-files`)
- `R2_BINDING` (default: `APP_FILES`)
- `D1_BINDING` (default: `APP_DB`)

**Outputs**
- `app/services/file.service.ts` — upload/delete service with transactional rollback on metadata failure
- `db/migrations/<file-migration>` — `files` metadata table migration

**Side effects**
- Updates `docs/architecture.md` — R2 integration point and binding
- Updates `docs/data-model.md` — `files` metadata table

---

### `adding-ai` _(when ai=yes)_

Adds the Vercel AI SDK with an OpenAI provider for text generation, structured output, and image generation.

**Inputs**
- `PROJECT_PATH`
- `OPENAI_API_KEY` — from macOS Keychain or user input
- Text model ID and image model ID (defaulted or user-supplied)

**Outputs**
- `app/services/ai.service.ts` — AI service wrapper with provider configuration and `ai: AIService` exposed on app context
- `docs/conventions/ai-service.md` — patterns for text generation, structured output, and image generation

**Side effects**
- Updates `docs/architecture.md` — AI service integration point and model bindings

---

### `adding-landing-page` _(when landing_page=yes)_

Adds a public-facing landing page with Hero, Features, and CTA sections.

**Inputs**
- `PROJECT_PATH`
- `docs/prd.md` — for product name, problem statement, and key features (optional; user brief used as fallback)

**Outputs**
- `app/routes/public-layout.tsx`, `app/routes/home.tsx`
- `app/components/landing/Hero.tsx`, `Features.tsx`, `CTASection.tsx`
- `tests/unit/routes/home.test.tsx`
- `docs/conventions/landing-page.md` — landing page layout and component patterns

**Side effects**
- Updates `docs/architecture.md` — public layout route group and landing page sections

---

### `adding-legal-pages` _(when legal_pages=yes)_

Adds Impressum, Privacy Policy, and Terms of Service pages. Requires `adding-landing-page`.

**Inputs**
- `PROJECT_PATH`
- `OPERATOR_NAME`, `OPERATOR_ADDRESS`, `OPERATOR_EMAIL`, `OPERATOR_COUNTRY`
- `INCLUDE_IMPRESSUM`, `INCLUDE_PRIVACY_POLICY`, `INCLUDE_TERMS` — booleans selecting which pages to generate

**Outputs**
- `app/routes/impressum.tsx`, `app/routes/privacy-policy.tsx`, `app/routes/terms.tsx` — one file per enabled flag

**Side effects**
- Updates `docs/architecture.md` — legal routes registered under the public layout group

**Phase complete when** `pnpm dev` starts without errors, `docs/architecture.md` lists every capability with its integration point, `docs/data-model.md` reflects all foundation tables, `docs/conventions/` contains entries from each skill, and `AGENTS.md` is updated.

---

## Phase 3 — Feature Planning

**Goal:** Define and approve the feature set before any product-specific code is written.

Product Builder proposes a list of features that deliver the first usable version, ordered by dependency. The user approves, reorders, adds, or removes features — no planning begins until the feature list is approved.

After approval, `docs/features/manifest.json` is created with all features set to `listed`. The manifest tracks every feature through its lifecycle:

| Status | Meaning | Set by |
| --- | --- | --- |
| `listed` | In the manifest, no spec yet | `creating-products` |
| `ready` | Spec written and approved | `planning-features` |
| `implementing` | Implementation in progress | `implementing-features` |
| `implemented` | Code written, needs verification | `implementing-features` |
| `verified` | Passed verification | `verifying-features` |
| `blocked` | Needs user input | any skill |

### `planning-features`

**Inputs**
- Feature description in user terms
- `docs/prd.md` — product context
- `docs/data-model.md` — existing entities and relationships
- Existing feature specs and codebase for dependency context

**Outputs**
- `docs/features/NN-short-name.spec.md` — feature spec with database changes, DAOs, queries, services, routes, components, and acceptance criteria (written after user approves the presented spec)
- `docs/features/manifest.json` — created on first feature with all approved features set to `listed`

**Side effects**
- Updates `docs/features/manifest.json` — feature entry status advanced from `listed` to `ready`

**Phase complete when** every feature in the manifest has status `ready` (or `blocked` with a documented reason) — no feature has status `listed`.

---

## Phase 4 — Feature Implementation

**Goal:** Implement every feature from its spec.

For each `ready` feature in manifest id order, respecting `depends_on`: implement the code, then commit before moving to the next.

### `implementing-features`

**Inputs**
- `docs/features/NN-short-name.spec.md` — the approved feature spec
- `docs/data-model.md` — current schema state
- `docs/architecture.md` — design decisions and integration log
- `docs/conventions/` — coding patterns to follow

**Outputs**
- `app/db/schema.ts` — updated with new or changed entities
- `db/migrations/<feature-migration>` — migration file (if schema changed)
- `app/db/daos/<entity>.dao.ts` — one file per new entity
- `app/db/queries/<parent>-<child>.query.ts` — cross-table read queries
- `app/services/<entity>.service.ts` — business logic services
- `app/routes/<route>.tsx` — one file per new route
- Test files under `tests/integration/db/daos/`, `tests/integration/db/queries/`, `tests/integration/services/`, `tests/unit/routes/`

**Side effects**
- Updates `docs/data-model.md` — new entities and relationships
- Updates `docs/architecture.md` — Implementation Log entry
- Updates `docs/conventions/` — new patterns introduced by the feature (as needed)
- Updates `docs/features/manifest.json` — status set to `implementing` then `implemented`

**Phase complete when** every feature has status `implemented` (or `blocked` with a documented reason).

---

## Phase 5 — Verification

**Goal:** Verify every feature against its spec and acceptance criteria.

For each `implemented` feature in manifest id order: verify, then iterate if verification fails — `implementing-features` re-runs targeting the failed criteria, then re-verifies. Repeats until the spec passes or user input is needed.

### `verifying-features`

**Inputs**
- `docs/features/NN-short-name.spec.md` — the feature spec to verify against
- Implementation code in the project
- `docs/prd.md`, `docs/data-model.md`, `docs/architecture.md`
- Test files and `docs/conventions/`

**Outputs**
- Verification report (in-chat): acceptance criteria evaluation, deviations, missing items, inconsistencies
- Verdict: **Pass**, **Pass with notes**, or **Fail**

**Side effects**
- Updates `docs/features/manifest.json` — status set to `verified` (on pass only)

**Phase complete when** every feature has status `verified` (or `blocked` with a documented reason).

---

## Phase 6 — Testing

**Goal:** Run E2E tests and confirm the full project builds cleanly.

> **Prerequisite:** Chrome DevTools MCP must be connected before Phase 6 begins. The `testing-features` skill hard-stops if `navigate_page`, `click`, `fill`, and `screenshot` tools are unavailable.

If E2E tests fail, issues are fixed with `implementing-features` and `testing-features` re-runs. After E2E, run `pnpm typecheck`, `pnpm lint`, and `pnpm build` — fix any failures and re-run until all pass.

### `testing-features`

**Inputs**
- All `docs/features/*.spec.md` files
- Chrome DevTools MCP connection (hard-stop if unavailable)
- Test user credentials (default: `max@example.com` / `1234qwer`)
- Running dev server (started by the skill if not already running)

**Outputs**
- `docs/e2e/test-plan.md` — full test plan with routes, steps, and expected results per feature
- `docs/e2e/screenshots/` — screenshots captured during test execution
- E2E test report (in-chat): per-feature and per-step pass/fail status

**Phase complete when** E2E tests pass and typecheck, lint, and build all exit 0.

---

## Final Summary

Product Builder commits the final state and summarizes: foundation skills used, features implemented, commit hash, verification results, E2E test results, and any open questions from `docs/architecture.md`.

---

## Reference Skill

### `react-router-patterns`

Reference guide for React Router v7 patterns used by `planning-features` and `implementing-features` when generating routes.

**Inputs**
- Topic selection (which pattern to look up)

**Outputs**
- In-chat patterns and gotchas for: adding routes, loading data, form validation with Conform/Zod, navigation, protected routes, pending/optimistic UI, error boundaries, resource routes, and app-level context

---

## Summary Table

| Skill | Phase | Outputs | Side effects (`docs/` updates) |
| --- | --- | --- | --- |
| `creating-products` | All | bootstrapped project, `docs/features/manifest.json` | all sub-skill `docs/` updates |
| `preparing-repositories` | 0 | `LOCAL_REPOSITORY_PATH`, `REPOSITORY_STATUS` | — |
| `writing-prd` | 1 | `docs/prd.md` | — |
| `scaffolding-project` | 2 | full project tree, `docs/architecture.md`, `docs/conventions/routes.md` | — |
| `adding-database` | 2 | `drizzle.config.ts`, `app/db/schema.ts`, `app/context.ts`, `db/migrations/`, test configs, `docs/data-model.md`, `docs/conventions/data-access.md`, `docs/conventions/testing.md` | `docs/architecture.md` |
| `adding-authentication` | 2 | auth routes, auth service, auth migration, test files | `docs/architecture.md`, `docs/data-model.md`, `docs/conventions/routes.md` |
| `adding-file-storage` | 2 | `app/services/file.service.ts`, file migration | `docs/architecture.md`, `docs/data-model.md` |
| `adding-ai` | 2 | `app/services/ai.service.ts`, `docs/conventions/ai-service.md` | `docs/architecture.md` |
| `adding-landing-page` | 2 | landing routes, landing components, landing tests, `docs/conventions/landing-page.md` | `docs/architecture.md` |
| `adding-legal-pages` | 2 | legal route files | `docs/architecture.md` |
| `planning-features` | 3 | `docs/features/NN-*.spec.md`, `docs/features/manifest.json` | `docs/features/manifest.json` (status: `listed` → `ready`) |
| `implementing-features` | 4–6 | schema, DAOs, queries, services, routes, test files | `docs/data-model.md`, `docs/architecture.md`, `docs/conventions/`, `docs/features/manifest.json` |
| `verifying-features` | 5 | verification report (in-chat) | `docs/features/manifest.json` (status: → `verified`, on pass) |
| `testing-features` | 6 | `docs/e2e/test-plan.md`, `docs/e2e/screenshots/`, E2E report (in-chat) | — |
| `react-router-patterns` | 3–4 | patterns reference (in-chat) | — |

## Key References

| Reference | Purpose |
| --- | --- |
| [feature-manifest.md](../plugins/product-builder/skills/creating-products/references/feature-manifest.md) | Manifest schema, field definitions, and status lifecycle |
| [data-access-architecture.md](../plugins/product-builder/shared/references/data-access-architecture.md) | DAO, query, service, and transaction conventions |
| [test-patterns.md](../plugins/product-builder/skills/implementing-features/references/test-patterns.md) | DAO, query, and service test templates used during implementation |
| [architecture-template.md](../plugins/product-builder/shared/templates/architecture-template.md) | Template for `docs/architecture.md` |
| [data-model-template.md](../plugins/product-builder/shared/templates/data-model-template.md) | Template for `docs/data-model.md` |
| [convention-template.md](../plugins/product-builder/shared/templates/convention-template.md) | Template for convention files in `docs/conventions/` |
