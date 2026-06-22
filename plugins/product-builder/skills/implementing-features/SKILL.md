---
name: implementing-features
description: Implements a Product Builder feature spec from docs/features/ end-to-end, writing code and maintaining docs/data-model.md, docs/conventions/, and docs/architecture.md. Use when the user asks to implement, build, or code a planned feature from a feature spec.
---

# Implement Feature

## Context

Read [context-schema.md](../../shared/references/context-schema.md) for the full `docs/context.json` schema, field reference, and guard pattern.

**Guard** — stop before proceeding if `context.skills.planning-features` is not `"done"` in `docs/context.json`. Stop with:

```text
Stop — docs/context.json is missing skills.planning-features = "done". Run planning-features first, then re-run this skill.
```

Set `skills.implementing-features` to `in-progress` at the start of the workflow. On successful completion, set it to `done`.

**Writes:**

```json
{
  "skills": { "implementing-features": "done" }
}
```

## Input

A feature spec from `docs/features/` (e.g., `docs/features/02-color-upload.spec.md`). If the user does not specify which spec, list available `docs/features/*.spec.md` files and ask.

## Workflow

### 1) Read Context

- Read the target spec file.
- Read dependency specs listed in its Dependencies section.
- Read `docs/data-model.md` if it exists — this is the canonical reference for entities, relationships, and constraints.
- Read `docs/architecture.md` if it exists — use the Implementation Log for prior design decisions and deviations.
- Scan the codebase for existing code related to the spec: schema, DAOs, queries, services, routes, components.
- Read [data-access-architecture.md](../../shared/references/data-access-architecture.md) for DAO, query, service, and transaction conventions.
- Read [test-patterns.md](references/test-patterns.md) for DAO, Query, and Service test templates.
- Load `react-router-patterns` for route, loader, action, and page conventions.
- Read all `docs/conventions/*.md` files for project-specific patterns and anti-patterns established during prior implementations.

### 2) Update Manifest

If `docs/features/manifest.json` exists, set the feature's status to `implementing`.

### 3) Implement

- Build everything the spec describes: schema, migrations, DAOs, queries, services, routes, loaders/actions, components — the full vertical slice.
- When a loader or action needs cross-table data, check for an existing Query in `app/db/queries/`. If none exists, create one following the patterns in [data-access-architecture.md](../../shared/references/data-access-architecture.md) — do not re-derive the interface or naming conventions here.
- After creating each DAO at `app/db/daos/<entity>.dao.ts`, create a test at `tests/integration/db/daos/<entity>.dao.test.ts` using the DAO test pattern from [test-patterns.md](references/test-patterns.md).
- After creating each Query at `app/db/queries/<parent>-<child>.query.ts`, create a test at `tests/integration/db/queries/<parent>-<child>.query.test.ts` using the Query test pattern.
- After creating each Service at `app/services/<entity>.service.ts`, create a test at `tests/integration/services/<entity>.service.test.ts` using the Service test pattern.
- After creating each route component at `app/routes/<route>.tsx`, create a test at `tests/unit/routes/<route>.test.tsx` using the Route Component Test pattern from [test-patterns.md](references/test-patterns.md). Use `createRoutesStub` with loader/action stubs so data flows through the router the same way it does in production.
- Follow project conventions in `docs/conventions/` and avoid listed anti-patterns. For base patterns use Drizzle for schema, React Router loaders/actions for data, shadcn/ui for components, Conform + Zod for forms.
- When the spec is ambiguous, make a reasonable choice and log it in `docs/architecture.md`.
- Run `pnpm typecheck` periodically to catch errors early.

### 4) Update Architecture

Update `docs/architecture.md`. Foundation skills (`scaffolding-project`, `adding-database`, `adding-authentication`, `adding-file-storage`, `adding-ai`) create this file and populate the Stack, Structure, and Conventions sections. If it does not exist (standalone use without foundation skills), create it using [architecture-template.md](../../shared/templates/architecture-template.md) and fill in the Stack and Structure to match the current project.

#### Data Model

Update `docs/data-model.md`. Foundation skills create this file with entities from the initial schema. If it does not exist, create it using [data-model-template.md](../../shared/templates/data-model-template.md). After implementing schema changes, update it to reflect the current state of `app/db/schema.ts` — entities, columns, types, relationships, and constraints. This file always represents what is built, not what is planned.

#### Implementation Log

Add a section header for the current spec (`### NN — Title`) under the Implementation Log in `docs/architecture.md` and log entries under it. Update as decisions happen.

```markdown
## Implementation Log

### 02 — Color Upload

#### Design Decisions

- **Sonner for toasts** — used sonner instead of a custom toast because the project already depends on it via shadcn/ui.

#### Deviations

- **Error display** — spec said inline error below the form; used a toast instead for consistency with the existing delete confirmation pattern.

#### Tradeoffs

- **File validation on client vs server** — validated file extension on the client for fast feedback, but full .ase parsing stays server-side. Client-only validation would miss corrupted files.

#### Open Questions

- **Max file size** — spec does not specify. Currently allowing up to 5 MB. Confirm or adjust.
```

#### Conventions

When implementation reveals a pattern worth reusing or a mistake worth preventing, add or update the relevant file in `docs/conventions/`. Foundation skills may have already seeded `docs/conventions/routes.md` and `docs/conventions/data-access.md` — read existing convention files before adding entries. Use the template in [convention-template.md](../../shared/templates/convention-template.md) when creating a new convention file. Each file covers one area (data access, UI components, form validation, routes) and contains both Patterns and Anti-patterns sections. These grow organically — only add entries that would save a future implementer from a real mistake or inconsistency.

If you create a new convention file, add a linked entry in the Conventions section of `docs/architecture.md`.

Omit empty subsections in the Implementation Log.

### 5) Verify

- Run `pnpm typecheck` — must pass.
- Run `pnpm lint` — fix any issues.
- Run `pnpm test` — must pass. If a test fails, fix the implementation or the test before proceeding.
- Walk through the acceptance criteria from the spec and confirm each one is met.
- If a criterion cannot be met, log it as an open question in `docs/architecture.md`.

### 6) Update Manifest

If `docs/features/manifest.json` exists, set the feature's status to `implemented`.

### 7) Update Context

Write `skills.implementing-features = "done"` to `docs/context.json`.

### 8) Summary

- State what was built and where.
- Highlight open questions or deviations that need user input.
- Provide the path to `docs/architecture.md`.

## Validation Checklist

- [ ] Target spec and its dependencies were read before implementation.
- [ ] `docs/architecture.md` was read or created.
- [ ] `docs/data-model.md` was read or created.
- [ ] `docs/data-model.md` reflects the current state of `app/db/schema.ts` after implementation.
- [ ] `data-access-architecture.md` conventions were followed for DAOs, queries, and services.
- [ ] `react-router-patterns` conventions were followed for routes, loaders, and actions.
- [ ] Project conventions in `docs/conventions/` were followed and anti-patterns avoided.
- [ ] All spec sections (database, DAOs, queries, services, routes, components) were implemented.
- [ ] A `.test.ts` file exists in `tests/integration/db/daos/` for every DAO created.
- [ ] A `.test.ts` file exists in `tests/integration/db/queries/` for every Query created.
- [ ] A `.test.ts` file exists in `tests/integration/services/` for every Service created.
- [ ] A `.test.tsx` file exists in `tests/unit/routes/` for every route component created.
- [ ] `pnpm typecheck` passes.
- [ ] `pnpm lint` passes.
- [ ] `pnpm test` passes.
- [ ] Each acceptance criterion was verified or logged as an open question.
- [ ] `docs/architecture.md` was updated with decisions, deviations, and tradeoffs.
- [ ] `docs/context.json` guards passed (`skills.planning-features = "done"`).
- [ ] `docs/context.json` was updated with `skills.implementing-features = "done"`.
