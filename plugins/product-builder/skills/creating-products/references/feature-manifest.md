# Feature Manifest

The file `docs/features/manifest.json` tracks every feature and its tasks throughout the product lifecycle. All feature skills read and update this file.

```json
{
  "product": "<product-name>",
  "features": [
    {
      "id": "01",
      "name": "short-name",
      "title": "Human-readable title",
      "spec": "01-short-name.spec.md",
      "status": "listed",
      "depends_on": [],
      "tasks": [
        {
          "id": "01.01",
          "title": "Schema and DAOs",
          "status": "pending",
          "depends_on": []
        },
        {
          "id": "01.02",
          "title": "Service and routes",
          "status": "pending",
          "depends_on": ["01.01"]
        },
        {
          "id": "01.03",
          "title": "UI",
          "status": "pending",
          "depends_on": ["01.02"]
        }
      ]
    }
  ]
}
```

## Feature Fields

- `id` — two-digit number that determines implementation order. Lower numbers first. A feature is never implemented before all features it `depends_on` are `verified`.
- `name` — kebab-case slug used in the spec filename.
- `title` — human-readable feature name.
- `spec` — filename of the spec in `docs/features/`.
- `status` — current lifecycle state (see Feature Status table below).
- `depends_on` — array of feature `id` values this feature depends on.
- `tasks` — ordered list of implementation units within this feature. Populated by `planning-features`; empty array `[]` until planning is complete.

## Task Fields

- `id` — dot-notation id: `<feature-id>.<two-digit-task-number>` (e.g. `01.02`).
- `title` — short label describing the slice of work (e.g. "Schema and DAOs").
- `status` — current task lifecycle state (see Task Status table below).
- `depends_on` — array of task `id` values within the same feature that must be `done` before this task starts. Tasks with no dependencies may start immediately once the feature is `implementing`.

## Feature Status

| Status | Meaning | Set by |
| --- | --- | --- |
| `listed` | In the manifest, no spec yet | `creating-products`, `adding-features` |
| `ready` | Spec written, tasks populated, approved | `planning-features` |
| `implementing` | At least one task is `implementing` | `implementing-features` |
| `implemented` | All tasks are `done` | `implementing-features` |
| `verified` | Passed verification | `verifying-features` |
| `blocked` | Needs user input | any skill |

## Task Status

| Status         | Meaning                    | Set by                  |
| -------------- | -------------------------- | ----------------------- |
| `pending`      | Not yet started            | `planning-features`     |
| `implementing` | Implementation in progress | `implementing-features` |
| `done`         | Implemented and committed  | `implementing-features` |
| `blocked`      | Needs user input           | any skill               |

## Derived Feature Status Rules

Feature status is derived from its tasks by `implementing-features`:

- Any task is `implementing` → feature is `implementing`
- Any task is `blocked` → feature is `blocked`
- All tasks are `done` → feature advances to `implemented`

Feature status is never set manually when tasks are present — always derived from task state.

**Blocked task invariant**: when a task is set to `blocked`, its status must be written to the manifest before the agent advances to the next task. This ensures the manifest is always consistent — a task is never left at `pending` or `implementing` while the feature is marked `blocked`.

## Ordering Rules

Features with no dependencies get the lowest numbers. When multiple features share the same dependencies, assign adjacent numbers — they are still implemented sequentially in `id` order.

Tasks within a feature are implemented in dependency order. Tasks whose `depends_on` are all `done` may be started; tasks with no `depends_on` may start immediately when the feature begins implementation.
