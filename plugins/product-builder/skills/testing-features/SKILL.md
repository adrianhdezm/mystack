---
name: testing-features
description: Generates a happy-path E2E test plan from all feature specs in docs/features/, then executes it in a browser via Chrome DevTools MCP. Use when the user asks to E2E test, smoke test, or browser-test implemented features.
---

# Testing Features

Reads all feature specs, writes a happy-path E2E test plan, gets user approval, starts the dev server, executes the plan via Chrome DevTools MCP, and produces a per-step pass/fail report.

## Context

**Guard** — stop before proceeding if `context.skills.planning-features` is not `"done"`:

```text
Stop — docs/context.json is missing skills.planning-features = "done". Run planning-features first, then re-run this skill.
```

Set `skills.testing-features` to `in-progress` at the start. On success write:

```json
{
  "skills": { "testing-features": "done" }
}
```

## Rules

- Require Chrome DevTools MCP before starting. Confirm `navigate_page`, `click`, `fill`, and `screenshot` are available — stop immediately if any are missing and tell the user to connect Chrome DevTools MCP.
- Do not start the dev server until the test plan is approved by the user.
- Use the default test user unless credentials fail (see below) — ask the user for alternatives before retrying.

## Default Test User

```text
Name:     Max Mustermann
Email:    max@example.com
Password: 1234qwer
```

## Workflow

### 1) Read Specs

- Read every `docs/features/*.spec.md`.
- Read `docs/architecture.md` for known deviations that affect expected behavior.
- Read `docs/conventions/*.md` for UI patterns (toast style, error display, navigation).

### 2) Write Test Plan

Create `docs/e2e/test-plan.md`:

```markdown
# E2E Test Plan

## Test User
- Name: Max Mustermann
- Email: max@example.com
- Password: 1234qwer

## Setup
1. Start dev server
2. Navigate to app root
3. Attempt login — if login fails, register then log in

## Features

### NN — Feature Title

**Routes:** `/path-a`, `/path-b`

| Step | Action | Expected Result |
|------|--------|-----------------|
| 1    | …      | …               |
```

Each feature section lists routes under test and sequential happy-path steps with concrete browser actions and observable expected results. Present the plan and **wait for user approval** before proceeding.

### 3) Start Dev Server

Run `pnpm dev` in the background. Navigate to the app root with `navigate_page` to confirm it is reachable. Stop and report if not reachable after 30 seconds.

### 4) Prepare Test User

Navigate to the login page. Attempt login with the default credentials. If login fails (user does not exist), register and log in. Take a screenshot: `docs/e2e/screenshots/00-login.png`.

### 5) Execute Test Plan

For each feature in order:

1. Execute each step using `navigate_page`, `click`, `fill`, `fill_form`, `press_key`, `wait_for`.
2. Verify the expected result is visible after each step.
3. Take a screenshot at key moments and save to `docs/e2e/screenshots/NN-feature-name-step-NN.png`.
4. Record each step as **pass** or **fail** with a note if it failed.

If a step fails, continue with remaining steps in that feature, then proceed to the next feature.

### 6) Stop Dev Server

Stop the `pnpm dev` process.

### 7) Report and Finish

Produce a test report:

```markdown
# E2E Test Report

## Summary
Overall: X/Y features passed, A/B steps passed.

## Results

### NN — Feature Title

| Step | Action | Expected | Actual | Status | Screenshot |
|------|--------|----------|--------|--------|------------|
| 1    | …      | …        | …      | Pass   | [link]     |

### Failures
- **NN — Feature Title, Step X** — what went wrong.
```

Present the report. Write `skills.testing-features = "done"` to `docs/context.json`.

## Review Checklist

- [ ] `docs/context.json` guard passed (`skills.planning-features = "done"`).
- [ ] Chrome DevTools MCP tools confirmed available before starting.
- [ ] All `docs/features/*.spec.md` files read.
- [ ] `docs/e2e/test-plan.md` written and approved before execution.
- [ ] Dev server started and confirmed reachable.
- [ ] Test user registered or confirmed to exist.
- [ ] Every step executed via Chrome DevTools MCP.
- [ ] Screenshots saved to `docs/e2e/screenshots/`.
- [ ] Dev server stopped after execution.
- [ ] Test report presented with per-step pass/fail status.
- [ ] `docs/context.json` updated with `skills.testing-features = "done"`.
