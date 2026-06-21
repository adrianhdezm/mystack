# Product Requirements Document

## Problem Statement

The problem that the user is facing, from the user's perspective. Include who is affected and why it matters.

## Solution

The proposed solution, described from the user's perspective. Focus on **what** the product does, not how it is built.

## User Stories

A numbered list of user stories covering happy paths, edge cases, and error scenarios. Each story follows the format:

1. As a `<actor>`, I want `<feature>`, so that `<benefit>`.

## User Interaction and Design

Describe every screen, page, modal, or API endpoint the product introduces or modifies. For each:

- **Purpose**: What the user accomplishes here.
- **Layout / Structure**: Key UI elements, their placement, and hierarchy (or request/response shape for APIs).
- **Inputs & Controls**: Fields, buttons, dropdowns, toggles — with types, defaults, and validation rules.
- **Outputs & Feedback**: What the user sees on success, on error, and while loading.
- **Navigation / Flow**: How the user arrives here and where they go next.
- **Edge Cases**: Empty states, permission-denied states, concurrent edits, offline behavior, etc.

If wireframes or mockups exist, reference them here. ASCII sketches are acceptable when no design tool is available.

## Assumptions

- **Technical**: e.g., "Users will be on modern browsers with JavaScript enabled."
- **Business**: e.g., "Free-tier users will not have access to this feature."
- **User Behavior**: e.g., "Users will complete onboarding before reaching this screen."

Flag any assumption that carries significant risk if wrong. Do not list Foundation Capabilities here — those are recorded in the Foundation Capabilities section.

## Out of Scope

Explicitly list features, flows, or variations intentionally excluded from this version. For each, briefly state why (e.g., deferred to v2, low user demand, blocked by dependency). Include tangential topics, unrelated bugs, or future ideas that came up during discussion but do not belong here.

## Success Metrics

- Primary metric(s) and target value
- Secondary / guardrail metrics
- How and when they will be measured

## Further Notes

Open questions, risks, dependencies on other teams, or relevant context.

## Foundation Capabilities

| Capability       | Depends On     | Value  | Rationale       |
| ---------------- | -------------- | ------ | --------------- |
| `database`       | —              | yes/no | <!-- reason --> |
| `authentication` | `database`     | yes/no | <!-- reason --> |
| `file_storage`   | `database`     | yes/no | <!-- reason --> |
| `ai`             | —              | yes/no | <!-- reason --> |
| `landing_page`   | —              | yes/no | <!-- reason --> |
| `legal_pages`    | `landing_page` | yes/no | <!-- reason --> |
