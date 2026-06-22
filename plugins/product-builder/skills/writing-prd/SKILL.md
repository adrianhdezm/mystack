---
name: writing-prd
description: Interviews the user, determines foundation capabilities, and writes a Product Requirements Document to docs/prd.md. Use when the user wants to create a PRD, define a product, or document product requirements before building.
---

# Writing PRD

Interviews the user to reach shared product understanding, derives the required foundation capabilities, presents them for approval, and writes `docs/prd.md`.

## Context

Set `skills.writing-prd` to `in-progress` at the start. If `docs/context.json` does not exist, create it using the default template from [context-schema.md](../../shared/references/context-schema.md). On success write:

```json
{
  "skills": { "writing-prd": "done" }
}
```

## Workflow

### 1) Get the Problem Description

Ask the user for a detailed description of the problem they want to solve and any solution ideas. Do not proceed until you have a substantive answer.

### 2) Explore the Repo

Read `docs/prd.md` if it exists — use it as prior context. Scan `docs/`, `README.md`, and `AGENTS.md` for existing product documentation.

### 3) Interview the User

Interview until you reach shared understanding. Prefer inference over questions — ask only when an answer materially changes the product or implementation. Cover at minimum:

- Who are the target users / personas?
- What pain points or jobs-to-be-done does this solve?
- What does success look like? (metrics, outcomes)
- Walk through every screen, flow, or endpoint the product requires — inputs, outputs, edge cases, error states.
- What are we **not** doing in this version? Push back until the boundary is crisp.
- What records must be saved between sessions?
- Is data private to a user, shared with a team, public, or admin-only?
- Are accounts, roles, invitations, or protected pages required?
- Are uploads, generated files, imports, exports, or attachments required?
- Does the product need a public landing or marketing page?
- What are the must-have pages or views for the first version?
- What external services, payments, email, AI APIs, or integrations are needed?

### 4) Determine Foundation Capabilities

From the interview, fill in `Value` and `Rationale` for each capability. Prefer inference.

Signals: `database` — persistent state, relational data, or user-owned records. `authentication` — accounts, login, protected pages, or per-user data (requires `database`). `file_storage` — uploads, attachments, or durable binary assets (requires `database`). `ai` — text/image generation, structured AI output, or OpenAI integration. `landing_page` — public marketing page before login. `legal_pages` — Impressum, Privacy Policy, or Terms (requires `landing_page`).

Enforce dependencies: if `authentication=yes` → `database=yes`; if `file_storage=yes` → `database=yes`; if `legal_pages=yes` → `landing_page=yes`.

Present the table for user approval. Re-enforce dependencies and re-present if the user changes any value. Do not proceed until explicitly approved.

| Capability       | Value    | Rationale |
| ---------------- | -------- | --------- |
| `database`       | yes / no | …         |
| `authentication` | yes / no | …         |
| `file_storage`   | yes / no | …         |
| `ai`             | yes / no | …         |
| `landing_page`   | yes / no | …         |
| `legal_pages`    | yes / no | …         |

### 5) Write the PRD

Write `docs/prd.md` using [assets/prd-template.md](assets/prd-template.md). Present it to the user for approval before writing the file. Write only after approval.

### 6) Update Context

Write `skills.writing-prd = "done"` to `docs/context.json`.

## References

- **PRD template**: [assets/prd-template.md](assets/prd-template.md)

## Review Checklist

- [ ] User provided a substantive problem description before the interview began.
- [ ] Existing repo documentation was read before interviewing.
- [ ] All interview topics covered or noted as not applicable.
- [ ] User stories cover happy paths, edge cases, and error scenarios.
- [ ] Every screen or flow has a corresponding entry in User Interaction and Design.
- [ ] Out of Scope section has at least one entry.
- [ ] Capabilities table presented and explicitly approved before writing.
- [ ] User approved the full PRD before `docs/prd.md` was written.
- [ ] `docs/context.json` updated with `skills.writing-prd = "done"`.
