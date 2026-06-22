# My Personal Stack

A personal stack for packaging and sharing custom development tools as plugins for Codex and Claude Code.

## Marketplace

The marketplace registries make this stack's plugins available for installation:

- **Codex** — `.agents/plugins/marketplace.json`
- **Claude Code** — `.claude-plugin/marketplace.json`

## Product Builder Plugin

Product Builder turns early product ideas into working product foundations. It helps define the audience, value proposition, workflow, pages, and data model, then guides the agent through building landing pages, auth, protected routes, dashboards, and polished product screens on a Cloudflare Workers + React Router v7 stack. After the initial product is built, it supports an iterative feature lifecycle — each feature is planned with a numbered spec and task breakdown, implemented task-by-task with a commit per task, verified against acceptance criteria, and E2E-tested via Chrome DevTools MCP. `docs/prd.md` is a living document extended with each new feature.

### Installation

**Codex**

```sh
codex plugin marketplace add https://github.com/adrianhdezm/mystack
codex plugin add product-builder@mystack
```

**Claude Code**

```text
/plugin marketplace add https://github.com/adrianhdezm/mystack
/plugin install product-builder@mystack
```

After installing or updating the plugin, start a new thread so the latest skills are loaded.

### Skills

#### Product creation

- `creating-products` — orchestrates the full product lifecycle across four phases: repository setup, PRD interview, foundation scaffolding, and a per-feature loop (plan → implement → verify → test).
- `preparing-repositories` — prepares an empty GitHub repository and local clone; creates `docs/context.json`.
- `scaffolding-project` — scaffolds the initial codebase (pnpm, TypeScript, Vite, Cloudflare Workers, React Router v7, Tailwind CSS v4, shadcn/ui).

#### Infrastructure

- `adding-database` — adds Cloudflare D1 persistence with Drizzle ORM, Wrangler bindings, migrations, and React Router context.
- `adding-authentication` — adds Better Auth email-and-password login, signup, logout, auth routes, and D1 migrations.
- `adding-file-storage` — adds Cloudflare R2 file storage with D1 metadata, Wrangler bindings, and React Router context.
- `adding-ai` — adds Vercel AI SDK with OpenAI provider for text generation, structured output, and image generation.
- `adding-landing-page` — adds a public-facing landing page with Hero, Features, and CTA sections.
- `adding-legal-pages` — adds Impressum, Privacy Policy, and Terms of Service pages.

#### Feature lifecycle

- `adding-features` — drives the full post-launch cycle for a single new feature: update PRD, register in manifest, plan spec with tasks, implement task-by-task, verify, and E2E test.
- `planning-features` — plans a feature end-to-end (database changes, pages, components, numbered tasks with acceptance criteria) and saves a spec to `docs/features/`.
- `implementing-features` — implements a feature spec task-by-task, committing after each task and maintaining `docs/data-model.md`, `docs/conventions/`, and `docs/architecture.md`.
- `verifying-features` — read-only verification of a feature against its spec; checks all task acceptance criteria and produces a structured report.
- `testing-features` — writes and executes a happy-path E2E test plan for a single feature via Chrome DevTools MCP.

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
