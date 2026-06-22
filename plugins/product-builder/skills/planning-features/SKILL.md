---
name: planning-features
description: Plans a Product Builder feature end-to-end — database changes, pages, views, shadcn components, and acceptance criteria — and saves a numbered spec to docs/features/. Use when the user asks to plan, spec, design, or scope a feature for a Product Builder project.
---

# Planning Features

Interviews the user to scope a feature, reads the codebase and existing specs to understand what is already built, slices the work into numbered vertical-slice specs, gets user approval, and writes spec files to `docs/features/`.

## Context

**Guard** — stop before proceeding if `context.skills.scaffolding-project` is not `"done"`:

```text
Stop — docs/context.json is missing skills.scaffolding-project = "done". Run scaffolding-project first, then re-run this skill.
```

Set `skills.planning-features` to `in-progress` at the start. On success write:

```json
{
  "skills": { "planning-features": "done" }
}
```

## Input

A product feature described in user terms — e.g. "Users should be able to bookmark recipes and organize them into collections." If the description is vague, ask up to three clarifying questions before planning: who triggers this and what outcome do they expect? Is the data private, shared, or public? What should be excluded from the first version?

## Workflow

### 1) Read Context

- Read `docs/prd.md` — align feature scope with the product's problem statement, target users, and primary workflow.
- Read `docs/data-model.md` — canonical reference for existing entities and relationships.
- Read `docs/architecture.md` — Implementation Log for prior design decisions.
- Read all existing `docs/features/*.spec.md` — know what is already planned.
- Scan the codebase: `app/db/schema.ts`, `app/db/daos/`, `app/db/queries/`, `app/services/`, `app/routes/`, `app/components/`.
- Read [data-access-architecture.md](../../shared/references/data-access-architecture.md) for DAO, query, service, and transaction conventions.
- Load `react-router-patterns` for route, loader, action, and page conventions.
- Read all `docs/conventions/*.md` for project-specific patterns. Specs must align with them.

### 2) Slice the Feature

- Think in terms of what the user will see and do; derive the technical pieces from that.
- A spec is a **vertical slice** delivered end-to-end: schema changes, DAOs, queries, services, routes, loaders/actions, UI components, and wiring. A reader should be able to build the spec and see a working feature in the browser.
- Slice by user-facing capability — no schema-only or component-only specs.
- Order so each part builds on the previous. For large features, split into multiple numbered specs and note dependencies.

### 3) Confirm with User

Present the proposed spec list: number, title, one-line scope for each. Ask the user to approve, reorder, merge, or split before writing files.

### 4) Write Specs

Create `docs/features/` if it does not exist. Write one file per spec using [feature-spec-template.md](assets/feature-spec-template.md). Name files `NN-short-name.spec.md`, continuing the existing numbering sequence.

### 5) Update Manifest and Context

If `docs/features/manifest.json` exists, update each written spec's status from `listed` to `ready`. Write `skills.planning-features = "done"` to `docs/context.json`.

## References

- **Feature spec template**: [assets/feature-spec-template.md](assets/feature-spec-template.md)
- **Data access architecture**: [data-access-architecture.md](../../shared/references/data-access-architecture.md)

## Review Checklist

- [ ] `docs/context.json` guard passed (`skills.scaffolding-project = "done"`).
- [ ] Clarifying questions asked when description was ambiguous.
- [ ] Existing specs and codebase scanned before planning.
- [ ] Feature scope aligns with `docs/prd.md`.
- [ ] Each spec is a vertical slice the user can interact with in the browser.
- [ ] Database changes described relative to current `docs/data-model.md`.
- [ ] Pages and routes include path, loader/action responsibilities, and protected status.
- [ ] Acceptance criteria are verifiable "When X, then Y" statements.
- [ ] No spec depends on a feature with a higher id number.
- [ ] Specs align with `docs/conventions/`.
- [ ] User approved the spec list before files were written.
- [ ] `docs/context.json` updated with `skills.planning-features = "done"`.
