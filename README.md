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

### Example Usage

Use Product Builder with natural-language prompts. The plugin derives the
GitHub repository and local folder from your prompt when possible, and must ask
for any missing or ambiguous repository or local destination before creating
files. It should never create a fallback app in `work/` or another
agent-chosen folder.

Missing repository or local folder:

```text
Use Product Builder to create a meal-planning app for busy parents that turns weekly preferences into grocery lists and quick dinner plans.
```

Expected behavior: ask for the GitHub repository and local parent folder before
preparing or bootstrapping the project.

Existing empty repository with no local clone:

```text
Use Product Builder to bootstrap github.com/<username>/example-product under ~/Code as a lightweight CRM for freelance consultants.
```

Product creation entry point:

```text
Use Product Builder to create github.com/<username>/example-product under ~/Code as a client portal where freelancers can share project updates, invoices, and files with clients.
```

Existing empty repository already cloned locally:

```text
Use Product Builder to turn the empty repository already cloned at ~/Code/example-product into a habit tracker for remote engineering teams.
```

Existing Product Builder project that needs a database:

```text
Use Product Builder to add a database to the existing project at ~/Code/example-product.
```

Existing Product Builder project that needs authentication:

```text
Use Product Builder to add authentication to the existing project at ~/Code/example-product.
```

Existing Product Builder project that needs file uploads:

```text
Use Product Builder to add file storage to the existing project at ~/Code/example-product.
```

Path: `plugins/product-builder`
