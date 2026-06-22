# Example Usage

Use Product Builder with natural-language prompts. The plugin derives the GitHub repository and local folder from your prompt when possible, and must ask for any missing or ambiguous repository or local destination before creating files. It should never create a fallback app in `work/` or another agent-chosen folder.

---

## Creating a product

### Missing repository or local folder

```text
Use Product Builder to create a meal-planning app for busy parents that turns weekly preferences into grocery lists and quick dinner plans.
```

Expected behavior: ask for the GitHub repository and local parent folder before proceeding.

### Existing empty repository with no local clone

```text
Use Product Builder to bootstrap github.com/<username>/example-product under ~/Code as a lightweight CRM for freelance consultants.
```

### Existing empty repository already cloned locally

```text
Use Product Builder to turn the empty repository already cloned at ~/Code/example-product into a habit tracker for remote engineering teams.
```

---

## Adding a feature to an existing product

### Add the next planned feature

```text
Use Product Builder to add the next feature to the product at ~/Code/example-product.
```

Expected behavior: reads `docs/features/manifest.json`, proposes the first eligible `listed` feature, and drives the full plan → implement → verify → test cycle.

### Add a specific new feature

```text
Use Product Builder to add a CSV export feature to the product at ~/Code/example-product.
```

Expected behavior: updates `docs/prd.md` with the new feature, registers it in the manifest, plans the spec with tasks, implements task-by-task, verifies, and runs E2E tests.

---

## Adding infrastructure to an existing project

### Add a database

```text
Use Product Builder to add a database to the existing project at ~/Code/example-product.
```

### Add authentication

```text
Use Product Builder to add authentication to the existing project at ~/Code/example-product.
```

### Add file storage

```text
Use Product Builder to add file storage to the existing project at ~/Code/example-product.
```

### Add AI

```text
Use Product Builder to add AI to the existing project at ~/Code/example-product.
```
