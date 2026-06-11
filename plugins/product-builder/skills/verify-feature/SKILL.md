---
name: verify-feature
description: Verify a Product Builder feature implementation against its spec from docs/features/, checking acceptance criteria and reporting deviations, missing items, and inconsistencies. Use when the user asks to verify, review, check, validate, or QA a feature implementation.
---

# Verify Feature

## Input

A feature spec from `docs/features/` (e.g., `docs/features/02-color-upload.spec.md`).
If the user does not specify which spec, list available `docs/features/*.spec.md`
files and ask.

## Workflow

### 1) Read Context

- Read the target spec file.
- Read `docs/architecture.md` — use the Data Model section as the expected
  entity/relationship map, and the Implementation Log for known deviations and
  open questions.
- Read dependency specs listed in the Dependencies section.

### 2) Check Implementation

For each section in the spec, verify the code matches:

- **Database**: Confirm tables, columns, indexes, and relationships exist in
  `app/db/schema.ts` and migrations under `db/migrations/`. Verify the Data
  Model section in `docs/architecture.md` matches `app/db/schema.ts`.
- **DAOs**: Confirm DAOs exist in `app/db/daos/` and implement the DAO interface
  per
  [05-data-access-architecture.md](../adding-database/references/05-data-access-architecture.md).
- **Services**: Confirm services exist in `app/services/` with correct
  transaction boundaries and DAO composition.
- **Routes**: Confirm route files exist, paths are registered in
  `app/routes.ts`, and loaders/actions match the spec.
- **Components**: Confirm shadcn/ui components are installed and custom
  components are created as specified.
- **Auth**: If routes are marked as protected, confirm authentication checks are
  in place.
- **Conventions**: Check that the implementation follows project conventions and
  avoids anti-patterns listed in `docs/architecture.md`.

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

Produce a verification report with these sections:

```markdown
# Verification: NN — Title

## Summary

One-line: overall status (pass / pass with notes / fail).

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
- Data Model in `docs/architecture.md` out of sync with `app/db/schema.ts`.

## Recommendations

- Suggested fixes or follow-up work.
```

Present the report to the user. Do not modify code — this skill is read-only.
If there are failing criteria or missing items, suggest running
`implement-feature` again with the spec to address them.

## Validation Checklist

- [ ] Target spec was read completely.
- [ ] `docs/architecture.md` was consulted for known deviations.
- [ ] Data Model in `docs/architecture.md` was checked against
      `app/db/schema.ts` for consistency.
- [ ] Every spec section (database, routes, components, services) was checked
      against the codebase.
- [ ] Every acceptance criterion was individually evaluated.
- [ ] `pnpm typecheck`, `pnpm lint`, and `pnpm build` were run.
- [ ] Report was presented with clear status for each criterion.
- [ ] No code was modified during verification.
