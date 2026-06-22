---
name: testing-features
description: Generates a happy-path E2E test plan from all feature specs in docs/features/, then executes it in a browser via Chrome DevTools MCP. Use when the user asks to E2E test, smoke test, or browser-test implemented features.
---

# Test Features

## Context

Read [context-schema.md](../../shared/references/context-schema.md) for the full `docs/context.json` schema, field reference, and guard pattern.

**Guard** — stop before proceeding if `context.skills.planning-features` is not `"done"` in `docs/context.json`. Stop with:

```text
Stop — docs/context.json is missing skills.planning-features = "done". Run planning-features first, then re-run this skill.
```

Set `skills.testing-features` to `in-progress` at the start of the workflow. On successful completion, set it to `done`.

**Writes:**

```json
{
  "skills": { "testing-features": "done" }
}
```

## Input

All feature specs from `docs/features/*.spec.md`. If none exist, stop and tell the user to run `planning-features` first.

## Hard Rules

- Require Chrome DevTools MCP to be available before starting. Check that `navigate_page`, `click`, `fill`, and `screenshot` tools are available. If any are missing, stop immediately and tell the user to connect Chrome DevTools MCP before running this skill.
- Require `context.skills.planning-features = "done"` in `docs/context.json`. If missing, stop and direct the user to run `planning-features` first.
- Do not start the dev server until the test plan is approved by the user.

## Test User (default)

Use the following credentials for all E2E tests:

```text
Name:     Max Mustermann
Email:    max@example.com
Password: 1234qwer
```

If registration with these credentials fails (e.g., email domain restrictions, password policy), ask the user for valid credentials before proceeding. Do not retry silently or skip the test user step.

## Workflow

### 1) Read Specs

- Read every `docs/features/*.spec.md` file.
- Read `docs/architecture.md` for known deviations that affect expected behavior.
- Read `docs/conventions/*.md` for UI patterns (toast style, error display, navigation).

### 2) Write Test Plan

Create `docs/e2e/test-plan.md` with the following structure:

```markdown
# E2E Test Plan

## Test User

- Name: Max Mustermann
- Email: max@example.com
- Password: 1234qwer

## Setup

1. Start dev server
2. Navigate to app root
3. Check if test user exists (attempt login) — if not, register

## Features

### NN — Feature Title

**Routes:** `/path-a`, `/path-b`

| Step | Action | Expected Result |
| ---- | ------ | --------------- |
| 1    | ...    | ...             |
| 2    | ...    | ...             |
```

Each feature section lists the routes under test and a table of sequential happy-path steps. Steps should be concrete browser actions (navigate, click, fill, submit) with observable expected results (text appears, redirect happens, element visible).

Present the plan to the user and **wait for approval** before proceeding.

### 3) Start Dev Server

- Run `pnpm dev` in the background.
- Wait for the server to be reachable by navigating to the app root with `navigate_page`.
- If the server is not reachable after 30 seconds, stop and report the failure.

### 4) Prepare Test User

- Navigate to the login page.
- Attempt to log in with the test user credentials.
- If login fails (user does not exist), navigate to the registration page and register the test user, then log in.
- Take a screenshot after successful login: `docs/e2e/screenshots/00-login.png`.

### 5) Execute Test Plan

For each feature section in the plan, in order:

1. Execute each step using Chrome DevTools MCP tools (`navigate_page`, `click`, `fill`, `fill_form`, `press_key`, `wait_for`).
2. After each step, verify the expected result is visible on the page.
3. Take a screenshot at key moments (after form submissions, after navigation, on final result) and save to `docs/e2e/screenshots/NN-feature-name-step-NN.png`.
4. Record the step result as **pass** or **fail** with a note if it failed.

If a step fails, continue with the remaining steps in that feature, then proceed to the next feature.

### 6) Stop Dev Server

- Stop the `pnpm dev` process started in step 3.

### 7) Report

Produce a test report:

```markdown
# E2E Test Report

## Summary

Overall: X/Y features passed, A/B total steps passed.

## Results

### NN — Feature Title

| Step | Action | Expected | Actual | Status | Screenshot |
| ---- | ------ | -------- | ------ | ------ | ---------- |
| 1    | ...    | ...      | ...    | Pass   | [link]     |

### Failures

- **NN — Feature Title, Step X** — description of what went wrong.
```

Present the report to the user.

### 8) Update Context

Write `skills.testing-features = "done"` to `docs/context.json`.

## Validation Checklist

- [ ] All `docs/features/*.spec.md` files were read.
- [ ] `docs/e2e/test-plan.md` was written and approved by the user before execution.
- [ ] Dev server was started and confirmed reachable.
- [ ] Test user was registered or confirmed to exist.
- [ ] Every step in the plan was executed via Chrome DevTools MCP.
- [ ] Screenshots were saved to `docs/e2e/screenshots/`.
- [ ] Dev server was stopped after execution.
- [ ] Test report was presented with per-step pass/fail status.
- [ ] `docs/context.json` guards passed (`skills.planning-features = "done"`).
- [ ] `docs/context.json` was updated with `skills.testing-features = "done"`.
