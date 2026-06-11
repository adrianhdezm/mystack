# My Personal Stack

A personal Codex stack for packaging and sharing custom development tools.

## My Personal Stack Marketplace

The marketplace makes this stack available inside Codex.

## Product Builder Plugin

Product Builder turns early product ideas into working product foundations. It
helps define the audience, value proposition, workflow, pages, and data model,
then guides Codex through building landing pages, auth, protected routes,
dashboards, and polished product screens.

### Codex installation

Add this repository as a Codex marketplace, then install the plugin:

```sh
codex plugin marketplace add https://github.com/adrianhdezm/mystack
codex plugin add product-builder@my-stack
```

After installing or updating the plugin, start a new Codex thread so the latest
skills are loaded.

### Claude Code installation

Add this repository as a Claude Code marketplace, then install the plugin:

```text
/plugin marketplace add https://github.com/adrianhdezm/mystack
/plugin install product-builder@my-stack
```

Current skills:

- `creating-products`: interviews the user, classifies project complexity,
  orchestrates the required Product Builder skills, proposes the data model and
  page map, and implements after approval.
- `preparing-repositories`: prepares an empty GitHub repository and local clone for Product Builder work.
- `bootstrapping-code`: bootstraps the initial Product Builder codebase after repository preparation completes.
- `adding-database`: adds Cloudflare D1 persistence with Drizzle ORM, Wrangler bindings, migrations, and React Router context.
- `adding-file-storage`: adds Cloudflare R2 file storage with D1 metadata, Wrangler bindings, and React Router context.
- `adding-authentication`: adds Better Auth login, signup, logout, auth routes, secrets, and D1 migrations.
- `react-router-patterns`: defines React Router v7 route design and implementation patterns for consistent route, loader, action, and page creation.

For usage examples, see [Example Usage](docs/example-usage.md).

### Releasing a new version

The plugin version lives in a single source of truth:

```text
plugins/product-builder/VERSION
```

To release, run the release script with the new version:

```sh
./scripts/release-plugin.sh 0.1.13
```

This updates the VERSION file, syncs all three manifests, validates them,
commits, and creates a `0.1.13` git tag. The working tree must be clean before
running.
