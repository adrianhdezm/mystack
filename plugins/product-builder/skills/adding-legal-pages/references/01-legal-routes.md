# 01 - Legal Routes

## Overview

Each legal page is a named route registered in `app/routes.ts` under the same public layout as the landing page. They are served publicly without authentication.

Only create the routes the user requested (see `INCLUDE_IMPRESSUM`, `INCLUDE_PRIVACY_POLICY`, `INCLUDE_TERMS`).

## Steps

### 1. Create the route files

Create one file per requested legal page.

**`app/routes/impressum.tsx`** (`INCLUDE_IMPRESSUM=yes`)

```tsx
import type { Route } from "./+types/impressum";

export const meta: Route.MetaFunction = () => [
  { title: "Impressum" },
  { name: "robots", content: "noindex" },
];

export default function ImpressumPage(_props: Route.ComponentProps) {
  return (
    <div className="container max-w-3xl py-16">
      <h1 className="mb-8 text-3xl font-bold">Impressum</h1>
      {/* Content populated in 02-legal-content.md */}
    </div>
  );
}
```

**`app/routes/privacy-policy.tsx`** (`INCLUDE_PRIVACY_POLICY=yes`)

```tsx
import type { Route } from "./+types/privacy-policy";

export const meta: Route.MetaFunction = () => [
  { title: "Privacy Policy" },
  { name: "robots", content: "noindex" },
];

export default function PrivacyPolicyPage(_props: Route.ComponentProps) {
  return (
    <div className="container max-w-3xl py-16">
      <h1 className="mb-8 text-3xl font-bold">Privacy Policy</h1>
      {/* Content populated in 02-legal-content.md */}
    </div>
  );
}
```

**`app/routes/terms.tsx`** (`INCLUDE_TERMS=yes`)

```tsx
import type { Route } from "./+types/terms";

export const meta: Route.MetaFunction = () => [
  { title: "Terms of Service" },
  { name: "robots", content: "noindex" },
];

export default function TermsPage(_props: Route.ComponentProps) {
  return (
    <div className="container max-w-3xl py-16">
      <h1 className="mb-8 text-3xl font-bold">Terms of Service</h1>
      {/* Content populated in 02-legal-content.md */}
    </div>
  );
}
```

The `noindex` meta tag prevents search engines from indexing legal pages, which is standard practice.

### 2. Register the legal routes in `app/routes.ts`

Open `app/routes.ts` and add the legal routes inside the existing `layout("routes/public-layout.tsx", [...])` block. Preserve every route already registered.

```ts
import {
  index,
  layout,
  route,
  type RouteConfig,
} from "@react-router/dev/routes";

export default [
  layout("routes/public-layout.tsx", [
    index("routes/home.tsx"),
    // Add only the pages that were requested:
    route("impressum", "routes/impressum.tsx"),
    route("privacy-policy", "routes/privacy-policy.tsx"),
    route("terms", "routes/terms.tsx"),
  ]),
  // Preserve existing auth and app routes below
] satisfies RouteConfig;
```

If `adding-landing-page` was not run and no public layout exists yet, create `app/routes/public-layout.tsx` first using the pattern from [../adding-landing-page/references/01-routes-and-layout.md](../adding-landing-page/references/01-routes-and-layout.md).

### 3. Verify generated route types resolve

After updating `app/routes.ts`, run the typecheck command to confirm that `./+types/impressum`, `./+types/privacy-policy`, and `./+types/terms` are generated:

```sh
pnpm typecheck
```

A path mismatch in `app/routes.ts` is the most common cause of missing generated types.

## Expected Results

- Each requested page is accessible at its URL (`/impressum`, `/privacy-policy`, `/terms`) without authentication.
- All pages render inside the `_public` layout with `SiteHeader` and `SiteFooter`.
- Route modules import generated types from `./+types/<route-file>`.
- No existing routes are changed or removed.
