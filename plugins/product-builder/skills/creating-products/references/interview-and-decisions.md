# Interview And Decisions

## Interview goals

Collect enough information to choose the foundation and design the first usable
product version. Prefer inference from the prompt and existing repo context.
Ask concise follow-up questions only when an answer changes the implementation.

## Core questions

Ask or infer:

- Who uses the product, and what job are they trying to complete?
- What is the primary workflow from first visit to completed outcome?
- What records must be saved between sessions?
- Is data private to a user, shared with a team, public, or admin-only?
- Are accounts, roles, invitations, or protected pages required?
- Are uploads, generated files, imports, exports, or attachments required?
- What are the must-have pages or views for the first version?
- What external services, payments, email, AI APIs, or integrations are needed?
- What should be avoided in the first version?

## Complexity classification

Use `simple` when the product is mostly public or single-session and can be
delivered with static content, forms without persistence, or a small local-only
stateful interface.

Use `standard` when the product has persistent structured data, one primary
authenticated user workflow, a dashboard, or a small number of related entities.

Use `advanced` when the product has multi-role access, teams, approvals, file
workflows, imports/exports, audit history, background processing, billing,
external integrations, or several coupled workflows.

## Foundation capability matrix

After classification, use this fixed mapping:

- `simple`: no database, no authentication, no file storage.
- `standard`: database and authentication, no file storage.
- `advanced`: database, authentication, and file storage.

Use capability needs to choose the classification:

- Choose at least `standard` when the product needs saved records, relational
  data, dashboard state, user-owned data, accounts, private records, protected
  dashboards, or role-based behavior.
- Choose `advanced` when the product needs uploads, images, documents,
  attachments, generated downloadable files, import files, durable exports,
  teams, approvals, audit history, billing, or external integrations.

When uncertain between two classifications, prefer the simpler classification
and state the tradeoff. Do not add foundation capabilities independently from
the classification matrix.

## Decision output

Before running foundation skills, state:

```text
PROJECT_COMPLEXITY: simple | standard | advanced
FOUNDATION_CAPABILITIES: database=<yes/no>, file_storage=<yes/no>, authentication=<yes/no>
RATIONALE: <short reason>
```
