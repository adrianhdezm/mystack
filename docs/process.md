# Product Builder: Creating Products Process

This document describes the end-to-end process that Product Builder follows when you ask it to turn a product idea into a working application.

## Example Prompt

```
Use Product Builder to create a meal-planning app for busy parents that turns
weekly preferences into grocery lists and quick dinner plans.
```

## Process Overview

The process runs in five phases, orchestrated by the [`creating-products`](../plugins/product-builder/skills/creating-products/SKILL.md) skill. Each phase is a single self-contained goal — it defines the end-state, the approach, and the stop condition in one block. Each phase invokes specialized sub-skills in sequence.

---

### Phase 1 — Interview and Classification

**Goal:** Understand the product, classify its complexity, prepare the repository, and scaffold the base project.

#### 1. Interview

Product Builder asks targeted questions to understand the product before writing any code. It follows the [interview-and-classification](../plugins/product-builder/skills/creating-products/references/interview-and-classification.md) reference to cover:

- Who uses the product and what job they complete.
- The primary workflow from first visit to outcome.
- What data must persist between sessions.
- Privacy model (private, shared, public, admin-only).
- Whether accounts, roles, or protected pages are needed.
- Whether uploads, file imports/exports, or attachments are needed.
- Must-have pages or views for the first version.
- External services or integrations.
- What to exclude from v1.

Product Builder prefers inference over questions — it only asks when the answer materially changes the implementation.

**Meal-planning example:** Product Builder would infer that busy parents need accounts (personal preferences and saved plans), a database (recipes, grocery lists, meal plans), and no file storage for v1. It might ask whether plans are per-household or per-user, and whether recipes come from a built-in set or user-created.

#### 2. Complexity Classification

Based on the interview, the product is classified using the [interview-and-classification](../plugins/product-builder/skills/creating-products/references/interview-and-classification.md) tiers:

| Classification | Database | Authentication | File Storage |
| -------------- | -------- | -------------- | ------------ |
| `simple`       | No       | No             | No           |
| `standard`     | Yes      | Yes            | No           |
| `advanced`     | Yes      | Yes            | Yes          |

AI is independent of classification — `ai=yes` is added when the product needs text generation, structured AI output, image generation, or LLM-powered features.

The classification is presented for user approval before proceeding:

```text
PROJECT_COMPLEXITY: standard
FOUNDATION_CAPABILITIES: database=yes, authentication=yes, file_storage=no, ai=no
RATIONALE: Persistent meal plans and grocery lists with user accounts, no file uploads for v1.
```

**Meal-planning example:** Classified as `standard` — persistent data (meal plans, grocery lists) and user accounts are required, but no file uploads for v1.

#### 3. Repository Preparation

The [`preparing-repositories`](../plugins/product-builder/skills/preparing-repositories/SKILL.md) skill creates or finds the GitHub repository and sets up the local clone.

**Inputs required:**

```
REPOSITORY: <owner>/<repo>          (e.g. adrianhmendez/meal-planner)
LOCAL_FOLDER: <parent-folder>       (e.g. ~/Code)
PRODUCT_IDEA: <short description>
```

#### 4. Code Bootstrap

The [`bootstrapping-code`](../plugins/product-builder/skills/bootstrapping-code/SKILL.md) skill scaffolds the base project:

- pnpm, TypeScript, Vite
- Cloudflare Workers
- React Router v7 (framework mode, SSR)
- Tailwind CSS, shadcn/ui

**Phase 1 is complete when** the user has approved the classification and `pnpm dev` starts without errors in the bootstrapped project directory.

---

### Phase 2 — Foundation

**Goal:** Install all foundation capabilities for the approved classification and verify their documentation.

Foundation skills run in dependency order based on the classification, following the [foundation-capabilities](../plugins/product-builder/skills/creating-products/references/foundation-capabilities.md) mapping:

1. **[`adding-database`](../plugins/product-builder/skills/adding-database/SKILL.md)** — Adds Cloudflare D1 with Drizzle ORM, migrations, and server context.
2. **[`adding-authentication`](../plugins/product-builder/skills/adding-authentication/SKILL.md)** — Adds Better Auth with email/password, session handling, and protected routes.
3. **[`adding-file-storage`](../plugins/product-builder/skills/adding-file-storage/SKILL.md)** _(advanced only)_ — Adds Cloudflare R2 with upload/delete lifecycle and file metadata.
4. **[`adding-ai`](../plugins/product-builder/skills/adding-ai/SKILL.md)** _(when ai=yes)_ — Adds Vercel AI SDK with OpenAI provider for text, structured output, and image generation.

Each foundation skill updates:

- `docs/architecture.md` — stack, structure, and conventions.
- `docs/data-model.md` — entities and relationships from the schema.
- `docs/conventions/` — pattern and anti-pattern files.
- `AGENTS.md` — agent instructions referencing the docs.

**Phase 2 is complete when** `docs/architecture.md` lists every capability with its integration point, `docs/data-model.md` reflects all foundation tables, `docs/conventions/` contains entries from each skill, and `AGENTS.md` is updated.

---

### Phase 3 — Feature Planning

**Goal:** Define and approve the feature set before any product-specific code is written.

#### 5. Feature Proposal

Product Builder proposes a list of features that deliver the first usable version. Each feature has a short title and one-line description, ordered by dependency.

**Meal-planning example:**

1. **Preference Survey** — Collect dietary restrictions, household size, and cuisine preferences.
2. **Meal Plan Generator** — Generate a weekly dinner plan based on preferences.
3. **Grocery List** — Aggregate ingredients from the meal plan into a grouped shopping list.
4. **Plan History** — View and reuse past weekly plans.

The user approves, reorders, adds, or removes features. No planning begins until the feature list is approved.

#### 6. Feature Manifest

After approval, Product Builder creates `docs/features/manifest.json` with all features set to `listed` status. The manifest tracks every feature through its lifecycle, following the [feature-manifest](../plugins/product-builder/skills/creating-products/references/feature-manifest.md) schema:

| Status         | Meaning                          | Set by                  |
| -------------- | -------------------------------- | ----------------------- |
| `listed`       | In the manifest, no spec yet     | `creating-products`     |
| `ready`        | Spec written and approved        | `planning-features`     |
| `implementing` | Implementation in progress       | `implementing-features` |
| `implemented`  | Code written, needs verification | `implementing-features` |
| `verified`     | Passed verification              | `verifying-features`    |
| `blocked`      | Needs user input                 | any skill               |

#### 7. Feature Spec Creation

The [`planning-features`](../plugins/product-builder/skills/planning-features/SKILL.md) skill runs for each feature in id order, producing numbered spec files:

```
docs/features/
├── manifest.json
├── 00-preference-survey.spec.md
├── 01-meal-plan-generator.spec.md
├── 02-grocery-list.spec.md
└── 03-plan-history.spec.md
```

Each spec covers database changes, pages, routes, DAOs, queries, services, shadcn components, and acceptance criteria. Each spec follows the planning-features approval flow before its manifest status moves from `listed` to `ready`.

**Phase 3 is complete when** every feature in the manifest has status `ready` (or `blocked` with a documented reason) — no feature has status `listed`.

---

### Phase 4 — Feature Implementation

**Goal:** Implement every feature from its spec.

For each `ready` feature in manifest id order, respecting `depends_on`:

1. **Implement** — [`implementing-features`](../plugins/product-builder/skills/implementing-features/SKILL.md) writes the code, updates `docs/data-model.md`, `docs/conventions/`, and `docs/architecture.md`, and sets the manifest status to `implementing` then `implemented`.
2. **Commit** — Once implemented, the feature is committed before moving to the next.

**Phase 4 is complete when** every feature has status `implemented` (or `blocked` with a documented reason).

---

### Phase 5 — Verification

**Goal:** Verify every feature, run E2E tests, and confirm the full project builds cleanly. Both `verifying-features` and `testing-features` are mandatory.

For each `implemented` feature in manifest id order:

1. **Verify** — [`verifying-features`](../plugins/product-builder/skills/verifying-features/SKILL.md) checks the implementation against acceptance criteria and sets the manifest status to `verified`.
2. **Iterate** — If verification fails, [`implementing-features`](../plugins/product-builder/skills/implementing-features/SKILL.md) runs again targeting the failed acceptance criteria, then re-verifies. This repeats until the spec passes or user input is needed.

After all features reach `verified`:

3. **E2E Test** — [`testing-features`](../plugins/product-builder/skills/testing-features/SKILL.md) generates a happy-path E2E test plan from all feature specs and executes it in the browser via Chrome DevTools MCP. If E2E tests fail, issues are fixed with `implementing-features` and `testing-features` re-runs.
4. **Build** — Run `pnpm typecheck`, `pnpm lint`, and `pnpm build` — fix any failures and re-run until all pass.

**Phase 5 is complete when** every feature has status `verified` (or `blocked` with a documented reason), E2E tests pass, and typecheck, lint, and build all exit 0.

---

### Final Summary

Product Builder commits the final state and summarizes: foundation skills used, features implemented, commit hash, verification results, E2E test results, and any open questions from `docs/architecture.md`.

---

## Final Project Structure

After all phases complete, the meal-planning app would have this structure:

```
meal-planner/
├── app/
│   ├── components/             # Shared UI components (shadcn/ui)
│   │   ├── ui/                 # shadcn primitives (button, card, input, etc.)
│   │   └── ...                 # Product-specific components
│   ├── db/
│   │   ├── daos/               # Data Access Objects (one per entity)
│   │   ├── queries/            # Relation queries (cross-table reads)
│   │   └── schema.ts           # Drizzle ORM schema (all entities)
│   ├── services/               # Business logic (transaction boundaries, DAO composition)
│   ├── routes/
│   │   ├── _index.tsx          # Landing / home page
│   │   ├── login.tsx           # Login page
│   │   ├── register.tsx        # Registration page
│   │   ├── dashboard.tsx       # User dashboard
│   │   ├── preferences.tsx     # Preference survey
│   │   ├── meal-plans.tsx      # Meal plan list / generator
│   │   ├── meal-plans.$id.tsx  # Meal plan detail
│   │   ├── grocery-list.tsx    # Grocery list view
│   │   └── api.auth.$.ts      # Auth API resource route
│   ├── routes.ts               # Route config
│   ├── context.ts              # App context (db, auth, services)
│   ├── app.css                 # Tailwind styles
│   └── root.tsx                # Root layout
├── db/
│   └── migrations/             # Drizzle D1 migration files
├── workers/
│   └── app.ts                  # Cloudflare Worker entry point
├── docs/
│   ├── architecture.md         # Full stack, structure, conventions, implementation log
│   ├── data-model.md           # All entities, columns, relationships
│   ├── conventions/            # Pattern and anti-pattern files
│   │   ├── data-access.md
│   │   ├── routes.md
│   │   └── ...
│   ├── features/               # Manifest and numbered feature specs
│   │   ├── manifest.json
│   │   ├── 00-preference-survey.spec.md
│   │   ├── 01-meal-plan-generator.spec.md
│   │   ├── 02-grocery-list.spec.md
│   │   └── 03-plan-history.spec.md
│   └── e2e/                    # E2E test plan, report, and screenshots
│       ├── test-plan.md
│       └── screenshots/
├── public/                     # Static assets
├── AGENTS.md                   # Agent instructions referencing docs/
├── package.json
├── tsconfig.json
├── vite.config.ts
├── wrangler.jsonc              # Cloudflare Workers + D1 bindings
├── drizzle.config.ts           # Drizzle ORM config
├── tailwind.config.ts
├── components.json             # shadcn/ui config
└── worker-configuration.d.ts   # Generated Cloudflare env types
```

## Key References

| Reference | Purpose |
| --- | --- |
| [interview-and-classification.md](../plugins/product-builder/skills/creating-products/references/interview-and-classification.md) | Interview questions, classification tiers, and approval format |
| [foundation-capabilities.md](../plugins/product-builder/skills/creating-products/references/foundation-capabilities.md) | Classification-to-skill mapping and dependency order |
| [feature-manifest.md](../plugins/product-builder/skills/creating-products/references/feature-manifest.md) | Manifest schema, field definitions, and status lifecycle |
| [data-access-architecture.md](../plugins/product-builder/shared/references/data-access-architecture.md) | DAO, query, service, and transaction conventions |
| [architecture-template.md](../plugins/product-builder/shared/templates/architecture-template.md) | Template for `docs/architecture.md` |
| [data-model-template.md](../plugins/product-builder/shared/templates/data-model-template.md) | Template for `docs/data-model.md` |
| [convention-template.md](../plugins/product-builder/shared/templates/convention-template.md) | Template for convention files in `docs/conventions/` |

## Skills Reference

| Skill | Phase | Role |
| --- | --- | --- |
| [`creating-products`](../plugins/product-builder/skills/creating-products/SKILL.md) | All | Orchestrator — drives the full process |
| [`preparing-repositories`](../plugins/product-builder/skills/preparing-repositories/SKILL.md) | 1 | Creates or finds the GitHub repo and local clone |
| [`bootstrapping-code`](../plugins/product-builder/skills/bootstrapping-code/SKILL.md) | 1 | Scaffolds the base project |
| [`adding-database`](../plugins/product-builder/skills/adding-database/SKILL.md) | 2 | Adds Cloudflare D1 + Drizzle ORM |
| [`adding-authentication`](../plugins/product-builder/skills/adding-authentication/SKILL.md) | 2 | Adds Better Auth email/password |
| [`adding-file-storage`](../plugins/product-builder/skills/adding-file-storage/SKILL.md) | 2 | Adds Cloudflare R2 (advanced only) |
| [`adding-ai`](../plugins/product-builder/skills/adding-ai/SKILL.md) | 2 | Adds Vercel AI SDK + OpenAI (when ai=yes) |
| [`planning-features`](../plugins/product-builder/skills/planning-features/SKILL.md) | 3 | Creates numbered feature specs |
| [`implementing-features`](../plugins/product-builder/skills/implementing-features/SKILL.md) | 4 | Implements a feature from its spec |
| [`verifying-features`](../plugins/product-builder/skills/verifying-features/SKILL.md) | 5 | Verifies implementation against spec |
| [`testing-features`](../plugins/product-builder/skills/testing-features/SKILL.md) | 5 | Runs E2E browser tests via Chrome DevTools |
| [`react-router-patterns`](../plugins/product-builder/skills/react-router-patterns/SKILL.md) | 3–4 | Route design and implementation patterns |
