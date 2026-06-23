# My Personal Stack

A personal stack for packaging and sharing custom development tools as plugins for Codex and Claude Code.

## Marketplace

The marketplace registries make this stack's plugins available for installation:

- **Codex** — `.agents/plugins/marketplace.json`
- **Claude Code** — `.claude-plugin/marketplace.json`

---

## Project Bootstrapper Plugin

Project Bootstrapper sets up a new project from scratch. It collects the product idea and deployment target, selects infrastructure capabilities, scaffolds the codebase, and runs all foundation skills — committing a runnable project ready for product development.

Supports two deployment targets:

- **Cloudflare** — Workers + D1 + R2 + React Router
- **Docker/Postgres** — Node.js (Hono) + Postgres + RustFS + React Router

### Installation

**Codex**

```sh
codex plugin marketplace add https://github.com/adrianhdezm/mystack
codex plugin add project-bootstrapper@mystack
```

**Claude Code**

```text
/plugin marketplace add https://github.com/adrianhdezm/mystack
/plugin install project-bootstrapper@mystack
```

### Skills

#### Orchestration

- `bootstrapping-projects` — orchestrates the full bootstrap: repository preparation → capability selection → scaffold → foundation skills → commit.

#### Repository and capabilities

- `preparing-repositories` — creates or validates the GitHub remote, clones locally, and writes `docs/context.json`.
- `selecting-capabilities` — collects the product idea and deployment target, presents the infrastructure capability menu (database, auth, file storage, AI), and writes approved selections to `docs/context.json`.

#### Scaffold

- `scaffolding-project` — scaffolds the base stack (pnpm, TypeScript, Vite, React Router, Tailwind CSS v4, shadcn/ui) and dispatches to the deployment-target-specific infrastructure (Cloudflare Workers or Docker/Postgres Node.js server).

#### Infrastructure

- `adding-database` — adds a database (Cloudflare D1 + Drizzle ORM, or Postgres + Drizzle ORM) with migrations and React Router context.
- `adding-authentication` — adds Better Auth email/password login, signup, logout, and auth routes with Drizzle adapter.
- `adding-file-storage` — adds object storage (Cloudflare R2 or RustFS/S3) with file metadata table and React Router context.
- `adding-ai` — adds Vercel AI SDK with OpenAI provider for text generation, structured output, and image generation.

### Updating the plugin

After a new version is released, update the plugin in your agent:

**Codex**

```sh
codex plugin update project-bootstrapper@mystack
```

**Claude Code**

```text
/plugin update project-bootstrapper@mystack
```

### Releasing a new version

```sh
./scripts/release-plugin.sh project-bootstrapper 0.1.1
```

---

## Product Builder Plugin

Product Builder drives product development on a bootstrapped project. It writes the PRD, runs any product-layer capabilities (landing page, legal pages), then drives features through a plan → implement → verify → test lifecycle. The PRD is a living document extended with each new feature.

**Requires a project bootstrapped by `project-bootstrapper` first.**

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

### Skills

#### Orchestration

- `creating-products` — orchestrates the full product lifecycle: bootstrap check → PRD → product capabilities → feature list → per-feature loop (plan → implement → verify → test).

#### PRD

- `writing-prd` — interviews the user about product features, flows, and personas; determines landing page and legal page needs; writes `docs/prd.md`.

#### Product capabilities

- `adding-landing-page` — adds a public-facing landing page with Hero, Features, and CTA sections.
- `adding-legal-pages` — adds Impressum, Privacy Policy, and Terms of Service pages.

#### Feature lifecycle

- `adding-features` — drives the full post-launch cycle for a single new feature: update PRD, register in manifest, plan spec, implement, verify, and E2E test.
- `planning-features` — plans a feature end-to-end (database changes, pages, components, numbered tasks with acceptance criteria) and saves a spec to `docs/features/`.
- `implementing-features` — implements a feature spec task-by-task, committing after each task and maintaining `docs/data-model.md`, `docs/conventions/`, and `docs/architecture.md`.
- `verifying-features` — read-only verification of a feature against its spec; checks all task acceptance criteria and produces a structured report.
- `testing-features` — writes and executes a happy-path E2E test plan for a single feature via Chrome DevTools MCP.

#### Patterns

- `react-router-patterns` — defines React Router route design and implementation patterns for consistent route, loader, action, and page creation.

### Updating the plugin

After a new version is released, update the plugin in your agent:

**Codex**

```sh
codex plugin update product-builder@mystack
```

**Claude Code**

```text
/plugin update product-builder@mystack
```

### Releasing a new version

```sh
./scripts/release-plugin.sh product-builder 0.2.1
```
