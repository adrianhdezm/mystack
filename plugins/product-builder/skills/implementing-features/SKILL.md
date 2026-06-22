---
name: implementing-features
description: Implements a Product Builder feature spec task by task from docs/features/, writing code and maintaining docs/data-model.md, docs/conventions/, and docs/architecture.md. Use when the user asks to implement, build, or code a planned feature from a feature spec.
---

# Implementing Features

Reads a feature spec and all project context, then builds each task in the spec as a full vertical slice — schema, migrations, DAOs, queries, services, routes, components, and tests — committing after each task and keeping `docs/data-model.md`, `docs/architecture.md`, and `docs/conventions/` up to date.

## Context

**Guard** — stop before proceeding if `project.name` is not set in `docs/context.json`:

```text
Stop — docs/context.json is missing project.name. Run scaffolding-project first, then re-run this skill.
```

Progress is tracked per-feature and per-task in `docs/features/manifest.json`, not in `docs/context.json`. Do not write any fields to `docs/context.json` from this skill.

## Input

A feature spec from `docs/features/` (e.g. `docs/features/02-bookmarking.spec.md`), or a specific task id to resume from (e.g. `02.03`). If not provided:

1. Read `docs/features/manifest.json`.
2. Find the first `ready` feature whose `depends_on` features are all `verified`.
3. If exactly one candidate exists, propose it and proceed after confirmation.
4. If multiple candidates exist, list them and ask the user to choose.
5. If no eligible feature exists, report what is blocking progress (features with unmet dependencies or none in `ready` state) and stop.

## Workflow

### 1) Read Context

- Read the target spec completely — understand the goal, all tasks, their `depends_on`, and acceptance criteria.
- Read all dependency specs listed in the feature's Dependencies section.
- Read `docs/features/manifest.json` — find the feature entry, read existing task statuses, determine which tasks are `pending` or `blocked`.
- Read `docs/data-model.md` — canonical entity/relationship reference.
- Read `docs/architecture.md` — Implementation Log for prior decisions and deviations.
- Scan existing code: schema, DAOs, queries, services, routes, components.
- Read [data-access-architecture.md](../../shared/references/data-access-architecture.md) for DAO, query, service, and transaction conventions.
- Read [test-patterns.md](references/test-patterns.md) for DAO, Query, Service, and route test templates.
- Load `react-router-patterns` for route, loader, action, and page conventions.
- Read all `docs/conventions/*.md` for project-specific patterns and anti-patterns.

### 2) Determine Task Order

From the manifest, identify all tasks that are `pending` or `blocked`. Build the execution order respecting `depends_on`: a task may only start when all its `depends_on` tasks are `done`. Start from the first eligible task — or from the task id given as input if resuming.

### 3) Set Feature Status

Set the feature's `status` to `implementing` in `manifest.json` before beginning the first task.

### 4) Implement Task by Task

For each eligible task in order:

**a) Start the task** — set task `status` to `implementing` in `manifest.json`.

**b) Build the task's vertical slice** — implement everything the task describes:

- Schema changes and Drizzle migrations (if task includes schema).
- DAOs at `app/db/daos/<entity>.dao.ts` + test at `tests/integration/db/daos/<entity>.dao.test.ts` using the DAO test pattern from [test-patterns.md](references/test-patterns.md).
- Queries at `app/db/queries/<parent>-<child>.query.ts` + test at `tests/integration/db/queries/<parent>-<child>.query.test.ts`.
- Services at `app/services/<entity>.service.ts` + test at `tests/integration/services/<entity>.service.test.ts`.
- Route modules at `app/routes/<route>.tsx` + test at `tests/unit/routes/<route>.test.tsx` using `createRoutesStub` with loader/action stubs.
- For cross-table data, check for an existing Query in `app/db/queries/` before creating one — follow [data-access-architecture.md](../../shared/references/data-access-architecture.md) conventions exactly.
- Follow `docs/conventions/` and avoid listed anti-patterns.
- When the task is ambiguous, make a reasonable choice and log it in `docs/architecture.md`.
- Run `pnpm typecheck` to catch errors early.

**c) Verify the task** — walk every acceptance criterion for this task. Log unmet criteria as open questions in `docs/architecture.md`.

**d) Finish the task** — set task `status` to `done` in `manifest.json`. Commit with a message referencing the task id and title (e.g. `feat(bookmarking): ✨ Task 02.01 — Schema and DAOs`).

**e) Derive feature status** — after each task commit, update the feature's `status` in `manifest.json`:

- Any task `implementing` → feature `implementing`
- Any task `blocked` → feature `blocked`
- All tasks `done` → feature `implemented`

If a task requires user input: set that task's `status` to `blocked` in the manifest **before** advancing, then derive the feature status (which will also be `blocked`). Advance to the next eligible task — one whose `depends_on` are all `done` and which is not itself blocked. Stop and report if no eligible tasks remain.

### 5) Update Architecture and Docs

**`docs/architecture.md` — Implementation Log**: Add `### NN — Title` and log Design Decisions, Deviations, Tradeoffs, and Open Questions. Omit empty subsections.

**`docs/data-model.md`**: Update to reflect the current state of `app/db/schema.ts` after all schema changes.

**`docs/conventions/`**: Add or update files when implementation reveals a reusable pattern or a mistake worth preventing. Use [convention-template.md](../../shared/templates/convention-template.md) for new files. Add a linked entry in `docs/architecture.md` Conventions section for any new file.

### 6) Final Checks

- `pnpm typecheck` — must pass.
- `pnpm lint` — fix all issues.
- `pnpm test` — must pass. Fix the implementation or test before proceeding.

### 7) Finish

Summarize what was built task by task, highlight open questions, and provide the path to `docs/architecture.md`.

## References

- **Test patterns**: [references/test-patterns.md](references/test-patterns.md)
- **Feature manifest schema**: [references/feature-manifest.md](../creating-products/references/feature-manifest.md)
- **Data access architecture**: [data-access-architecture.md](../../shared/references/data-access-architecture.md)
- **Architecture template**: [architecture-template.md](../../shared/templates/architecture-template.md)
- **Data model template**: [data-model-template.md](../../shared/templates/data-model-template.md)
- **Convention template**: [convention-template.md](../../shared/templates/convention-template.md)

## Review Checklist

- [ ] `docs/context.json` guard passed (`project.name` is set).
- [ ] Target spec and all dependency specs read before implementation.
- [ ] Manifest read — task statuses and `depends_on` confirmed before determining order.
- [ ] `docs/architecture.md` and `docs/data-model.md` read or created.
- [ ] Tasks implemented in dependency order; no task started before its `depends_on` are `done`.
- [ ] Each task: status set to `implementing` before starting, `done` after commit.
- [ ] Each task committed individually with a message referencing the task id.
- [ ] Feature `status` derived and updated in manifest after each task commit.
- [ ] All spec sections built: schema, DAOs, queries, services, routes, components.
- [ ] Integration test exists for every DAO, Query, and Service.
- [ ] Unit test exists for every route component.
- [ ] `docs/data-model.md` reflects current `app/db/schema.ts`.
- [ ] Implementation Log updated in `docs/architecture.md`.
- [ ] `docs/conventions/` updated where new patterns emerged.
- [ ] `pnpm typecheck`, `pnpm lint`, and `pnpm test` pass.
- [ ] Every task's acceptance criteria verified or logged as an open question.
