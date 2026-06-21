# Product Builder: Skills Process Reference

This document describes each skill in the `product-builder` plugin — its inputs, outputs, and side effects.

- **Outputs** — files created by the skill (including new `docs/` files) and logical values returned to the caller.
- **Side effects** — updates to existing files inside `docs/`. Skills with no `docs/` updates have no side effects listed.

See [process.md](process.md) for the phase-by-phase orchestration narrative.

---

## Orchestrator

### `creating-products`

Drives the full product lifecycle across six phases by invoking all other skills in sequence.

**Inputs**
- Product idea or problem description (from the user)
- Resolved outputs from each sub-skill as phases complete

**Outputs**
- Fully bootstrapped, documented, and verified project in a local git repository
- `docs/features/manifest.json` — created with approved features set to `listed`
- Final summary: foundation skills used, features implemented, commit hash, verification and E2E results, open questions

**Side Effects**
- All `docs/` updates produced by the sub-skills it invokes

---

## Phase 0 — Repository

### `preparing-repositories`

Creates or locates a GitHub repository and prepares a clean local clone.

**Inputs**
- `REPOSITORY` — `<owner>/<repo>` GitHub slug or full URL
- `LOCAL_FOLDER` — parent directory for the local clone

**Outputs**
- `LOCAL_REPOSITORY_PATH` — absolute path to the prepared local repository
- `REPOSITORY_STATUS` — one of `existing-local`, `cloned`, or `created-and-cloned`

---

## Phase 1 — PRD

### `writing-prd`

Interviews the user and writes a complete Product Requirements Document.

**Inputs**
- Product idea or problem description (from the user)
- User answers to interview questions on: target users, primary workflow, data persistence, privacy model, accounts/roles, file uploads, must-have pages, external services, v1 exclusions, success metrics
- Existing `docs/prd.md` if updating (optional)

**Outputs**
- `docs/prd.md` — product overview, user personas, problem statement, primary workflow, entry-point flow, must-have pages, data ownership model, and approved Foundation Capabilities table

---

## Phase 2 — Foundation

### `scaffolding-project`

Bootstraps the base project from an empty repository.

**Inputs**
- `LOCAL_REPOSITORY_PATH` — from `preparing-repositories`
- `REPOSITORY_STATUS` — from `preparing-repositories`

**Outputs**
- Full project tree: `package.json`, `pnpm-lock.yaml`, `tsconfig.json`, `vite.config.ts`, `wrangler.jsonc`, `tailwind.config.ts`, `components.json`, `app/root.tsx`, `app/routes.ts`, `app/styles/globals.css`, `workers/app.ts`, `public/`, `README.md`, `AGENTS.md`
- `docs/architecture.md` — initial stack and structure documentation
- `docs/conventions/routes.md` — initial routing conventions

---

### `adding-database`

Adds Cloudflare D1 with Drizzle ORM, migrations, and Worker context integration.

**Inputs**
- `PROJECT_PATH` — absolute path to a scaffolded Product Builder project
- `D1_DATABASE_NAME` — Cloudflare D1 database name (auto-derived if omitted)
- `D1_BINDING` — binding name (default: `APP_DB`)
- `.env` values: `CLOUDFLARE_ACCOUNT_ID`, `CLOUDFLARE_DATABASE_ID`, `CLOUDFLARE_D1_TOKEN`

**Outputs**
- `drizzle.config.ts`, `app/db/schema.ts`, `app/context.ts` — Drizzle config, initial schema, app context with `db: DrizzleD1Database`
- `db/migrations/` — initial migration files
- `tsconfig.integration.json`, `tsconfig.cloudflare.json`, `tests/integration/vitest.config.ts` — test infrastructure
- `docs/data-model.md` — entities and relationships from the initial schema
- `docs/conventions/data-access.md` — DAO, query, and service patterns
- `docs/conventions/testing.md` — directory structure, test type inference, `applyMigrations`/`getTestDb` patterns, and layer-specific testing guidance

**Side Effects**
- Updates `docs/architecture.md` — D1 integration point and binding

---

### `adding-authentication`

Adds Better Auth email-and-password authentication with protected routes and session handling.

**Inputs**
- `PROJECT_PATH` — absolute path to a Product Builder project with D1
- `D1_BINDING` — database binding name (default: `APP_DB`)
- `AUTH_COOKIE_PREFIX` — cookie prefix for Better Auth (default: `App`)
- `AUTH_SECRET` — generated via `openssl rand -base64 32`

**Outputs**
- `app/services/auth.service.ts`, `app/routes/auth.tsx`, `app/routes/login.tsx`, `app/routes/signup.tsx`, `app/routes/logout.tsx` — auth service and routes
- `db/migrations/<auth-migration>` — auth tables migration
- `tests/unit/routes/login.test.tsx`, `tests/unit/routes/signup.test.tsx` — route unit tests

**Side Effects**
- Updates `docs/architecture.md` — auth integration and session handling
- Updates `docs/data-model.md` — `users`, `sessions`, `accounts`, `verifications` tables
- Updates `docs/conventions/routes.md` — protected route patterns

---

### `adding-file-storage`

Adds Cloudflare R2 object storage with file metadata in D1 and a transactional file service.

**Inputs**
- `PROJECT_PATH` — absolute path to a Product Builder project with D1
- `R2_BUCKET_NAME` — R2 bucket name (default: `<project-name>-files`)
- `R2_BINDING` — binding name (default: `APP_FILES`)
- `D1_BINDING` — database binding name (default: `APP_DB`)

**Outputs**
- `app/services/file.service.ts` — upload/delete service with transactional rollback on metadata failure
- `db/migrations/<file-migration>` — `files` metadata table migration

**Side Effects**
- Updates `docs/architecture.md` — R2 integration point and binding
- Updates `docs/data-model.md` — `files` metadata table

---

### `adding-ai`

Adds the Vercel AI SDK with an OpenAI provider for text generation, structured output, and image generation.

**Inputs**
- `PROJECT_PATH` — absolute path to an existing Product Builder project
- `OPENAI_API_KEY` — from macOS Keychain or user input
- Text model ID and image model ID (defaulted or user-supplied)

**Outputs**
- `app/services/ai.service.ts` — AI service wrapper with provider configuration and `ai: AIService` exposed on app context
- `docs/conventions/ai-service.md` — patterns for text generation, structured output, and image generation

**Side Effects**
- Updates `docs/architecture.md` — AI service integration point and model bindings

---

### `adding-landing-page`

Adds a public-facing landing page with Hero, Features, and CTA sections.

**Inputs**
- `PROJECT_PATH` — absolute path to an existing Product Builder project
- `docs/prd.md` — for product name, problem statement, and key features (optional; user brief used as fallback)

**Outputs**
- `app/routes/public-layout.tsx`, `app/routes/home.tsx` — public layout and landing page routes
- `app/components/landing/Hero.tsx`, `Features.tsx`, `CTASection.tsx` — landing page section components
- `tests/unit/routes/home.test.tsx` — landing page route tests
- `docs/conventions/landing-page.md` — landing page layout and component patterns

**Side Effects**
- Updates `docs/architecture.md` — public layout route group and landing page sections

---

### `adding-legal-pages`

Adds Impressum, Privacy Policy, and Terms of Service pages with real operator information.

**Inputs**
- `PROJECT_PATH` — absolute path to a Product Builder project with a public layout (requires `adding-landing-page`)
- `OPERATOR_NAME`, `OPERATOR_ADDRESS`, `OPERATOR_EMAIL`, `OPERATOR_COUNTRY` — legal operator details
- `INCLUDE_IMPRESSUM`, `INCLUDE_PRIVACY_POLICY`, `INCLUDE_TERMS` — booleans selecting which pages to generate

**Outputs**
- `app/routes/impressum.tsx`, `app/routes/privacy-policy.tsx`, `app/routes/terms.tsx` — one file per enabled flag

**Side Effects**
- Updates `docs/architecture.md` — legal routes registered under the public layout group

---

## Phase 3 — Feature Planning

### `planning-features`

Plans a feature end-to-end and writes a numbered spec file.

**Inputs**
- Feature description in user terms
- `docs/prd.md` — product context
- `docs/data-model.md` — existing entities and relationships
- Existing feature specs and codebase for dependency context

**Outputs**
- `docs/features/NN-short-name.spec.md` — feature spec with database changes, DAOs, queries, services, routes, components, and acceptance criteria (written after user approves the presented spec)
- `docs/features/manifest.json` — created on first feature with all approved features set to `listed`

**Side Effects**
- Updates `docs/features/manifest.json` — feature entry status advanced from `listed` to `ready`

---

## Phase 4 — Feature Implementation

### `implementing-features`

Implements a feature spec as a full vertical slice: schema, DAOs, queries, services, routes, components, and tests.

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

**Side Effects**
- Updates `docs/data-model.md` — new entities and relationships
- Updates `docs/architecture.md` — Implementation Log entry
- Updates `docs/conventions/` — new patterns introduced by the feature (as needed)
- Updates `docs/features/manifest.json` — status set to `implementing` then `implemented`

---

## Phase 5 — Verification

### `verifying-features`

Verifies a feature implementation against its spec and acceptance criteria.

**Inputs**
- `docs/features/NN-short-name.spec.md` — the feature spec to verify against
- Implementation code in the project
- `docs/prd.md`, `docs/data-model.md`, `docs/architecture.md`
- Test files and `docs/conventions/`

**Outputs**
- Verification report (in-chat): acceptance criteria evaluation, deviations, missing items, inconsistencies
- Verdict: **Pass**, **Pass with notes**, or **Fail**

**Side Effects**
- Updates `docs/features/manifest.json` — status set to `verified` (on pass only)

---

### `testing-features`

Generates a happy-path E2E test plan from all feature specs and executes it in a browser via Chrome DevTools MCP.

**Inputs**
- All `docs/features/*.spec.md` files
- Chrome DevTools MCP connection (hard-stop if unavailable)
- Test user credentials (default: `max@example.com` / `1234qwer`)
- Running dev server (started by the skill if not already running)

**Outputs**
- `docs/e2e/test-plan.md` — full test plan with routes, steps, and expected results per feature
- `docs/e2e/screenshots/` — screenshots captured during test execution
- E2E test report (in-chat): per-feature and per-step pass/fail status

---

## Reference Skill

### `react-router-patterns`

Reference guide for React Router v7 patterns used by `planning-features` and `implementing-features` when generating routes.

**Inputs**
- Topic selection (which pattern to look up)

**Outputs**
- In-chat patterns and gotchas for: adding routes, loading data, form validation with Conform/Zod, navigation, protected routes, pending/optimistic UI, error boundaries, resource routes, and app-level context

---

## Summary

| Skill | Outputs | Side Effects (`docs/` updates) |
| --- | --- | --- |
| `creating-products` | bootstrapped project, `docs/features/manifest.json` | all sub-skill `docs/` updates |
| `preparing-repositories` | `LOCAL_REPOSITORY_PATH`, `REPOSITORY_STATUS` | — |
| `writing-prd` | `docs/prd.md` | — |
| `scaffolding-project` | full project tree, `docs/architecture.md`, `docs/conventions/routes.md` | — |
| `adding-database` | `drizzle.config.ts`, `app/db/schema.ts`, `app/context.ts`, `db/migrations/`, test configs, `docs/data-model.md`, `docs/conventions/data-access.md`, `docs/conventions/testing.md` | `docs/architecture.md` |
| `adding-authentication` | auth routes, auth service, auth migration, test files | `docs/architecture.md`, `docs/data-model.md`, `docs/conventions/routes.md` |
| `adding-file-storage` | `app/services/file.service.ts`, file migration | `docs/architecture.md`, `docs/data-model.md` |
| `adding-ai` | `app/services/ai.service.ts`, `docs/conventions/ai-service.md` | `docs/architecture.md` |
| `adding-landing-page` | landing routes, landing components, landing tests, `docs/conventions/landing-page.md` | `docs/architecture.md` |
| `adding-legal-pages` | legal route files | `docs/architecture.md` |
| `planning-features` | `docs/features/NN-*.spec.md`, `docs/features/manifest.json` | `docs/features/manifest.json` (status: `listed` → `ready`) |
| `implementing-features` | schema, DAOs, queries, services, routes, test files | `docs/data-model.md`, `docs/architecture.md`, `docs/conventions/`, `docs/features/manifest.json` |
| `verifying-features` | verification report (in-chat) | `docs/features/manifest.json` (status: → `verified`, on pass) |
| `testing-features` | `docs/e2e/test-plan.md`, `docs/e2e/screenshots/`, E2E report (in-chat) | — |
| `react-router-patterns` | patterns reference (in-chat) | — |
