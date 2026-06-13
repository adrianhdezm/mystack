# Feature Manifest

The file `docs/features/manifest.json` tracks every feature and its current status throughout the product lifecycle. All feature skills read and update this file.

```json
{
  "product": "<product-name>",
  "features": [
    {
      "id": "00",
      "name": "short-name",
      "title": "Human-readable title",
      "spec": "00-short-name.spec.md",
      "status": "listed",
      "depends_on": []
    }
  ]
}
```

- `id` — two-digit number that determines implementation order. Lower numbers first. A feature is never implemented before all features it `depends_on` are `verified`.
- `name` — kebab-case slug used in the spec filename.
- `title` — human-readable feature name.
- `spec` — filename of the spec in `docs/features/`.
- `status` — current lifecycle state.
- `depends_on` — array of `id` values this feature depends on.

| Status         | Meaning                          | Set by                  |
| -------------- | -------------------------------- | ----------------------- |
| `listed`       | In the manifest, no spec yet     | `creating-products`     |
| `ready`        | Spec written and approved        | `planning-features`     |
| `implementing` | Implementation in progress       | `implementing-features` |
| `implemented`  | Code written, needs verification | `implementing-features` |
| `verified`     | Passed verification              | `verifying-features`    |
| `blocked`      | Needs user input                 | any skill               |

Features with no dependencies get the lowest numbers. When multiple features share the same dependencies, assign adjacent numbers — they are still implemented sequentially in `id` order.
