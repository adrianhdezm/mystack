---
name: implementing-features
description: Implements a Product Builder feature spec from docs/features/ end-to-end, writing code and maintaining docs/data-model.md, docs/conventions/, and docs/architecture.md. Use when the user asks to implement, build, or code a planned feature from a feature spec.
---

# Implementing Features

Reads a feature spec and all project context, then builds the full vertical slice — schema, migrations, DAOs, queries, services, routes, components, and tests — and keeps `docs/data-model.md`, `docs/architecture.md`, and `docs/conventions/` up to date.

## Context

**Guard** — stop before proceeding if `context.skills.planning-features` is not `"done"`:

```text
Stop — docs/context.json is missing skills.planning-features = "done". Run planning-features first, then re-run this skill.
```

Set `skills.implementing-features` to `in-progress` at the start. On success write:

```json
{
  "skills": { "implementing-features": "done" }
}
```

## Input

A feature spec from `docs/features/` (e.g. `docs/features/02-color-upload.spec.md`). If not specified, list available specs and ask.

## Workflow

### 1) Read Context

- Read the target spec and all dependency specs listed in its Dependencies section.
- Read `docs/data-model.md` — canonical entity/relationship reference.
- Read `docs/architecture.md` — Implementation Log for prior decisions and deviations.
- Scan existing code: schema, DAOs, queries, services, routes, components.
- Read [data-access-architecture.md](../../shared/references/data-access-architecture.md) for DAO, query, service, and transaction conventions.
- Read [test-patterns.md](references/test-patterns.md) for DAO, Query, Service, and route test templates.
- Load `react-router-patterns` for route, loader, action, and page conventions.
- Read all `docs/conventions/*.md` for project-specific patterns and anti-patterns.

### 2) Update Manifest

If `docs/features/manifest.json` exists, set the feature's status to `implementing`.

### 3) Implement

Build everything the spec describes — the full vertical slice:

- Schema changes and Drizzle migrations.
- DAOs at `app/db/daos/<entity>.dao.ts` + test at `tests/integration/db/daos/<entity>.dao.test.ts` using the DAO test pattern from [test-patterns.md](references/test-patterns.md).
- Queries at `app/db/queries/<parent>-<child>.query.ts` + test at `tests/integration/db/queries/<parent>-<child>.query.test.ts`.
- Services at `app/services/<entity>.service.ts` + test at `tests/integration/services/<entity>.service.test.ts`.
- Route modules at `app/routes/<route>.tsx` + test at `tests/unit/routes/<route>.test.tsx` using `createRoutesStub` with loader/action stubs.
- For cross-table data, check for an existing Query in `app/db/queries/` before creating one — follow [data-access-architecture.md](../../shared/references/data-access-architecture.md) conventions exactly.
- Follow `docs/conventions/` and avoid listed anti-patterns.
- When the spec is ambiguous, make a reasonable choice and log it in `docs/architecture.md`.
- Run `pnpm typecheck` periodically to catch errors early.

### 4) Update Architecture and Docs

**`docs/architecture.md` — Implementation Log**: Add `### NN — Title` and log Design Decisions, Deviations, Tradeoffs, and Open Questions. Omit empty subsections.

**`docs/data-model.md`**: Update to reflect the current state of `app/db/schema.ts` after all schema changes. This file always represents what is built.

**`docs/conventions/`**: Add or update files when implementation reveals a reusable pattern or a mistake worth preventing. Use [convention-template.md](../../shared/templates/convention-template.md) for new files. Add a linked entry in `docs/architecture.md` Conventions section for any new file.

### 5) Verify

- `pnpm typecheck` — must pass.
- `pnpm lint` — fix all issues.
- `pnpm test` — must pass. Fix the implementation or test before proceeding.
- Walk every acceptance criterion from the spec. Log unmet criteria as open questions in `docs/architecture.md`.

### 6) Finish

If `docs/features/manifest.json` exists, set the feature's status to `implemented`. Write `skills.implementing-features = "done"` to `docs/context.json`. Summarize what was built, highlight open questions, and provide the path to `docs/architecture.md`.

## References

- **Test patterns**: [references/test-patterns.md](references/test-patterns.md)
- **Data access architecture**: [data-access-architecture.md](../../shared/references/data-access-architecture.md)
- **Architecture template**: [architecture-template.md](../../shared/templates/architecture-template.md)
- **Data model template**: [data-model-template.md](../../shared/templates/data-model-template.md)
- **Convention template**: [convention-template.md](../../shared/templates/convention-template.md)

## Review Checklist

- [ ] `docs/context.json` guard passed (`skills.planning-features = "done"`).
- [ ] Target spec and all dependency specs read before implementation.
- [ ] `docs/architecture.md` and `docs/data-model.md` read or created.
- [ ] All spec sections built: schema, DAOs, queries, services, routes, components.
- [ ] Integration test exists for every DAO, Query, and Service.
- [ ] Unit test exists for every route component.
- [ ] `docs/data-model.md` reflects current `app/db/schema.ts`.
- [ ] Implementation Log updated in `docs/architecture.md`.
- [ ] `docs/conventions/` updated where new patterns emerged.
- [ ] `pnpm typecheck`, `pnpm lint`, and `pnpm test` pass.
- [ ] Every acceptance criterion verified or logged as an open question.
- [ ] `docs/context.json` updated with `skills.implementing-features = "done"`.
