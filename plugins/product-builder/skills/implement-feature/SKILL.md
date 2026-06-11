---
name: implement-feature
description: Implement a Product Builder feature spec from docs/features/ end-to-end, writing code and maintaining docs/architecture.md with design decisions, deviations, and tradeoffs. Use when the user asks to implement, build, or code a planned feature from a feature spec.
---

# Implement Feature

## Input

A feature spec from `docs/features/` (e.g., `docs/features/02-color-upload.spec.md`).
If the user does not specify which spec, list available `docs/features/*.spec.md`
files and ask.

## Workflow

### 1) Read Context

- Read the target spec file.
- Read dependency specs listed in its Dependencies section.
- Read `docs/architecture.md` if it exists — use the Data Model section to
  understand existing entities and relationships, and the Implementation Log
  for prior design decisions and deviations.
- Scan the codebase for existing code related to the spec: schema, DAOs,
  services, routes, components.
- Read
  [05-data-access-architecture.md](../adding-database/references/05-data-access-architecture.md)
  for DAO, service, and transaction conventions.
- Load `react-router-patterns` for route, loader, action, and page conventions.

### 2) Implement

- Build everything the spec describes: schema, migrations, DAOs, services,
  routes, loaders/actions, components — the full vertical slice.
- Follow existing project patterns: Drizzle for schema, React Router
  loaders/actions for data, shadcn/ui for components, Conform + Zod for forms.
- When the spec is ambiguous, make a reasonable choice and log it in
  `docs/architecture.md`.
- Run `pnpm typecheck` periodically to catch errors early.

### 3) Update Architecture

Create or update `docs/architecture.md`. Use the template in
[architecture-template.md](assets/architecture-template.md) when creating it for
the first time. This is the canonical reference for the project's data model,
conventions, and implementation history.

#### Data Model

Keep the Data Model section at the top of the file. After implementing schema
changes, update it to reflect the current state of `app/db/schema.ts` — entities,
columns, types, relationships, and constraints. This section always represents
what is built, not what is planned.

#### Implementation Log

Below the Data Model, add a section header for the current spec
(`## NN — Title`) and log entries under it. Update as decisions happen.

```markdown
# Architecture

## Data Model

### Entity Name

- `id` (text, PK) — UUID
- `name` (text, not null) — display name
- `userId` (text, FK → users.id) — owner
- `createdAt` / `updatedAt` (integer, not null) — timestamps

**Relations**: belongs to User; has many Items.

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

#### Conventions and Anti-patterns

When implementation reveals a pattern worth reusing or a mistake worth
preventing, add it under the relevant area in Conventions or Anti-patterns.
These sections grow organically — only add entries that would save a future
implementer from a real mistake or inconsistency.

Omit empty subsections in the Implementation Log.

### 4) Verify

- Run `pnpm typecheck` — must pass.
- Run `pnpm lint` — fix any issues.
- Walk through the acceptance criteria from the spec and confirm each one is met.
- If a criterion cannot be met, log it as an open question in
  `docs/architecture.md`.

### 5) Summary

- State what was built and where.
- Highlight open questions or deviations that need user input.
- Provide the path to `docs/architecture.md`.

## Validation Checklist

- [ ] Target spec and its dependencies were read before implementation.
- [ ] `docs/architecture.md` was read or created.
- [ ] Data Model section in `docs/architecture.md` reflects the current state of
      `app/db/schema.ts` after implementation.
- [ ] `05-data-access-architecture.md` conventions were followed for DAOs and
      services.
- [ ] `react-router-patterns` conventions were followed for routes, loaders, and
      actions.
- [ ] All spec sections (database, routes, components, services) were
      implemented.
- [ ] `pnpm typecheck` passes.
- [ ] `pnpm lint` passes.
- [ ] Each acceptance criterion was verified or logged as an open question.
- [ ] `docs/architecture.md` was updated with decisions, deviations, and
      tradeoffs.
