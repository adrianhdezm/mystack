---
name: testing-features
description: Writes or extends an E2E test plan for a single feature spec, executes it in a browser via Chrome DevTools MCP, and produces a per-step pass/fail report. Use when the user asks to E2E test, smoke test, or browser-test a feature.
---

# Testing Features

Reads a single feature spec, writes or extends the E2E test plan for that feature, gets user approval, starts the dev server, executes the plan via Chrome DevTools MCP, and produces a per-step pass/fail report.

## Context

**Guard 1 — Feature status** — stop before proceeding if the target feature's status in `docs/features/manifest.json` is not `verified`:

```text
Stop — the target feature is not "verified" in docs/features/manifest.json.
Run verifying-features for this feature first, then re-run this skill.
```

**Guard 2 — Chrome DevTools MCP** — stop immediately if any of these tools are unavailable: `navigate_page`, `click`, `fill`, `screenshot`.

```text
Stop — Chrome DevTools MCP is not connected. Connect Chrome DevTools MCP and re-run this skill.
```

Both guards must pass before any other work begins. Progress is tracked per-feature in `docs/features/manifest.json`, not in `docs/context.json`. Do not write a global skill flag for this skill.

## Rules

- Do not start the dev server until the test plan is approved by the user.
- Use the default test user unless credentials fail (see below) — ask the user for alternatives before retrying.

## Default Test User

```text
Name:     Max Mustermann
Email:    max@example.com
Password: 1234qwer
```

## Input

A feature spec from `docs/features/` (e.g. `docs/features/02-bookmarking.spec.md`). If not provided:

1. Read `docs/features/manifest.json`.
2. Find the first `verified` feature.
3. If exactly one candidate exists, propose it and proceed after confirmation.
4. If multiple candidates exist, list them and ask the user to choose.
5. If no `verified` feature exists, report the current manifest state and stop.

## Workflow

### 1) Read Spec- Read the target feature spec completely — all tasks and their acceptance criteria.

- Read `docs/architecture.md` for known deviations that affect expected behavior.
- Read `docs/conventions/*.md` for UI patterns (toast style, error display, navigation).

### 2) Write or Extend Test Plan

If `tests/e2e/test-plan.md` does not exist, create it with the header and Setup section below. Then append a section for the target feature. Never remove or modify existing feature sections.

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
| ---- | ------ | --------------- |
| 1    | …      | …               |
```

Each feature section lists routes under test and sequential happy-path steps with concrete browser actions and observable expected results. Present the new section and **wait for user approval** before proceeding.

### 3) Start Dev Server

Run `pnpm dev` in the background. Navigate to the app root with `navigate_page` to confirm it is reachable. Stop and report if not reachable after 30 seconds.

### 4) Prepare Test User

Navigate to the login page. Attempt login with the default credentials. If login fails (user does not exist), register and log in. Take a screenshot: `tests/e2e/screenshots/00-login.png`.

### 5) Execute Test Plan for Target Feature

Execute only the section for the target feature:

1. Execute each step using `navigate_page`, `click`, `fill`, `fill_form`, `press_key`, `wait_for`.
2. Verify the expected result is visible after each step.
3. Take a screenshot at key moments and save to `tests/e2e/screenshots/NN-feature-name/step-NN.png`.
4. Record each step as **pass** or **fail** with a note if it failed.

If a step fails, continue with remaining steps and note all failures.

### 6) Stop Dev Server

Stop the `pnpm dev` process.

### 7) Report and Finish

Produce a test report for the target feature:

```markdown
# E2E Test Report — NN Feature Title

## Summary

Overall: A/B steps passed.

## Results

| Step | Action | Expected | Actual | Status | Screenshot |
| ---- | ------ | -------- | ------ | ------ | ---------- |
| 1    | …      | …        | …      | Pass   | [link]     |

## Failures

- **Step X** — what went wrong.
```

Present the report.

## Review Checklist

- [ ] Guard 1 passed — target feature confirmed `verified` in manifest.
- [ ] Guard 2 passed — Chrome DevTools MCP tools confirmed available.
- [ ] Target feature spec read completely including all task acceptance criteria.
- [ ] `tests/e2e/test-plan.md` written or extended — existing sections untouched.
- [ ] New feature section presented and approved before execution.
- [ ] Dev server started and confirmed reachable.
- [ ] Test user registered or confirmed to exist.
- [ ] Every step executed via Chrome DevTools MCP.
- [ ] Screenshots saved to `tests/e2e/screenshots/NN-feature-name/`.
- [ ] Dev server stopped after execution.
- [ ] Test report presented with per-step pass/fail status.
