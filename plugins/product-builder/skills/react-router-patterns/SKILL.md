---
name: react-router-patterns
description: Defines Product Builder React Router v7 route design and implementation patterns. Use when planning or creating routes, pages, layouts, loaders, actions, redirects, resource routes, protected routes, navigation, pending UI, route errors, or app-level React Router files.
---

# React Router Patterns

Load the reference that matches the work being done. Each reference is self-contained, so avoid loading unrelated references unless the route touches multiple concerns.

## Stack Assumptions

- React Router runs in framework mode with SSR enabled.
- Routes are declared in `app/routes.ts` using helpers from `@react-router/dev/routes`.
- Route modules live under `app/routes/`.
- Route types are imported from the generated `./+types/<route-file>` module.
- Request-scoped server dependencies come from `context.get(appContext)`.
- The Worker passes context with `RouterContextProvider`; do not use `AppLoadContext`, plain object context, or `context.cloudflare`.
- Product Builder projects using Better Auth should prefer the Better Auth integration installed by `adding-authentication`.

## Gotchas

- Importing a `.server` module from a client component compiles without error in dev but crashes the production build. If a loader or service import leaks into a component, the build fails with a cryptic "server-only module" error.
- `context.get(appContext)` only works inside loaders, actions, and middleware. Calling it at module scope or inside a React component throws because there is no active request context.
- React Router's `redirect()` in an action returns a `Response`, not a thrown redirect. Return it (`return redirect("/path")`), do not throw it.
- Route type generation (`./+types/<route-file>`) depends on the route being registered in `app/routes.ts`. Adding a route file without updating `app/routes.ts` causes "module not found" errors on the type import.

## When Adding New Routes

Use this when creating pages, layout routes, nested routes, index routes, dynamic routes, splats, or new route modules.

Read [adding-routes.md](references/adding-routes.md).

## When Loading Data

Use this when adding loaders, reading route params or search params, returning route data, redirecting before render, using client loaders, streaming data, or keeping server data access out of client components.

Read [loading-data.md](references/loading-data.md).

## When Adding Forms Or Validating Input

Use this when creating or reviewing search forms, create/edit/delete forms, login/signup/logout forms, uploads, inline mutations, route actions, Conform/Zod validation, or validation error UI.

Read [form-validation.md](references/form-validation.md).

## When Creating Navigation

Use this when adding links, nav bars, active navigation, redirects, relative navigation, programmatic navigation, search-param navigation, or scroll restoration.

Read [navigation.md](references/navigation.md).

## When Protecting Routes

Use this when adding authenticated pages, login redirects, logout behavior, ownership checks, role checks, session access, cookie-backed sessions, or auth middleware.

Read [protecting-routes.md](references/protecting-routes.md).

## When Adding Pending Or Optimistic UI

Use this when adding loading states, submit pending states, optimistic fetcher UI, disabled buttons, skeletons, pending nav indicators, or local fetcher state.

Read [pending-ui.md](references/pending-ui.md).

## When Handling Route Errors

Use this when adding `ErrorBoundary` exports, expected 404/403 responses, validation failure responses, not-found pages, or route-level error reporting.

Read [errors-and-boundaries.md](references/errors-and-boundaries.md).

## When Building Resource Routes Or API Endpoints

Use this when adding non-page responses, resource routes, upload/download endpoints, webhooks, auth endpoints, or JSON-style endpoints under clear resource paths.

Read [resource-routes.md](references/resource-routes.md).

## When Editing App-Level Files Or Context

Use this when changing `app/root.tsx`, `app/routes.ts`, `react-router.config.ts`, entry files, middleware, `appContext`, `.server` modules, `.client` modules, global styles, or SSR/prerender behavior.

Read [app-files-and-context.md](references/app-files-and-context.md).

## Universal Checklist

- [ ] `app/routes.ts` is the only route registry and existing routes are preserved.
- [ ] Every new route has a clear path, route file, and loader/action decision.
- [ ] Route modules import generated types from `./+types/<route-file>`.
- [ ] Loaders and actions use `context.get(appContext)` for server dependencies.
- [ ] Protected loaders and actions authenticate before private data access.
- [ ] Resource mutations check ownership or role permissions.
- [ ] Actions validate form data before mutating and redirect after successful page-level POSTs.
- [ ] Search and filter forms use `<Form method="get">`.
- [ ] Inline non-navigating mutations use `useFetcher`.
- [ ] No server-only services, secrets, database clients, or storage clients are imported into client components.
