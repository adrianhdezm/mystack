# Product Builder: Creating Products Process

This document describes the end-to-end process that Product Builder follows when you ask it to turn a product idea into a working application.

## Example Prompt

```
Use Product Builder to create a meal-planning app for busy parents that turns
weekly preferences into grocery lists and quick dinner plans.
```

## Process Overview

The process runs in four phases, orchestrated by the [`creating-products`](../plugins/product-builder/skills/creating-products/SKILL.md) skill. Each phase invokes specialized sub-skills in sequence.

---

### Phase 1 — Interview and Foundation

**Goal:** Understand the product, classify its complexity, and set up the project with the right infrastructure.

#### 1. Interview

Product Builder asks targeted questions to understand the product before writing any code. It follows the [interview-and-decisions](../plugins/product-builder/skills/creating-products/references/interview-and-decisions.md) reference to cover:

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

Based on the interview, the product is classified using a fixed matrix:

| Classification | Database | Authentication | File Storage |
| -------------- | -------- | -------------- | ------------ |
| `simple`       | No       | No             | No           |
| `standard`     | Yes      | Yes            | No           |
| `advanced`     | Yes      | Yes            | Yes          |

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

It also generates the initial project documentation from shared templates:

- [`docs/architecture.md`](../plugins/product-builder/shared/templates/architecture-template.md) — stack, structure, conventions, and implementation log.
- [`docs/data-model.md`](../plugins/product-builder/shared/templates/data-model-template.md) — canonical entity and relationship reference.
- [`docs/conventions/`](../plugins/product-builder/shared/templates/convention-template.md) — pattern and anti-pattern files that grow during implementation.
- `AGENTS.md` — agent instructions referencing the docs.

#### 5. Foundation Capabilities

Foundation skills run in dependency order based on the classification:

1. **[`adding-database`](../plugins/product-builder/skills/adding-database/SKILL.md)** — Adds Cloudflare D1 with Drizzle ORM, migrations, and server context.
2. **[`adding-authentication`](../plugins/product-builder/skills/adding-authentication/SKILL.md)** — Adds Better Auth with email/password, session handling, and protected routes.
3. **[`adding-file-storage`](../plugins/product-builder/skills/adding-file-storage/SKILL.md)** _(advanced only)_ — Adds Cloudflare R2 with upload/delete lifecycle and file metadata.

After foundation skills complete, `docs/architecture.md` reflects the full stack and `docs/data-model.md` includes all foundation entities (e.g., auth tables).

---

### Phase 2 — Feature Planning

**Goal:** Define and approve the feature set before any product-specific code is written.

#### 6. Feature Proposal

Product Builder proposes a list of features that deliver the first usable version. Each feature has a short title and one-line description, ordered by dependency.

**Meal-planning example:**

1. **Preference Survey** — Collect dietary restrictions, household size, and cuisine preferences.
2. **Meal Plan Generator** — Generate a weekly dinner plan based on preferences.
3. **Grocery List** — Aggregate ingredients from the meal plan into a grouped shopping list.
4. **Plan History** — View and reuse past weekly plans.

#### 7. User Approval

The user approves, reorders, adds, or removes features. No planning or implementation begins until the feature list is approved.

#### 8. Feature Spec Creation

The [`planning-features`](../plugins/product-builder/skills/planning-features/SKILL.md) skill runs for each approved feature, producing numbered spec files:

```
docs/features/
├── 01-preference-survey.md
├── 02-meal-plan-generator.md
├── 03-grocery-list.md
└── 04-plan-history.md
```

Each spec covers database changes, pages, views, shadcn components, and acceptance criteria. The spec follows the [design-approval](../plugins/product-builder/skills/creating-products/references/design-approval.md) reference for proposal content and approval flow.

---

### Phase 3 — Feature Implementation Loop

**Goal:** Implement and verify each feature against its spec.

For each spec in `docs/features/`, in order:

1. **Implement** — [`implementing-features`](../plugins/product-builder/skills/implementing-features/SKILL.md) writes the code, updates `docs/data-model.md`, `docs/conventions/`, and `docs/architecture.md`.
2. **Verify** — [`verifying-features`](../plugins/product-builder/skills/verifying-features/SKILL.md) checks the implementation against acceptance criteria.
3. **Iterate** — If verification finds issues, implementation runs again, then re-verifies. This repeats until the spec passes or user input is needed.
4. **Commit** — Once verified, the feature is committed and summarized before moving to the next.

---

### Phase 4 — Final Verification

**Goal:** Confirm the full project builds, passes checks, and works end-to-end.

1. Run formatting, typecheck, lint, and build across the full project.
2. If any failure traces to a specific feature, return to Phase 3 for that feature.
3. Optionally run [`testing-features`](../plugins/product-builder/skills/testing-features/SKILL.md) — generates a happy-path E2E test plan from all feature specs and executes it in the browser via Chrome DevTools MCP.
4. Commit the final state and summarize: foundation skills used, features implemented, commit hash, verification results, and open questions.

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
│   │   └── schema.ts           # Drizzle ORM schema (all entities)
│   ├── lib/
│   │   ├── auth.ts             # Better Auth client
│   │   ├── auth.server.ts      # Better Auth server config
│   │   └── ...                 # Utilities and helpers
│   ├── routes/
│   │   ├── _index.tsx          # Landing / home page
│   │   ├── login.tsx           # Login page
│   │   ├── register.tsx        # Registration page
│   │   ├── dashboard.tsx       # User dashboard
│   │   ├── preferences.tsx     # Preference survey
│   │   ├── meal-plans.tsx      # Meal plan list / generator
│   │   ├── meal-plans.$id.tsx  # Meal plan detail
│   │   ├── grocery-list.tsx    # Grocery list view
│   │   └── api.auth.$.ts       # Auth API resource route
│   ├── routes.ts               # Route config
│   ├── app.css                 # Tailwind styles
│   └── root.tsx                # Root layout
├── db/
│   └── migrations/             # Drizzle D1 migration files
├── docs/
│   ├── architecture.md         # Full stack, structure, conventions, implementation log
│   ├── data-model.md           # All entities, columns, relationships
│   ├── conventions/            # Pattern and anti-pattern files
│   │   ├── drizzle.md
│   │   ├── react-router.md
│   │   └── ...
│   └── features/               # Numbered feature specs
│       ├── 01-preference-survey.md
│       ├── 02-meal-plan-generator.md
│       ├── 03-grocery-list.md
│       └── 04-plan-history.md
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
| [interview-and-decisions.md](../plugins/product-builder/skills/creating-products/references/interview-and-decisions.md) | Interview questions, complexity classification, and foundation capability matrix |
| [design-approval.md](../plugins/product-builder/skills/creating-products/references/design-approval.md) | Design proposal content, approval flow, and implementation constraints |
| [architecture-template.md](../plugins/product-builder/shared/templates/architecture-template.md) | Template for `docs/architecture.md` |
| [data-model-template.md](../plugins/product-builder/shared/templates/data-model-template.md) | Template for `docs/data-model.md` |
| [convention-template.md](../plugins/product-builder/shared/templates/convention-template.md) | Template for convention files in `docs/conventions/` |

## Skills Reference

| Skill | Phase | Role |
| --- | --- | --- |
| [`creating-products`](../plugins/product-builder/skills/creating-products/SKILL.md) | All | Orchestrator — drives the full process |
| [`preparing-repositories`](../plugins/product-builder/skills/preparing-repositories/SKILL.md) | 1 | Creates or finds the GitHub repo and local clone |
| [`bootstrapping-code`](../plugins/product-builder/skills/bootstrapping-code/SKILL.md) | 1 | Scaffolds the base project and initial docs |
| [`adding-database`](../plugins/product-builder/skills/adding-database/SKILL.md) | 1 | Adds Cloudflare D1 + Drizzle ORM |
| [`adding-authentication`](../plugins/product-builder/skills/adding-authentication/SKILL.md) | 1 | Adds Better Auth email/password |
| [`adding-file-storage`](../plugins/product-builder/skills/adding-file-storage/SKILL.md) | 1 | Adds Cloudflare R2 (advanced only) |
| [`planning-features`](../plugins/product-builder/skills/planning-features/SKILL.md) | 2 | Creates numbered feature specs |
| [`implementing-features`](../plugins/product-builder/skills/implementing-features/SKILL.md) | 3 | Implements a feature from its spec |
| [`verifying-features`](../plugins/product-builder/skills/verifying-features/SKILL.md) | 3 | Verifies implementation against spec |
| [`testing-features`](../plugins/product-builder/skills/testing-features/SKILL.md) | 4 | Runs E2E browser tests via Chrome DevTools |
| [`react-router-patterns`](../plugins/product-builder/skills/react-router-patterns/SKILL.md) | 2–3 | Route design and implementation patterns |
