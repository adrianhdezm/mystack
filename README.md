# My Personal Stack

A personal stack for packaging and sharing custom development tools as plugins for Codex and Claude Code.

## Marketplace

The marketplace registries make this stack's plugins available for installation:

- **Codex** — `.agents/plugins/marketplace.json`
- **Claude Code** — `.claude-plugin/marketplace.json`

## Product Builder Plugin

Product Builder turns early product ideas into working product foundations. It helps define the audience, value proposition, workflow, pages, and data model, then guides the agent through building landing pages, auth, protected routes, dashboards, and polished product screens. After the initial product is built, it supports an iterative feature lifecycle — plan, implement, and verify — driven by numbered feature specs.

### Installation

**Codex**

```sh
codex plugin marketplace add https://github.com/adrianhdezm/mystack
codex plugin add product-builder@my-stack
```

**Claude Code**

```text
/plugin marketplace add https://github.com/adrianhdezm/mystack
/plugin install product-builder@my-stack
```

After installing or updating the plugin, start a new thread so the latest skills are loaded.

### Skills

#### Product creation

- `creating-products` — interviews the user, classifies project complexity, orchestrates the required Product Builder skills, proposes the data model and page map, and implements after approval.
- `preparing-repositories` — prepares an empty GitHub repository and local clone for Product Builder work.
- `bootstrapping-code` — bootstraps the initial codebase (pnpm, TypeScript, Vite, Cloudflare Workers, React Router v7, Tailwind CSS v4, shadcn/ui).

#### Infrastructure

- `adding-database` — adds Cloudflare D1 persistence with Drizzle ORM, Wrangler bindings, migrations, and React Router context.
- `adding-file-storage` — adds Cloudflare R2 file storage with D1 metadata, Wrangler bindings, and React Router context.
- `adding-authentication` — adds Better Auth email-and-password login, signup, logout, auth routes, secrets, and D1 migrations.

#### Feature lifecycle

- `planning-features` — plans a feature end-to-end (database changes, pages, components, acceptance criteria) and saves a numbered spec to `docs/features/`.
- `implementing-features` — implements a feature spec from `docs/features/` as a full vertical slice, maintaining `docs/data-model.md`, `docs/conventions/`, and `docs/architecture.md`.
- `verifying-features` — verifies a feature implementation against its spec, checking acceptance criteria and reporting deviations or missing items.

#### Patterns

- `react-router-patterns` — defines React Router v7 route design and implementation patterns for consistent route, loader, action, and page creation.

For usage examples, see [Example Usage](docs/example-usage.md).

### Shared resources

Skills share common references and templates under `plugins/product-builder/shared/`:

- `references/` — cross-skill reference material (data-access architecture, documentation update rules).
- `templates/` — starter templates for project documentation (architecture, conventions, data model).

### Releasing a new version

The plugin version lives in a single source of truth:

```text
plugins/product-builder/VERSION
```

To release, run the release script with the new version:

```sh
./scripts/release-plugin.sh 0.1.13
```

This updates the VERSION file, syncs all manifests, validates them, commits, and creates a git tag. The working tree must be clean before running.
