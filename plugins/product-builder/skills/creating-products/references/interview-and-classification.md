# Interview and Classification

## Interview Questions

Interview the user to collect enough information to choose the foundation and design the first usable product version. Prefer inference from the prompt and existing repo context. Ask concise follow-up questions only when an answer changes the implementation.

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

## Classification Tiers

- `simple` — mostly public or single-session. Static content, forms without persistence, or a small local-only stateful interface. No database, no authentication, no file storage.
- `standard` — persistent structured data, one primary authenticated user workflow, a dashboard, or a small number of related entities. Database and authentication, no file storage.
- `advanced` — multi-role access, teams, approvals, file workflows, imports/exports, audit history, background processing, billing, external integrations, or several coupled workflows. Database, authentication, and file storage.

## Choosing a Tier

Choose at least `standard` when the product needs saved records, relational data, dashboard state, user-owned data, accounts, private records, protected dashboards, or role-based behavior. Choose `advanced` when the product needs uploads, images, documents, attachments, generated downloadable files, import files, durable exports, teams, approvals, audit history, billing, or external integrations. When uncertain between two classifications, prefer the simpler one and state the tradeoff.

## AI Flag

AI is independent of classification. Add `ai=yes` when the product needs text generation, structured AI output, image generation, LLM-powered features, or OpenAI API integration.

## Presenting for Approval

Present the classification for user approval before proceeding:

```text
PROJECT_COMPLEXITY: simple | standard | advanced
FOUNDATION_CAPABILITIES: database=<yes/no>, authentication=<yes/no>, file_storage=<yes/no>, ai=<yes/no>
RATIONALE: <short reason>
```

If the user changes scope, update and ask for approval again.
