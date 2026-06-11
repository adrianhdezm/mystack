# Design Approval

## Proposal content

After the foundation skills finish, propose the domain implementation before editing product-specific code.

Include:

- Product summary and primary user workflow.
- Entities, key fields, relationships, and ownership rules.
- Migration plan, including tables to create or alter and indexes or constraints.
- Page and route map, including public pages, protected pages, dashboard views, resource detail pages, forms, and API/resource routes.
- Authentication and authorization behavior when auth is enabled.
- File storage behavior when R2 is enabled, including metadata fields, allowed file types when known, upload/delete lifecycle, and rollback expectations.
- Initial seed or sample data, if useful for local development.
- Verification plan and commands.
- Implementation sequence.

## Approval prompt

End the proposal with a direct approval request:

```text
Please approve this design or tell me what to change. I will not implement the
domain data model, migrations, pages, or views until you approve it.
```

## Change handling

If the user changes the scope, update the affected sections and ask for approval again. Do not implement a partially approved design unless the user explicitly limits approval to a named subset.

## Implementation after approval

Implement only the approved scope. Preserve generated stack conventions:

- Keep Drizzle schema in `app/db/schema.ts`.
- Keep migrations under `db/migrations`.
- Use React Router loaders/actions and existing app context.
- Use shadcn/ui and Tailwind patterns already present in the project.
- Keep Cloudflare bindings and secrets out of committed source.

Commit the implementation after verification succeeds, or explain any command that cannot run in the current environment.
