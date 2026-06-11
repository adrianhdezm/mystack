---
name: creating-products
description: Orchestrates Product Builder from a product idea into an approved implementation plan and working product. Use when the user asks to create, build, start, scaffold, or turn a product idea into an application with Product Builder.
---

# Creating Products

## Purpose

Use this as the Product Builder entry point. It interviews the user, classifies
project complexity, prepares the project foundation with the required Product
Builder skills, then proposes and implements the approved product model and
views.

## Required inputs

Before repository actions, require or derive the same inputs as
`preparing-repositories`:

```text
REPOSITORY: <owner>/<repo>
LOCAL_FOLDER: <parent-folder>
PRODUCT_IDEA: <short description>
```

If the repository or local folder is missing, run `preparing-repositories`; it
must ask only for missing blocking values. Do not create fallback folders.

## Workflow

1. Interview the user using [interview-and-decisions.md](references/interview-and-decisions.md).
   Ask only for information that cannot be inferred and materially changes the
   foundation or product design.
2. Classify the project as `simple`, `standard`, or `advanced`.
3. Select foundation capabilities from the classification matrix:
   - `simple`: no database, no authentication, no file storage.
   - `standard`: database and authentication, no file storage.
   - `advanced`: database, authentication, and file storage.
4. Prepare the repository by running `preparing-repositories`.
5. Bootstrap the app by running `bootstrapping-code` with the returned
   `LOCAL_REPOSITORY_PATH` and `REPOSITORY_STATUS`.
6. Add foundation capabilities in dependency order based on project
   classification:
   - `simple`: skip `adding-database`, `adding-authentication`, and
     `adding-file-storage`.
   - `standard`: run `adding-database`, then `adding-authentication`; skip
     `adding-file-storage`.
   - `advanced`: run `adding-database`, then `adding-authentication`, then
     `adding-file-storage`.
7. Load `react-router-patterns` before planning or adding any
   React Router code. Use it to plan the route map, route files,
   loader/action responsibilities, redirects, and protected route behavior.
8. Produce a design proposal using [design-approval.md](references/design-approval.md).
   Include the data model, migrations, routes/pages, permissions, storage
   behavior, and implementation sequence.
9. Stop and ask for approval before implementing domain-specific schema,
   migrations, pages, views, actions, loaders, or services.
10. After approval, implement the approved design in the target project. Any
    React Router code must follow `react-router-patterns` and
    the generated Product Builder stack.
11. Verify with formatting, typecheck, lint, build, relevant migrations, and any
    feature-specific checks. Fix issues before finishing when possible.
12. Commit the approved implementation using the project Conventional Commits
    format and summarize the foundation skills used, user-approved design, commit
    hash, verification results, and any failed commands.

## Approval gate

Do not treat the initial product idea as approval for the detailed product
design. The user must approve the proposed data model, migrations, and page/view
map before domain implementation begins.

If the user requests a change during review, update the proposal and ask for
approval again before implementing.

## Validation checklist

- [ ] Interview captured the core users, workflow, data, privacy, uploads, and
      collaboration needs.
- [ ] Complexity and matrix-derived capabilities are stated before foundation
      work.
- [ ] Repository preparation and bootstrapping completed before add-on skills.
- [ ] Database was added before file storage or authentication when required.
- [ ] `react-router-patterns` was loaded and followed for the
      route map, route modules, loaders, actions, redirects, and protected route
      behavior.
- [ ] Domain-specific data model, migrations, and pages were approved before
      implementation.
- [ ] Formatting, typecheck, lint, build, and relevant migration commands were
      run or failures were explained.
- [ ] Final summary includes foundation skills used, commit hash, and residual
      risks.
