---
name: writing-prd
description: Interviews the user about product features and writes or updates the Product Requirements Document at docs/prd.md. Requires a bootstrapped project (run project-bootstrapper first). Use when the user wants to create a PRD, document product requirements, or extend the PRD with a new feature.
---

# Writing PRD

Interviews the user to reach shared product understanding and writes `docs/prd.md`. Reads the committed project code and `docs/context.json` to understand what infrastructure is already wired. When the PRD already exists, runs in **update mode**: extends the document with new functionality without altering settled sections.

## Context

**Guards** — stop before proceeding if any of these are missing from `docs/context.json`:
- `repository.local_path` — working directory
- `project.deployment_target` — needed to understand what's wired
- `capabilities.*` — all set to `"planned"`, `"skipped"`, or `"ready"` by `project-bootstrapper`

```text
Stop — docs/context.json is missing repository.local_path, project.deployment_target, or capabilities.*.
Run project-bootstrapper → bootstrapping-projects first, then re-run this skill.
```

**Capabilities are not selected here.** They were selected and committed by `project-bootstrapper` → `selecting-capabilities`. This skill reads them from context — it does not write them.

## Mode Detection

Read `docs/prd.md` before doing anything else.

- **Create mode** — file does not exist or is empty. Run the full workflow below.
- **Update mode** — file exists with content. Skip to [Update Mode Workflow](#update-mode-workflow).

---

## Create Mode Workflow

### 1) Read the Committed Project

Before interviewing, read:
- `docs/context.json` — `project.idea`, `project.deployment_target`, `capabilities.*`
- `docs/architecture.md` — understand what's already scaffolded
- `README.md` and `AGENTS.md` — existing project documentation
- `app/db/schema.ts` if it exists — understand the current data model

Use `project.idea` as the seed for the product description. Use `capabilities.*` to understand which infrastructure is already wired (database, auth, file storage, AI, landing page, legal pages).

### 2) Interview the User

Interview until you reach shared understanding of the product features. The infrastructure is already decided — focus only on product behavior. Prefer inference over questions — ask only when an answer materially changes the product or implementation. Cover at minimum:

- Who are the target users / personas?
- What pain points or jobs-to-be-done does this solve?
- What does success look like? (metrics, outcomes)
- Walk through every screen, flow, or endpoint the product requires — inputs, outputs, edge cases, error states.
- What are we **not** doing in this version? Push back until the boundary is crisp.
- What records must be saved between sessions?
- Is data private to a user, shared with a team, public, or admin-only?
- What are the must-have pages or views for the first version?
- What external services, payments, email, or integrations are needed (beyond what's already wired)?

Do not re-interview about capabilities already set in context — those decisions are committed.

### 3) Write the PRD

Write `docs/prd.md` using [assets/prd-template.md](assets/prd-template.md). The Foundation Capabilities table should reflect the `capabilities.*` values from `docs/context.json` — mark each as included or not included. Present the PRD to the user for approval before writing the file. Write only after approval.

---

## Update Mode Workflow

Extends `docs/prd.md` with new functionality. Does **not** alter the Problem Statement, Solution, Foundation Capabilities table, or any existing user stories and UI sections — those are settled. The PRD is a cumulative record; append, never rewrite.

### 1) Read Existing PRD and Context

- Read `docs/prd.md` in full — understand what the product already does.
- Read `docs/features/manifest.json` if it exists — know what features are already `verified` or in flight.
- Scan `docs/features/` for existing specs to understand implemented scope.

### 2) Get the Feature Description

If a feature description was passed in by the caller (e.g. from `adding-features`), use it directly — do not re-ask. Only prompt the user when no description has been supplied.

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

Present the drafted additions to the user for approval. Write only after approval.

### 5) Update the PRD

Append the approved content to the relevant sections of `docs/prd.md`. Each addition should be clearly delineated — prefix new user story blocks or UI sections with a short comment like `<!-- Feature: <name> -->`.

---

## References

- **PRD template**: [assets/prd-template.md](assets/prd-template.md)

## Review Checklist

**Both modes**

- [ ] Guards passed — `repository.local_path`, `project.deployment_target`, and `capabilities.*` set in `docs/context.json`.

**Create mode**

- [ ] Committed code and context read before interviewing.
- [ ] All interview topics covered or noted as not applicable.
- [ ] User stories cover happy paths, edge cases, and error scenarios.
- [ ] Every screen or flow has a corresponding entry in User Interaction and Design.
- [ ] Out of Scope section has at least one entry.
- [ ] Foundation Capabilities table reflects `capabilities.*` from context.
- [ ] User approved the full PRD before `docs/prd.md` was written.
- [ ] `docs/prd.md` written only after explicit approval.

**Update mode**

- [ ] Existing PRD and manifest read before interviewing.
- [ ] Interview focused on the new feature only — settled sections not revisited.
- [ ] New user stories continue the existing numbering sequence.
- [ ] New UI sections follow the same format as existing entries.
- [ ] Drafted additions presented and approved before writing.
- [ ] Existing PRD content left intact — only appended, never rewritten.
