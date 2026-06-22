---
name: writing-prd
description: Interviews the user, determines foundation capabilities, and writes or updates the Product Requirements Document at docs/prd.md. Use when the user wants to create a PRD, define a product, document product requirements before building, or extend the PRD with a new feature after the first version ships.
---

# Writing PRD

Interviews the user to reach shared product understanding, derives the required foundation capabilities, presents them for approval, and writes `docs/prd.md`. When the PRD already exists, runs in **update mode**: extends the document with new functionality without altering settled sections.

## Context

**Guard** — stop before proceeding if `repository.local_path` is not set in `docs/context.json`:

```text
Stop — docs/context.json is missing repository.local_path.
Run preparing-repositories first, then re-run this skill.
```

If `docs/context.json` does not exist at all, the same condition applies — stop and run `preparing-repositories` first.

## Mode Detection

Read `docs/prd.md` before doing anything else.

- **Create mode** — file does not exist or is empty. Run the full workflow below.
- **Update mode** — file exists with content. Skip to [Update Mode Workflow](#update-mode-workflow).

---

## Create Mode Workflow

### 1) Get the Problem Description

Ask the user for a detailed description of the problem they want to solve and any solution ideas. Do not proceed until you have a substantive answer.

### 2) Explore the Repo

Scan `docs/`, `README.md`, and `AGENTS.md` for existing product documentation.

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

Write capabilities to `docs/context.json` based on the approved table: set each capability to `"planned"` if Value=yes, `"skipped"` if Value=no.

---

## Update Mode Workflow

Extends `docs/prd.md` with new functionality. Does **not** alter the Problem Statement, Solution, Foundation Capabilities table, or any existing user stories and UI sections — those are settled. The PRD is a cumulative record; append, never rewrite.

### 1) Read Existing PRD and Context

- Read `docs/prd.md` in full — understand what the product already does.
- Read `docs/features/manifest.json` if it exists — know what features are already `verified` or in flight.
- Scan `docs/features/` for existing specs to understand implemented scope.

### 2) Get the Feature Description

If a feature description was passed in by the caller (e.g. from `adding-features`), use it directly — do not re-ask. Only prompt the user when no description has been supplied. Do not proceed without a substantive answer.

### 3) Interview for the New Feature

Keep the interview focused on the new feature only. Prefer inference over questions. Cover:

- What does the user see and do? Walk through every screen, input, and output.
- What are we **not** doing in this addition? Push back until the boundary is crisp.
- What new data must be saved? Is it private, shared, or public?
- What are the edge cases and error states?
- Are there dependencies on existing features?

### 4) Draft the Feature Addition

Prepare the content to be added to the PRD:

- **New user stories** — numbered, continuing from the last existing story number.
- **New UI/flow sections** — one entry per new screen, page, or flow, following the same format as existing entries.
- **Out of Scope additions** — anything explicitly excluded from this addition.
- **Success Metrics additions** — how this feature's success is measured.
- **Further Notes additions** — open questions or risks specific to this feature.

Do **not** modify the Foundation Capabilities table unless a genuinely new capability is required (e.g., adding file storage to a product that previously had none). If a capability changes, re-present the full table for approval before writing.

Present the drafted additions to the user for approval. Write only after approval.

### 5) Update the PRD

Append the approved content to the relevant sections of `docs/prd.md`. Each addition should be clearly delineated — prefix new user story blocks or UI sections with a short comment like `<!-- Feature: <name> -->` so the document remains navigable as it grows.

### 6) Update Context

Update mode does not modify capabilities — the Foundation Capabilities table is settled. No context writes are needed unless a genuinely new capability is being added (in which case set it to `"planned"`).

---

## References

- **PRD template**: [assets/prd-template.md](assets/prd-template.md)

## Review Checklist

**Both modes**

- [ ] Guard passed — `repository.local_path` is set in `docs/context.json`.

**Create mode**

- [ ] User provided a substantive problem description before the interview began.
- [ ] Existing repo documentation was read before interviewing.
- [ ] All interview topics covered or noted as not applicable.
- [ ] User stories cover happy paths, edge cases, and error scenarios.
- [ ] Every screen or flow has a corresponding entry in User Interaction and Design.
- [ ] Out of Scope section has at least one entry.
- [ ] Capabilities table presented and explicitly approved before writing.
- [ ] User approved the full PRD before `docs/prd.md` was written.
- [ ] `docs/context.json` updated with `planned`/`skipped` for each capability.

**Update mode**

- [ ] Existing PRD and manifest read before interviewing.
- [ ] Interview focused on the new feature only — settled sections not revisited.
- [ ] New user stories continue the existing numbering sequence.
- [ ] New UI sections follow the same format as existing entries.
- [ ] Foundation Capabilities table only modified if a genuinely new capability is required; if so, set it to `"planned"` in context.
- [ ] Drafted additions presented and approved before writing.
- [ ] Existing PRD content left intact — only appended, never rewritten.

**Both modes**

- [ ] `docs/context.json` exists with default template if it was missing.
