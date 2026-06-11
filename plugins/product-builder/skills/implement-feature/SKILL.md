---
name: implement-feature
description: Implement a Product Builder feature spec from docs/features/ end-to-end, writing code and maintaining docs/data-model.md, docs/conventions/, and docs/architecture.md. Use when the user asks to implement, build, or code a planned feature from a feature spec.
---

# Implement Feature

## Input

A feature spec from `docs/features/` (e.g., `docs/features/02-color-upload.spec.md`). If the user does not specify which spec, list available `docs/features/*.spec.md` files and ask.

## Workflow

### 1) Read Context

- Read the target spec file.
- Read dependency specs listed in its Dependencies section.
- Read `docs/data-model.md` if it exists — this is the canonical reference for entities, relationships, and constraints.
- Read `docs/architecture.md` if it exists — use the Implementation Log for prior design decisions and deviations.
- Scan the codebase for existing code related to the spec: schema, DAOs, services, routes, components.
- Read [data-access-architecture.md](../../shared/references/data-access-architecture.md) for DAO, service, and transaction conventions.
- Load `react-router-patterns` for route, loader, action, and page conventions.
- Read all `docs/conventions/*.md` files for project-specific patterns and anti-patterns established during prior implementations.

### 2) Implement

- Build everything the spec describes: schema, migrations, DAOs, services, routes, loaders/actions, components — the full vertical slice.
- Follow project conventions in `docs/conventions/` and avoid listed anti-patterns. For base patterns use Drizzle for schema, React Router loaders/actions for data, shadcn/ui for components, Conform + Zod for forms.
- When the spec is ambiguous, make a reasonable choice and log it in `docs/architecture.md`.
- Run `pnpm typecheck` periodically to catch errors early.

### 3) Update Architecture

Update `docs/architecture.md`. Foundation skills (`bootstrapping-code`, `adding-database`, `adding-authentication`, `adding-file-storage`) create this file and populate the Stack, Structure, and Conventions sections. If it does not exist (standalone use without foundation skills), create it using [architecture-template.md](../../shared/templates/architecture-template.md) and fill in the Stack and Structure to match the current project.

#### Data Model

Update `docs/data-model.md`. Foundation skills create this file with entities from the initial schema. If it does not exist, create it using [data-model-template.md](../../shared/templates/data-model-template.md). After implementing schema changes, update it to reflect the current state of `app/db/schema.ts` — entities, columns, types, relationships, and constraints. This file always represents what is built, not what is planned.

#### Implementation Log

Add a section header for the current spec (`### NN — Title`) under the Implementation Log in `docs/architecture.md` and log entries under it. Update as decisions happen.

```markdown
## Implementation Log

### NN — Title

#### Design Decisions

- **Short title** — explanation of the choice made

#### Deviations

- **Short title** — where implementation departs from the spec, and why

#### Tradeoffs

- **Short title** — alternatives considered and why one was picked

#### Open Questions

- **Short title** — anything the user should confirm or revise
```

#### Conventions

When implementation reveals a pattern worth reusing or a mistake worth preventing, add or update the relevant file in `docs/conventions/`. Foundation skills may have already seeded `docs/conventions/routes.md` and `docs/conventions/data-access.md` — read existing convention files before adding entries. Use the template in [convention-template.md](../../shared/templates/convention-template.md) when creating a new convention file. Each file covers one area (data access, UI components, form validation, routes) and contains both Patterns and Anti-patterns sections. These grow organically — only add entries that would save a future implementer from a real mistake or inconsistency.

If you create a new convention file, add a linked entry in the Conventions section of `docs/architecture.md`.

Omit empty subsections in the Implementation Log.

### 4) Verify

- Run `pnpm typecheck` — must pass.
- Run `pnpm lint` — fix any issues.
- Walk through the acceptance criteria from the spec and confirm each one is met.
- If a criterion cannot be met, log it as an open question in `docs/architecture.md`.

### 5) Summary

- State what was built and where.
- Highlight open questions or deviations that need user input.
- Provide the path to `docs/architecture.md`.

## Validation Checklist

- [ ] Target spec and its dependencies were read before implementation.
- [ ] `docs/architecture.md` was read or created.
- [ ] `docs/data-model.md` was read or created.
- [ ] `docs/data-model.md` reflects the current state of `app/db/schema.ts` after implementation.
- [ ] `data-access-architecture.md` conventions were followed for DAOs and services.
- [ ] `react-router-patterns` conventions were followed for routes, loaders, and actions.
- [ ] Project conventions in `docs/conventions/` were followed and anti-patterns avoided.
- [ ] All spec sections (database, routes, components, services) were implemented.
- [ ] `pnpm typecheck` passes.
- [ ] `pnpm lint` passes.
- [ ] Each acceptance criterion was verified or logged as an open question.
- [ ] `docs/architecture.md` was updated with decisions, deviations, and tradeoffs.
