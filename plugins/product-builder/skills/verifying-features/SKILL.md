---
name: verifying-features
description: Verifies a Product Builder feature implementation against its spec from docs/features/, checking acceptance criteria and reporting deviations, missing items, and inconsistencies. Use when the user asks to verify, review, check, validate, or QA a feature implementation.
---

# Verify Feature

## Input

A feature spec from `docs/features/` (e.g., `docs/features/02-color-upload.spec.md`). If the user does not specify which spec, list available `docs/features/*.spec.md` files and ask.

## Workflow

### 1) Read Context

- Read the target spec file.
- Read `docs/vision.md` — use it to verify the feature aligns with the product's pitch, target users, primary workflow, and entry point flow.
- Read `docs/data-model.md` — use it as the expected entity/relationship map.
- Read `docs/architecture.md` — use the Implementation Log for known deviations and open questions.
- Read all `docs/conventions/*.md` files for project-specific patterns and anti-patterns to verify against.
- Read dependency specs listed in the Dependencies section.

### 2) Check Implementation

For each section in the spec, verify the code matches:

- **Database**: Confirm tables, columns, indexes, and relationships exist in `app/db/schema.ts` and migrations under `db/migrations/`. Verify `docs/data-model.md` matches `app/db/schema.ts`.
- **DAOs**: Confirm DAOs exist in `app/db/daos/` and implement the `Dao` interface per [data-access-architecture.md](../../shared/references/data-access-architecture.md).
- **Queries**: Confirm relation queries exist in `app/db/queries/` for any cross-table reads and implement the `RelationQuery` interface per [data-access-architecture.md](../../shared/references/data-access-architecture.md). Verify services use queries instead of raw Drizzle joins.
- **Services**: Confirm services exist in `app/services/` with correct transaction boundaries, DAO composition, and query delegation. Verify services do not import schema tables or build raw Drizzle queries.
- **Routes**: Confirm route files exist, paths are registered in `app/routes.ts`, and loaders/actions match the spec.
- **Components**: Confirm shadcn/ui components are installed and custom components are created as specified.
- **Auth**: If routes are marked as protected, confirm authentication checks are in place.
- **Conventions**: Check that the implementation follows project conventions (patterns and anti-patterns) in `docs/conventions/`.

### 3) Walk Acceptance Criteria

For each acceptance criterion in the spec:

1. Trace the code path that fulfills it.
2. Mark as **met**, **partially met**, or **not met**.
3. For partially met or not met, describe what is missing or different.

### 4) Run Checks

- Run `pnpm typecheck` and report the result.
- Run `pnpm lint` and report the result.
- Run `pnpm build` and report the result.

### 5) Report

Produce a static verification report with these sections:

```markdown
# Verification: NN — Title

## Acceptance Criteria

| #   | Criterion      | Status                        | Notes   |
| --- | -------------- | ----------------------------- | ------- |
| 1   | When X, then Y | Met / Partially met / Not met | Details |

## Deviations from Spec

- **Area** — what differs and whether it is acceptable.

## Missing Items

- Items specified but not found in the code.

## Inconsistencies

- Mismatches between spec, code, and architecture notes.
- `docs/data-model.md` out of sync with `app/db/schema.ts`.
```

Do not modify code — this skill is read-only.

### 6) Update Manifest

If `docs/features/manifest.json` exists and verification passes (Pass or Pass with notes), set the feature's status to `verified`.

### 7) Result

Present the verification report to the user with a verdict:

- **Pass** — all acceptance criteria met, checks pass, and feature aligns with the product vision.
- **Pass with notes** — all criteria met but there are minor deviations, inconsistencies, or vision alignment concerns. List recommendations.
- **Fail** — one or more acceptance criteria not met, checks fail, or feature contradicts the product vision. List the specific items that need to be fixed and suggest running `implementing-features` again with the spec to address them.

## Validation Checklist

- [ ] Target spec was read completely.
- [ ] `docs/vision.md` was consulted to verify feature aligns with product vision.
- [ ] `docs/data-model.md` was checked against `app/db/schema.ts` for consistency.
- [ ] `docs/architecture.md` was consulted for known deviations.
- [ ] Every spec section (database, DAOs, queries, services, routes, components) was checked against the codebase.
- [ ] Implementation was checked against project conventions and anti-patterns in `docs/conventions/`.
- [ ] Every acceptance criterion was individually evaluated.
- [ ] `pnpm typecheck`, `pnpm lint`, and `pnpm build` were run.
- [ ] Report was presented with clear status for each criterion.
- [ ] Verdict was presented (Pass, Pass with notes, or Fail).
- [ ] No code was modified during verification.
