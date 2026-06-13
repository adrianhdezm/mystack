---
name: planning-features
description: Plans a Product Builder feature end-to-end — database changes, pages, views, shadcn components, and acceptance criteria — and saves a numbered spec to docs/features/. Use when the user asks to plan, spec, design, or scope a feature for a Product Builder project.
---

# Plan Feature

## Input

A product feature described in user terms. Examples:

- "Users should be able to bookmark recipes and organize them into collections."
- "Add a team invitation flow — invite by email, accept/decline, and manage members."
- "Dashboard with charts showing sales by month and top products."

If the description is vague or missing key decisions, ask up to three clarifying questions before planning. Focus on:

- **Who and why** — which user role triggers this, and what outcome do they expect?
- **Data ownership** — is the data private, shared within a team, or public?
- **Scope boundaries** — what should be excluded from the first version?

## Workflow

### 1) Read Context

- Read `docs/vision.md` if it exists — use it to align feature scope with the product's pitch, target users, primary workflow, and entry point flow.
- Read `docs/data-model.md` if it exists — this is the canonical reference for entities, relationships, and constraints. Use it to understand the current data model before proposing changes.
- Read `docs/architecture.md` if it exists — use the Implementation Log for prior design decisions and deviations.
- Read all existing `docs/features/*.spec.md` files to know what is already planned.
- Scan the codebase for what is already built: schema (`app/db/schema.ts`), DAOs (`app/db/daos/`), queries (`app/db/queries/`), services (`app/services/`), routes (`app/routes/`), and components (`app/components/`).
- Read [data-access-architecture.md](../../shared/references/data-access-architecture.md) for DAO, query, service, and transaction conventions.
- Load `react-router-patterns` for route, loader, action, and page conventions.
- Read all `docs/conventions/*.md` files for project-specific patterns and anti-patterns. Specs should align with established conventions.
- Identify what the feature requires that is NOT yet covered by existing specs or code.

### 2) Slice the Feature

- Think in terms of what the user will see and do, then derive the technical pieces needed to support it.
- A feature spec is a **vertical slice** delivered end-to-end: schema changes, DAOs, queries, services, routes, loaders/actions, UI components, and wiring. The reader should be able to build the spec and see a working feature in the browser.
- Slice by user-facing capability. Do not create schema-only or component-only specs.
- Order dependencies so each part builds on the previous.
- If the feature is large, split into multiple numbered specs and note dependencies between them. Each spec should still deliver something the user can interact with.

### 3) Confirm with User

Present the proposed spec list: number, title, one-line scope for each. Ask the user to approve, reorder, merge, or split before writing files.

### 4) Write Specs

Create `docs/features/` if it does not exist. Write one file per spec using the template in [feature-spec-template.md](assets/feature-spec-template.md).

Name files as `NN-short-name.spec.md` continuing the existing numbering sequence. If `00` and `01` exist, start at `02`.

### 5) Update Manifest

If `docs/features/manifest.json` exists, update the status of each spec written in this run from `listed` to `ready`.

## Validation Checklist

- [ ] Clarifying questions were asked when the feature description was ambiguous.
- [ ] Existing specs and code were scanned before planning.
- [ ] Feature scope aligns with the product vision in `docs/vision.md`.
- [ ] Each spec is a vertical slice the user can interact with in the browser.
- [ ] Database changes describe additions and modifications relative to the current data model in `docs/data-model.md`.
- [ ] Pages and routes include path, loader/action responsibilities, and protected status.
- [ ] shadcn/ui components are listed with intended usage.
- [ ] Acceptance criteria are verifiable "When X, then Y" statements written from the user's perspective.
- [ ] Specs are ordered with no forward dependencies.
- [ ] Specs align with project conventions in `docs/conventions/`.
- [ ] User approved the spec list before files were written.
