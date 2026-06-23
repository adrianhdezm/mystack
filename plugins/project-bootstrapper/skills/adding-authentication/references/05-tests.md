# 05 - Auth Route Tests

## Overview

Auth route tests are unit tests that verify the login and signup form components render correctly and display errors from action responses. They live in `tests/unit/routes/` alongside any existing route tests.

Tests use `createRoutesStub` from `react-router` and `render` from `vitest-browser-react` so each route component receives data through the router exactly as in production.

The logout route is a resource route with no default component export — it has no UI to test. The `api/auth/*` route delegates directly to Better Auth's handler — its behavior is covered by integration and E2E tests, not unit tests.

## Conventions

### File placement

One test file per auth route component:

- `tests/unit/routes/login.test.tsx`
- `tests/unit/routes/signup.test.tsx`

### Render helpers

Each test file defines two render helpers:

- `render<Route>()` — wraps the route component in `createRoutesStub` with no action stub. Used for rendering tests.
- `render<Route>WithAction(actionFn)` — same, but with an `action` stub so tests can simulate error responses. Used for Conform error tests.

Both helpers must set `path` and `initialEntries` to the route's actual path (e.g., `/login`, `/signup`).

### What to test per auth form route

Each test file should cover these categories:

1. **Heading** — the route's primary heading renders.
2. **Form fields** — every labeled input in the form is present. Query by `getByLabelText` using the `<Label>` text from the route component.
3. **Submit button** — the form's submit button renders.
4. **Cross-route link** — login links to signup, signup links to login. Assert both presence and `href`.
5. **Form-level error from action** — stub the action to return a Conform error, fill and submit the form, then assert the error alert appears.

### Conform action error stubs

Stub the `action` to return a Conform `SubmissionResult` object. The `initialValue` field **must** be present or Conform silently ignores the result:

```tsx
action: () => ({
  status: "error",
  initialValue: { email: "test@example.com", password: "wrong" },
  error: { "": ["Incorrect username or password"] },
});
```

- The `error` key `""` (empty string) is a form-level error — the component should render it in an element with `role="alert"`.
- Field-level errors use the field name as key (e.g., `{ email: ["Please enter a valid email address"] }`).
- `initialValue` must include all fields the form submits, with the values used in the test's `.fill()` calls.

To test this: fill every required field, click submit, then assert `page.getByRole("alert")` is in the document.

### Labels and text

Match labels and headings against the actual rendered text in the route component — do not assume fixed strings. Read the login and signup route files before writing tests.

## Steps

### 1. Create login and signup test files

Create `tests/unit/routes/login.test.tsx` and `tests/unit/routes/signup.test.tsx` following the conventions above.

For login, the form fields are `email` and `password`.

For signup, the form fields are `name`, `email`, `password`, and `confirmPassword`.

### 2. Run the unit tests

```sh
pnpm test:unit
```

All tests must pass before committing. If `pnpm test:unit` is not available as a script, run:

```sh
pnpm test --project unit
```

## Implementation Notes

- `render()` from `vitest-browser-react` returns a `Promise<RenderResult>`. Use `void render(...)` in non-async render helpers when the result is not needed — this satisfies `@typescript-eslint/no-floating-promises` without making the helper async.
- `createRoutesStub` returns a loosely typed `StubRouteObject[]` that triggers `@typescript-eslint/no-unsafe-assignment`. Add a per-directory ESLint override for `tests/**` disabling this rule, or use `// eslint-disable-next-line @typescript-eslint/no-unsafe-assignment` at the call site.
- When the signup form has both "Password" and "Confirm Password" labels, use `page.getByLabelText('Password', { exact: true })` to avoid Playwright strict-mode errors from ambiguous matches.
- Use `page` from `vitest/browser` for element queries — Playwright locators, strict by default. Do not use `@vitest/browser/context`, which is deprecated in Vitest 4.x.
- Use `expect.element()` (not `expect()`) for DOM assertions — it retries until the DOM settles.
- Import route components via the `~/` path alias, not a relative path.
- Always wrap components that contain `<Link>` or `<Form>` in a `createRoutesStub` — they require a router context and throw without one.
- The logout route has no default export — do not create a component test for it.

## Expected Results

- `tests/unit/routes/login.test.tsx` exists and all tests pass with `pnpm test:unit`.
- `tests/unit/routes/signup.test.tsx` exists and all tests pass with `pnpm test:unit`.
- Login tests assert: heading, form fields, submit button, signup link, and action error display.
- Signup tests assert: heading, form fields, submit button, login link, and action error display.
