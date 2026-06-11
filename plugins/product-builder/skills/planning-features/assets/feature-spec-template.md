# NN — Title

## Goal

One sentence: what this spec achieves for the user.

## Database Changes

Changes relative to the current data model in `docs/data-model.md`:

- New tables with key columns, types, and constraints.
- Columns added or altered on existing tables.
- New indexes and foreign key relationships.
- Migration notes.

## Pages and Routes

| Path       | Route File    | Type | Auth   | Description        |
| ---------- | ------------- | ---- | ------ | ------------------ |
| `/example` | `example.tsx` | page | yes/no | What the page does |

For each route, note loader and action responsibilities.

## Components

- shadcn/ui components to install or use (e.g., `Card`, `Dialog`, `DataTable`).
- Custom components to create, with purpose and location.

## Services and DAOs

- DAOs to create (one per new table).
- Services to create or modify, with workflow description.

## Acceptance Criteria

1. When [action], then [expected result].
2. Given [state], when [action], expect [outcome].

## Dependencies

List spec numbers this depends on (e.g., "Requires 00, 01"). Write "None" if standalone.

## Notes

Optional. Non-obvious constraints, workarounds, or tradeoffs only.
