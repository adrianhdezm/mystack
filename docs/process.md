# Product Builder: Process Reference

End-to-end reference for the two orchestrated flows: [`creating-products`](../plugins/product-builder/skills/creating-products/SKILL.md) for building a product from scratch, and [`adding-features`](../plugins/product-builder/skills/adding-features/SKILL.md) for extending a live product with new functionality.

Both flows share the same per-feature cycle: **plan → implement → verify → test**, driven by numbered feature specs and tracked in `docs/features/manifest.json`.

---

## State files

| File | Purpose |
| --- | --- |
| `docs/context.json` | Infrastructure state: repository, project, operator, capability statuses. Created by `preparing-repositories` before any other skill runs. Never written by feature skills. |
| `docs/prd.md` | Living product requirements document. Written in create mode by `writing-prd`, extended in update mode on each new feature addition. |
| `docs/features/manifest.json` | Feature and task lifecycle tracker. Created in Phase 3. The authoritative source of truth for all feature and task progress. |

### Capability statuses (`docs/context.json`)

| Status    | Meaning                               | Set by           |
| --------- | ------------------------------------- | ---------------- |
| `skipped` | Not needed for this product (default) | `writing-prd`    |
| `planned` | Approved in the PRD interview         | `writing-prd`    |
| `ready`   | Foundation skill ran and wired up     | `adding-*` skill |

### Feature statuses (`manifest.json`)

| Status | Meaning | Set by |
| --- | --- | --- |
| `listed` | Registered, no spec yet | `creating-products`, `adding-features` |
| `ready` | Spec written and tasks populated | `planning-features` |
| `implementing` | At least one task in progress | `implementing-features` |
| `implemented` | All tasks done | `implementing-features` |
| `verified` | Passed all acceptance criteria | `verifying-features` |
| `blocked` | Needs user input | any skill |

Feature status is always **derived** from task state — never set manually when tasks are present.

### Task statuses (`manifest.json`)

| Status         | Meaning                                     |
| -------------- | ------------------------------------------- |
| `pending`      | Not yet started                             |
| `implementing` | In progress                                 |
| `done`         | Implemented and committed                   |
| `blocked`      | Needs user input (written before advancing) |

---

## Creating a Product — `creating-products`

Drives four phases from an empty repository to a working, verified, E2E-tested product. Resume is data-driven: each phase checks a signal in `docs/context.json` or `docs/features/manifest.json` — no skill flags.

| Phase | Resume: skip when |
| --- | --- |
| 0 — Repository | `repository.local_path` set and path exists on disk |
| 1 — PRD | `docs/prd.md` exists and is non-empty |
| 2 — Foundation | `project.name` set and every `planned` capability is `ready` |
| 3 — Feature List | manifest exists with at least one non-`listed` feature |
| 4 — Per-Feature Loop | all features `verified` or `blocked` |

---

### Phase 0 — Repository

**Goal:** Establish an empty GitHub repository and a local clone.

#### `preparing-repositories`

**Inputs**

- `REPOSITORY` — `<owner>/<repo>` GitHub slug or full URL
- `LOCAL_FOLDER` — parent directory for the local clone

**Outputs**

- `LOCAL_REPOSITORY_PATH` — absolute path to the prepared repository
- `REPOSITORY_STATUS` — `existing-local`, `cloned`, or `created-and-cloned`
- `docs/context.json` — created at `LOCAL_REPOSITORY_PATH/docs/context.json` with `repository.*` fields

---

### Phase 1 — PRD

**Goal:** Interview the user, derive foundation capabilities, and write `docs/prd.md`.

#### `writing-prd` (create mode)

Covers: target users, primary workflow, data persistence, privacy model, accounts, file uploads, must-have pages, external services, v1 exclusions, success metrics. Prefers inference over questions.

After the interview, derives each capability and presents the table for user approval. On approval, writes `docs/prd.md` and sets each capability to `planned` or `skipped` in `docs/context.json`.

**Outputs**

- `docs/prd.md` — problem statement, user stories, UI flows, out-of-scope, success metrics, Foundation Capabilities table
- `docs/context.json` — `capabilities.*` set to `planned` or `skipped`

---

### Phase 2 — Foundation

**Goal:** Scaffold the base project and run every `planned` capability skill.

When both `landing_page` and `authentication` are planned, `adding-landing-page` runs first so the public layout route exists before auth routes are registered.

| Capability       | Skill                   | Depends On   |
| ---------------- | ----------------------- | ------------ |
| `database`       | `adding-database`       | —            |
| `authentication` | `adding-authentication` | database     |
| `file_storage`   | `adding-file-storage`   | database     |
| `ai`             | `adding-ai`             | —            |
| `landing_page`   | `adding-landing-page`   | —            |
| `legal_pages`    | `adding-legal-pages`    | landing_page |

#### `scaffolding-project`

**Outputs**

- Full project tree: `package.json`, `pnpm-lock.yaml`, `tsconfig.json`, `vite.config.ts`, `wrangler.jsonc`, `tailwind.config.ts`, `components.json`, `app/root.tsx`, `app/routes.ts`, `workers/app.ts`, `README.md`, `AGENTS.md`
- `docs/architecture.md`, `docs/conventions/routes.md`
- `docs/context.json` — `project.*` fields written

#### `adding-database` _(database=planned)_

**Outputs**

- `drizzle.config.ts`, `app/db/schema.ts`, `app/context.ts`, `db/migrations/`
- Test configs: `tsconfig.integration.json`, `tests/integration/vitest.config.ts`
- `docs/data-model.md`, `docs/conventions/data-access.md`, `docs/conventions/testing.md`
- `docs/context.json` — `capabilities.database = "ready"`, `project.d1_database_name`

#### `adding-authentication` _(authentication=planned)_

**Outputs**

- `app/services/auth.service.ts`, `app/routes/auth.tsx`, `app/routes/login.tsx`, `app/routes/signup.tsx`, `app/routes/logout.tsx`
- `db/migrations/<auth-migration>`, unit tests for login/signup routes
- `docs/context.json` — `capabilities.authentication = "ready"`

#### `adding-file-storage` _(file_storage=planned)_

**Outputs**

- `app/services/file.service.ts`, `db/migrations/<file-migration>`
- `docs/context.json` — `capabilities.file_storage = "ready"`, `project.r2_bucket_name`

#### `adding-ai` _(ai=planned)_

**Outputs**

- `app/services/ai.service.ts`, `docs/conventions/ai-service.md`
- `docs/context.json` — `capabilities.ai = "ready"`

#### `adding-landing-page` _(landing_page=planned)_

**Outputs**

- `app/routes/public-layout.tsx`, `app/routes/home.tsx`
- `app/components/landing/Hero.tsx`, `Features.tsx`, `CTASection.tsx`
- `tests/unit/routes/home.test.tsx`, `docs/conventions/landing-page.md`
- `docs/context.json` — `capabilities.landing_page = "ready"`

#### `adding-legal-pages` _(legal_pages=planned)_

**Outputs**

- `app/routes/impressum.tsx`, `app/routes/privacy-policy.tsx`, `app/routes/terms.tsx` (per flags)
- `docs/context.json` — `capabilities.legal_pages = "ready"`, `operator.*`

**Phase complete when** `pnpm dev` starts, every `planned` capability is `ready`, `docs/architecture.md` lists every integration point, `docs/data-model.md` reflects all foundation tables, and `AGENTS.md` is updated.

---

### Phase 3 — Feature List

**Goal:** Approve the full feature list and register all entries in the manifest.

Derives features from `docs/prd.md`. Proposes title, one-line description, and `depends_on` for each. Gets user approval before writing. Creates `docs/features/manifest.json` with all features at `listed`, `tasks: []`.

This phase is structural only — no specs are written here.

---

### Phase 4 — Per-Feature Loop

**Goal:** Drive every feature through plan → implement → verify → test, in dependency order.

For each feature whose `depends_on` are all `verified`, run steps 4a–4d:

#### Step 4a — `planning-features`

Reads PRD, data model, architecture, existing specs, and codebase. Writes one spec file per feature: `docs/features/NN-name.spec.md`. The spec contains a **Tasks** section — each task is a vertical slice with layers, `depends_on`, and acceptance criteria. Updates manifest: feature → `ready`, `tasks[]` populated at `pending`.

**Outputs**

- `docs/features/NN-name.spec.md`
- `docs/features/manifest.json` — feature `ready`, tasks `pending`

#### Step 4b — `implementing-features`

Works through tasks in dependency order. For each task: sets `implementing`, builds the full vertical slice (schema, migrations, DAOs, queries, services, routes, components, tests), verifies task acceptance criteria, sets `done`, commits. Derives feature status from task state. Runs `pnpm typecheck` and `pnpm test` after all tasks complete.

**Outputs per task**

- Schema changes, `db/migrations/`, `app/db/daos/`, `app/db/queries/`, `app/services/`, `app/routes/`, test files
- Commit per task, referencing task id and title

**Side effects**

- `docs/data-model.md` — updated after schema changes
- `docs/architecture.md` — Implementation Log entry
- `docs/features/manifest.json` — task statuses, feature status derived

#### Step 4c — `verifying-features`

Read-only. Confirms all tasks are `done`, checks implementation against every task's acceptance criteria, runs `pnpm typecheck`, `pnpm lint`, `pnpm test`, `pnpm build`. Produces a structured report with Pass / Pass with notes / Fail verdict.

**Outputs**

- Verification report (in-chat) with per-task acceptance criteria status
- `docs/features/manifest.json` — feature → `verified` on pass

If verification fails: re-run `implementing-features` targeting failed criteria, then re-verify. Set to `blocked` after two failed attempts.

#### Step 4d — `testing-features`

Guards: feature must be `verified`; Chrome DevTools MCP must be connected. Appends a feature section to `docs/e2e/test-plan.md` (creates file on first run). Gets user approval, starts `pnpm dev`, executes steps via Chrome DevTools MCP, stops server, reports.

**Outputs**

- `docs/e2e/test-plan.md` — extended with feature section (existing sections preserved)
- `docs/e2e/screenshots/NN-feature-name/` — screenshots per step
- E2E test report (in-chat)

If E2E fails: re-implement → re-verify → re-test. Set to `blocked` after two failed attempts.

**After all features reach a terminal state**, run `pnpm build` and `pnpm lint` — fix and re-run until both pass.

---

## Adding a Feature — `adding-features`

Drives the full cycle for a single new feature on a product that already has `creating-products` completed. One feature per run.

**Guard:** `project.name` must be set and no capability may be stuck at `"planned"` in `docs/context.json`.

**Input detection:** if no feature is described, proposes the first `listed` feature whose `depends_on` are all `verified`. If accepted → skip Phases 1 and 2. If rejected or no candidate → ask user to describe the new feature.

| Phase | Description |
| --- | --- |
| 1 — Update PRD | `writing-prd` in update mode. Feature description passed in — not re-asked. Interview focused on scoping, edge cases, exclusions. Appends to `docs/prd.md` with `<!-- Feature: name -->` markers. |
| 2 — Manifest | Propose title, description, `depends_on` derived from PRD. User approval required. Adds feature at `listed`, `tasks: []`. |
| 3 — Plan Spec | `planning-features` — writes spec with Tasks section, updates manifest to `ready`. |
| 4 — Implement | `implementing-features` — task-by-task, commit per task, `pnpm typecheck` + `pnpm test` after completion. |
| 5 — Verify | `verifying-features` — if fails, re-implement → re-verify once. Second failure → `blocked`. |
| 6 — Test | `testing-features` — E2E for this feature. If fails, re-implement → re-verify → re-test once. Second failure → `blocked`. Then `pnpm build`. |

---

## Summary Table

| Skill | Flow | Key outputs |
| --- | --- | --- |
| `creating-products` | Creating | Orchestrates all phases; final summary with commit hash |
| `adding-features` | Adding | Orchestrates single-feature cycle; final summary |
| `preparing-repositories` | Creating Ph.0 | `docs/context.json` (repository.\*) |
| `writing-prd` | Creating Ph.1, Adding Ph.1 | `docs/prd.md`; `capabilities.*` planned/skipped (create) or appended (update) |
| `scaffolding-project` | Creating Ph.2 | Full project tree; `docs/context.json` (project.\*) |
| `adding-database` | Creating Ph.2 | Schema, migrations, test configs, `docs/data-model.md`; capabilities.database ready |
| `adding-authentication` | Creating Ph.2 | Auth routes, migration; capabilities.authentication ready |
| `adding-file-storage` | Creating Ph.2 | File service, migration; capabilities.file_storage ready |
| `adding-ai` | Creating Ph.2 | AI service; capabilities.ai ready |
| `adding-landing-page` | Creating Ph.2 | Landing routes and components; capabilities.landing_page ready |
| `adding-legal-pages` | Creating Ph.2 | Legal routes; capabilities.legal_pages ready, operator.\* |
| `planning-features` | Ph.4a / Adding Ph.3 | `docs/features/NN-*.spec.md`; manifest feature→ready, tasks→pending |
| `implementing-features` | Ph.4b / Adding Ph.4 | Schema, DAOs, queries, services, routes, tests; manifest tasks→done, feature→implemented |
| `verifying-features` | Ph.4c / Adding Ph.5 | Verification report (in-chat); manifest feature→verified |
| `testing-features` | Ph.4d / Adding Ph.6 | `docs/e2e/test-plan.md`, screenshots, E2E report (in-chat) |
| `react-router-patterns` | Planning + Implementation | Route, loader, action, and page patterns (in-chat) |

## Key References

| Reference | Purpose |
| --- | --- |
| [context-schema.md](../plugins/product-builder/shared/references/context-schema.md) | `docs/context.json` schema, capability statuses, field ownership |
| [feature-manifest.md](../plugins/product-builder/skills/creating-products/references/feature-manifest.md) | Manifest schema, feature/task status lifecycle, derived status rules |
| [data-access-architecture.md](../plugins/product-builder/shared/references/data-access-architecture.md) | DAO, query, service, and transaction conventions |
| [test-patterns.md](../plugins/product-builder/skills/implementing-features/references/test-patterns.md) | DAO, query, and service test templates |
| [architecture-template.md](../plugins/product-builder/shared/templates/architecture-template.md) | Template for `docs/architecture.md` |
| [data-model-template.md](../plugins/product-builder/shared/templates/data-model-template.md) | Template for `docs/data-model.md` |
| [convention-template.md](../plugins/product-builder/shared/templates/convention-template.md) | Template for `docs/conventions/` files |
