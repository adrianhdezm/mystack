---
name: verifying-features
description: Verifies a Product Builder feature implementation against its spec from docs/features/, checking acceptance criteria and reporting deviations, missing items, and inconsistencies. Use when the user asks to verify, review, check, validate, or QA a feature implementation.
---

# Verifying Features

Read-only skill that checks a feature implementation against its spec — verifies each acceptance criterion, runs the project checks, and produces a structured report with a Pass / Pass with notes / Fail verdict.

## Context

**Guard** — stop before proceeding if `context.skills.implementing-features` is not `"done"`:

```text
Stop — docs/context.json is missing skills.implementing-features = "done". Run implementing-features first, then re-run this skill.
```

Set `skills.verifying-features` to `in-progress` at the start. On success write:

```json
{
  "skills": { "verifying-features": "done" }
}
```

## Input

A feature spec from `docs/features/` (e.g. `docs/features/02-color-upload.spec.md`). If not specified, list available specs and ask.

## Workflow

### 1) Read Context

- Read the target spec and all dependency specs in its Dependencies section.
- Read `docs/prd.md` — verify the feature aligns with the product's problem statement and primary workflow.
- Read `docs/data-model.md` — expected entity/relationship map.
- Read `docs/architecture.md` — known deviations and open questions.
- Read all `docs/conventions/*.md` — patterns and anti-patterns to verify against.

### 2) Check Implementation

For each spec section:

- **Database**: tables, columns, indexes, and relationships in `app/db/schema.ts` and `db/migrations/`. Verify `docs/data-model.md` matches `app/db/schema.ts`.
- **DAOs**: exist in `app/db/daos/` and implement the `Dao` interface per [data-access-architecture.md](../../shared/references/data-access-architecture.md).
- **Queries**: exist in `app/db/queries/` for cross-table reads; implement `RelationQuery` interface; services use queries instead of raw Drizzle joins.
- **Services**: in `app/services/` with correct transaction boundaries and DAO composition; do not import schema tables or build raw Drizzle queries.
- **Routes**: files exist, paths registered in `app/routes.ts`, loaders/actions match the spec.
- **Components**: shadcn/ui components installed; custom components created as specified.
- **Tests**: integration tests in `tests/integration/db/daos/`, `tests/integration/db/queries/`, `tests/integration/services/`; unit tests in `tests/unit/routes/`.
- **Auth**: protected routes have authentication checks.
- **Conventions**: implementation follows patterns and avoids anti-patterns in `docs/conventions/`.

### 3) Walk Acceptance Criteria

For each criterion: trace the code path, mark as **met** / **partially met** / **not met**, and describe what is missing or different.

### 4) Run Checks

Run `pnpm typecheck`, `pnpm lint`, `pnpm test`, and `pnpm build`. Report each result.

### 5) Report and Verdict

Produce a static verification report:

```markdown
# Verification: NN — Title

## Acceptance Criteria

| # | Criterion | Status | Notes |
|---|-----------|--------|-------|
| 1 | When X, then Y | Met / Partially met / Not met | … |

## Deviations from Spec

- **Area** — what differs and whether it is acceptable.

## Missing Items

- Items specified but not found in the code.
- Test files missing for: [list DAOs/Queries/Services/routes without coverage].

## Inconsistencies

- Mismatches between spec, code, and architecture notes.
- `docs/data-model.md` out of sync with `app/db/schema.ts`.
```

Verdict:
- **Pass** — all criteria met, checks pass, feature aligns with product requirements.
- **Pass with notes** — all criteria met but minor deviations or inconsistencies exist. List recommendations.
- **Fail** — one or more criteria not met or checks fail. List what needs fixing and suggest re-running `implementing-features`.

Do not modify any code during this skill.

### 6) Finish

If verification passes, set the feature's status to `verified` in `docs/features/manifest.json`. Write `skills.verifying-features = "done"` to `docs/context.json`.

## References

- **Data access architecture**: [data-access-architecture.md](../../shared/references/data-access-architecture.md)

## Review Checklist

- [ ] `docs/context.json` guard passed (`skills.implementing-features = "done"`).
- [ ] Target spec read completely.
- [ ] `docs/prd.md` consulted for product alignment.
- [ ] `docs/data-model.md` checked against `app/db/schema.ts`.
- [ ] `docs/architecture.md` consulted for known deviations.
- [ ] Every spec section checked against the codebase.
- [ ] Implementation checked against `docs/conventions/`.
- [ ] Every acceptance criterion individually evaluated.
- [ ] Integration tests checked for all DAOs, Queries, and Services.
- [ ] Unit tests checked for all route components.
- [ ] `pnpm typecheck`, `pnpm lint`, `pnpm test`, and `pnpm build` run.
- [ ] Report presented with clear per-criterion status and a verdict.
- [ ] No code modified during verification.
- [ ] `docs/context.json` updated with `skills.verifying-features = "done"`.
