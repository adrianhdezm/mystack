---
name: writing-prd
description: Interviews the user, determines foundation capabilities, and writes a Product Requirements Document to docs/prd.md. Use when the user wants to create a PRD, define a product, or document product requirements before building.
---

# Writing PRD

## Input

A product idea, problem description, or feature brief from the user. If none is provided, ask for one before proceeding.

## Workflow

### 1) Get the Problem Description

Ask the user for a long, detailed description of the problem they want to solve and any potential ideas for solutions. Do not proceed until you have a substantive answer.

### 2) Explore the Repo

Read `docs/prd.md` if it exists — use it as prior context before interviewing. Scan the repo for any existing product documentation (`docs/`, `README.md`, `AGENTS.md`) to understand the current product surface and user-facing behavior.

### 3) Interview the User

Interview the user about every **product** aspect until you reach shared understanding. Prefer inference over questions — ask only when an answer materially changes the product or its implementation. Cover at minimum:

- Who are the target users / personas?
- What pain points or jobs-to-be-done does this solve?
- What does success look like? (metrics, outcomes)
- Walk through every screen, flow, or endpoint the product requires — inputs, outputs, edge cases, error states.
- What are we **not** doing in this version? Push back until the boundary is crisp.
- What assumptions is the user making (technical, business, user behavior)?
- What records must be saved between sessions?
- Is data private to a user, shared with a team, public, or admin-only?
- Are accounts, roles, invitations, or protected pages required?
- Are uploads, generated files, imports, exports, or attachments required?
- Does the product need a public landing or marketing page, or should visitors go straight to login or signup?
- What are the must-have pages or views for the first version?
- What external services, payments, email, AI APIs, or integrations are needed?

### 4) Determine Foundation Capabilities

From the interview answers, fill in the `Value` and `Rationale` for each capability. Prefer inference — ask only when an answer cannot be determined from what the user has already described.

Signals per capability:

- `database` — product saves records between sessions, has relational data, user-owned data, dashboards, or any persistent state.
- `authentication` — product needs accounts, login, protected pages, roles, invitations, or per-user data. Requires `database`.
- `file_storage` — product needs uploads, images, documents, attachments, generated downloadable files, import/export files, or durable binary assets. Requires `database`.
- `ai` — product needs text generation, structured AI output, image generation, LLM-powered features, or an OpenAI API integration.
- `landing_page` — product needs a public marketing or informational page visitors see before logging in or signing up.
- `legal_pages` — product needs an Impressum, Privacy Policy, and/or Terms of Service. Requires `landing_page`.

Enforce dependencies before presenting: if `authentication=yes`, set `database=yes`; if `file_storage=yes`, set `database=yes`; if `legal_pages=yes`, set `landing_page=yes`.

Present the filled-in table for user approval:

| Capability       | Value    | Rationale |
| ---------------- | -------- | --------- |
| `database`       | yes / no | …         |
| `authentication` | yes / no | …         |
| `file_storage`   | yes / no | …         |
| `ai`             | yes / no | …         |
| `landing_page`   | yes / no | …         |
| `legal_pages`    | yes / no | …         |

If the user changes any value, re-enforce dependencies, update the table, and re-present. Do not proceed until the user explicitly approves.

### 5) Write the PRD

Once the interview is complete and the capabilities are approved, write `docs/prd.md` using the template in [assets/prd-template.md](assets/prd-template.md). Present it to the user for approval before writing the file. After approval, write the file.

## Validation Checklist

- [ ] User provided a substantive problem description before the interview began.
- [ ] Existing repo documentation was read before interviewing.
- [ ] All interview topics were covered or explicitly noted as not applicable.
- [ ] User stories cover happy paths, edge cases, and error scenarios.
- [ ] Every screen or flow mentioned in user stories has a corresponding entry in User Interaction and Design.
- [ ] Out of Scope section has at least one entry.
- [ ] Capabilities block was presented and explicitly approved by the user before writing the file.
- [ ] User approved the full PRD before `docs/prd.md` was written.
