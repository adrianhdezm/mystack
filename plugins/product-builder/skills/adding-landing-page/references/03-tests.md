# 03 - Tests

## Overview

Landing page tests are unit tests that live in `tests/unit/routes/home.test.tsx`. They use `createRoutesStub` from `react-router` and `render` from `vitest-browser-react` so the route component receives data through the router exactly as in production.

No integration test is needed — the landing page has no database access or server-side data fetching.

## Steps

### 1. Create the test file

Create `tests/unit/routes/home.test.tsx`.

```tsx
import { render } from "vitest-browser-react";
import { createRoutesStub } from "react-router";
import { describe, expect, it } from "vitest";
import { page } from "@vitest/browser/context";
import HomePage from "~/routes/home";

function renderHomePage() {
  const Stub = createRoutesStub([
    {
      path: "/",
      Component: HomePage,
    },
  ]);
  return render(<Stub initialEntries={["/"]} />);
}

describe("HomePage", () => {
  it("renders the hero headline", async () => {
    renderHomePage();
    // Replace with the real headline text from docs/vision.md
    await expect
      .element(page.getByRole("heading", { level: 1 }))
      .toBeInTheDocument();
  });

  it("renders the features section", async () => {
    renderHomePage();
    await expect
      .element(page.getByRole("heading", { level: 2 }))
      .toBeInTheDocument();
  });

  it("renders the primary CTA link", async () => {
    renderHomePage();
    // Replace with the real CTA label text from docs/vision.md
    await expect
      .element(page.getByRole("link", { name: /get started/i }))
      .toBeInTheDocument();
  });

  it("CTA link points to the signup route", async () => {
    renderHomePage();
    await expect
      .element(page.getByRole("link", { name: /get started/i }))
      .toHaveAttribute("href", "/signup");
  });
});
```

Replace the heading text and CTA label matchers with values from the actual product content in `docs/vision.md`.

### 2. Run the unit tests

```sh
pnpm test:unit
```

All tests must pass before committing. If `pnpm test:unit` is not available as a script, run:

```sh
pnpm test --project unit
```

### 3. Add SiteHeader and SiteFooter smoke tests (optional)

If the public layout shell components are substantive (e.g., they render nav links or the product name), add a second test file at `tests/unit/components/landing/SiteHeader.test.tsx`:

```tsx
import { render } from "vitest-browser-react";
import { createRoutesStub } from "react-router";
import { describe, expect, it } from "vitest";
import { page } from "@vitest/browser/context";
import { SiteHeader } from "~/components/landing/SiteHeader";

function renderHeader() {
  // Wrap in a stub router so <Link> components resolve correctly
  const Stub = createRoutesStub([
    {
      path: "/",
      Component: () => <SiteHeader />,
    },
  ]);
  return render(<Stub initialEntries={["/"]} />);
}

describe("SiteHeader", () => {
  it("renders the product name", async () => {
    renderHeader();
    // Replace with actual product name
    await expect
      .element(page.getByRole("link", { name: /product name/i }))
      .toBeInTheDocument();
  });

  it("renders login and signup links when authentication is present", async () => {
    renderHeader();
    await expect
      .element(page.getByRole("link", { name: /log in/i }))
      .toBeInTheDocument();
    await expect
      .element(page.getByRole("link", { name: /get started/i }))
      .toBeInTheDocument();
  });
});
```

Add these only when the header contains non-trivial rendered content worth asserting. Skip if the header renders only static structure.

## Implementation Notes

- All test functions must be `async`.
- Use `page` from `@vitest/browser/context` for element queries — Playwright locators, strict by default.
- Use `expect.element()` (not `expect()`) for DOM assertions — it retries until the DOM settles.
- Import `HomePage` via the `~/` path alias, not a relative path.
- Always wrap components that contain `<Link>` in a `createRoutesStub` — `<Link>` requires a router context and throws without one.
- Do not stub `SiteHeader` or `SiteFooter` in the route test — render them as-is so the test catches broken imports.

## Expected Results

- `tests/unit/routes/home.test.tsx` exists and all tests pass with `pnpm test:unit`.
- Tests assert the hero heading, features section, and CTA link are rendered.
- No mocks of React Router internals are needed — `createRoutesStub` handles routing context.
