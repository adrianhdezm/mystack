# Example Usage

Use Product Builder with natural-language prompts. The plugin derives the GitHub repository and local folder from your prompt when possible, and must ask for any missing or ambiguous repository or local destination before creating files. It should never create a fallback app in `work/` or another agent-chosen folder.

## Missing repository or local folder

```text
Use Product Builder to create a meal-planning app for busy parents that turns weekly preferences into grocery lists and quick dinner plans.
```

Expected behavior: ask for the GitHub repository and local parent folder before preparing or bootstrapping the project.

## Existing empty repository with no local clone

```text
Use Product Builder to bootstrap github.com/<username>/example-product under ~/Code as a lightweight CRM for freelance consultants.
```

## Product creation entry point

```text
Use Product Builder to create github.com/<username>/example-product under ~/Code as a client portal where freelancers can share project updates, invoices, and files with clients.
```

## Existing empty repository already cloned locally

```text
Use Product Builder to turn the empty repository already cloned at ~/Code/example-product into a habit tracker for remote engineering teams.
```

## Existing Product Builder project that needs a database

```text
Use Product Builder to add a database to the existing project at ~/Code/example-product.
```

## Existing Product Builder project that needs authentication

```text
Use Product Builder to add authentication to the existing project at ~/Code/example-product.
```

## Existing Product Builder project that needs file uploads

```text
Use Product Builder to add file storage to the existing project at ~/Code/example-product.
```
