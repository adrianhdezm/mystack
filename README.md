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

Use Product Builder with an empty GitHub repository:

```text
Use Product Builder to bootstrap a new product repository.

REPOSITORY: adrianhdezm/example-product
LOCAL_FOLDER: /Users/adrian/Code

First run preparing-repositories, then run bootstrapping-code with the returned
LOCAL_REPOSITORY_PATH and REPOSITORY_STATUS.
```

Path: `plugins/product-builder`
