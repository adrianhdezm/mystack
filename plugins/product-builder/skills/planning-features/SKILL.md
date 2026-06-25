---
name: planning-features
description: Plans a Product Builder feature end-to-end — database changes, pages, views, shadcn components, and tasks with acceptance criteria — and saves a numbered spec to docs/features/. Use when the user asks to plan, spec, design, or scope a feature for a Product Builder project.
---

# Planning Features

Interviews the user to scope a feature, reads the codebase and existing specs to understand what is already built, writes a single spec file with a numbered task breakdown, gets user approval, and updates `docs/features/manifest.json` with the feature's tasks.

## Context

**Guard** — stop before proceeding if `project.name` is not set in `docs/context.json`:

```text
Stop — docs/context.json is missing project.name. Run scaffolding-project first, then re-run this skill.
```

Progress is tracked per-feature in `docs/features/manifest.json`, not in `docs/context.json`. Do not write any fields to `docs/context.json` from this skill.

## Input

A product feature described in user terms — e.g. "Users should be able to bookmark recipes and organize them into collections." If the description is vague, ask up to three clarifying questions before planning: who triggers this and what outcome do they expect? Is the data private, shared, or public? What should be excluded from the first version?

## Workflow

### 1) Read Context

- Read `docs/prd.md` — align feature scope with the product's problem statement, target users, and primary workflow.
- Read `docs/data-model.md` — canonical reference for existing entities and relationships.
- Read `docs/architecture.md` — Implementation Log for prior design decisions.
- Read all existing `docs/features/*.spec.md` — know what is already planned and what task ids are already in use.
- Read `docs/features/manifest.json` if it exists — confirm the feature's current status and check existing task ids.
- Scan the codebase: `app/db/schema.ts`, `app/db/daos/`, `app/db/queries/`, `app/services/`, `app/routes/`, `app/components/`.
- For every service method, DAO, query, or schema change the spec will introduce, grep the codebase to check if it already exists. If it does, mark it **already implemented** in the spec and exclude it from task scope — do not re-spec work that is already in place.
- Read [data-access-architecture.md](../../shared/references/data-access-architecture.md) for DAO, query, service, and transaction conventions.
- Load `react-router-patterns` for route, loader, action, and page conventions.
- Read all `docs/conventions/*.md` for project-specific patterns. Specs must align with them.

### 2) Write the Spec

Write one spec file per feature using [feature-spec-template.md](assets/feature-spec-template.md). Name the file `NN-short-name.spec.md`, continuing the existing numbering sequence.

A spec describes what the user sees and does — database changes, pages, routes, components, DAOs, queries, services — and slices the implementation into **tasks**:

- A task is a vertical slice: it touches every layer it needs (schema, DAO, service, route, UI) and produces a committable, working increment.
- Slice by technical dependency, not by layer — no schema-only or UI-only tasks unless genuinely standalone.
- Each task has a title, a list of layers it touches, `depends_on` (task ids within this feature), and its own acceptance criteria.
- Tasks whose `depends_on` are all `done` may be implemented independently; plan `depends_on` to enable maximum parallelism without breaking increments.

### 3) Confirm with User

Present the spec for review: goal, task list (id, title, layers, depends_on), and acceptance criteria per task. Ask the user to approve, reorder, merge, or split before writing files.

### 4) Write the Spec File

Create `docs/features/` if it does not exist. Write the approved spec to `docs/features/NN-short-name.spec.md`.

### 5) Update Manifest

If `docs/features/manifest.json` exists:

- Set the feature's `status` to `ready`.
- Populate `tasks[]` with one entry per task: `id`, `title`, `status: "pending"`, `depends_on`.

## References

- **Feature spec template**: [assets/feature-spec-template.md](assets/feature-spec-template.md)
- **Feature manifest schema**: [references/feature-manifest.md](../creating-products/references/feature-manifest.md)
- **Data access architecture**: [data-access-architecture.md](../../shared/references/data-access-architecture.md)

## Review Checklist

- [ ] `docs/context.json` guard passed (`project.name` is set).
- [ ] Clarifying questions asked when description was ambiguous.
- [ ] Existing specs, manifest, and codebase scanned before planning.
- [ ] Every proposed service method, DAO, and query checked against existing code — already-implemented items excluded from task scope.
- [ ] Feature scope aligns with `docs/prd.md`.
- [ ] One spec file written per feature.
- [ ] Each task is a vertical slice the user can interact with in the browser.
- [ ] Tasks have `depends_on` set to enable independent execution where possible.
- [ ] Each task has its own acceptance criteria.
- [ ] Database changes described relative to current `docs/data-model.md`.
- [ ] Pages and routes include path, loader/action responsibilities, and protected status.
- [ ] No task depends on a task with a higher id number within the same feature.
- [ ] No feature spec depends on a feature with a higher id number.
- [ ] Specs align with `docs/conventions/`.
- [ ] User approved the spec before the file was written.
- [ ] `manifest.json` updated: feature `status = "ready"`, `tasks[]` populated at `pending`.
