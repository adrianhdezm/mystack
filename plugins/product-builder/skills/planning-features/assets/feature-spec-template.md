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
- For delete actions, plan a shadcn `Dialog` confirmation on the list or detail page instead of a separate delete route.
- Custom components to create, with purpose and location.

## DAOs, Queries, and Services

- DAOs to create (one per new table).
- Queries to create (one per cross-table read, in `app/db/queries/`).
- Services to create or modify, with workflow description.

## Tasks

Numbered implementation units. Each task is a vertical slice — it touches every layer it needs and produces a committable, working increment. Tasks are implemented in dependency order; tasks whose `depends_on` are all `done` may run independently.

### Task NN.01 — Title

**Layers**: e.g. schema migration, DAO  
**depends_on**: [] or [NN.0X, …]

Acceptance criteria:

1. When [action], then [expected result].

### Task NN.02 — Title

**Layers**: e.g. service, loader/action  
**depends_on**: [NN.01]

Acceptance criteria:

1. When [action], then [expected result].

### Task NN.03 — Title

**Layers**: e.g. page component, form, feedback states  
**depends_on**: [NN.02]

Acceptance criteria:

1. When [action], then [expected result].

## Test Considerations

- **DAO tests**: which CRUD operations need explicit coverage (e.g., filter combinations that represent business rules).
- **Query tests**: which cross-table reads to verify, including edge cases like empty relations.
- **Service tests**: which workflows and error scenarios matter.
- **Component tests**: key interactions to verify (if applicable).

## Dependencies

List feature spec numbers this depends on (e.g., "Requires 01, 02"). Write "None" if standalone.

## Notes

Optional. Non-obvious constraints, workarounds, or tradeoffs only.
