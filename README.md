# My Personal Stack

A personal Codex stack for packaging and sharing custom development tools.

## My Personal Stack Marketplace

The marketplace makes this stack available inside Codex.

## Product Builder Plugin

Product Builder turns early product ideas into working product foundations. It
helps define the audience, value proposition, workflow, pages, and data model,
then guides Codex through building landing pages, auth, protected routes,
dashboards, and polished product screens.

### Installation

Add this repository as a Codex marketplace, then install the plugin:

```sh
codex plugin marketplace add https://github.com/adrianhdezm/mystack
codex plugin add product-builder@my-stack
```

After installing or updating the plugin, start a new Codex thread so the latest
skills are loaded.

Current skills:

- `preparing-repositories`: prepares an empty GitHub repository and local clone for Product Builder work.
- `bootstrapping-code`: bootstraps the initial Product Builder codebase after repository preparation completes.

### Example Usage

Use Product Builder with natural-language prompts. The plugin derives the
GitHub repository and local folder from your prompt when possible, and asks for
only the missing or ambiguous value when it cannot.

No repository yet, just the idea:

```text
Use Product Builder to create a meal-planning app for busy parents that turns weekly preferences into grocery lists and quick dinner plans.
```

Existing empty repository with no local clone:

```text
Use Product Builder to bootstrap github.com/<username>/example-product under ~/Code as a lightweight CRM for freelance consultants.
```

Existing empty repository already cloned locally:

```text
Use Product Builder to turn the empty repository already cloned at ~/Code/example-product into a habit tracker for remote engineering teams.
```

Path: `plugins/product-builder`
