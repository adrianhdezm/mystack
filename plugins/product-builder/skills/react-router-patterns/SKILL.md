---
name: react-router-patterns
description: Defines Product Builder React Router v7 route design and implementation patterns. Use when planning or creating routes, pages, layouts, loaders, actions, redirects, resource routes, protected routes, navigation, pending UI, route errors, or app-level React Router files.
---

# React Router Patterns

Load the reference that matches the work being done. Each reference is self-contained — avoid loading unrelated references.

## Stack Assumptions

- React Router runs in framework mode with SSR enabled.
- Routes are declared in `app/routes.ts` using helpers from `@react-router/dev/routes`.
- Route modules live under `app/routes/`.
- Route types are imported from the generated `./+types/<route-file>` module.
- Request-scoped server dependencies come from `context.get(appContext)`.
- The Worker passes context with `RouterContextProvider` — do not use `AppLoadContext`, plain object context, or `context.cloudflare`.
- Projects using Better Auth should prefer the integration installed by `adding-authentication`.

## Rules

- A `.server` module imported from a client component compiles without error in dev but crashes the production build — a "server-only module" error with a cryptic trace. Keep server imports out of components.
- `context.get(appContext)` only works inside loaders, actions, and middleware — calling it at module scope or inside a React component throws.
- `redirect()` in an action returns a `Response` — `return redirect("/path")`, do not throw it.
- Route type generation (`./+types/<route-file>`) requires the route to be registered in `app/routes.ts` — an unregistered route file causes a "module not found" error on the type import.
- Resource routes that return non-HTML responses must set `Content-Type` explicitly — React Router does not infer MIME type from the body.

## References

Load the reference that matches the work being done:

- **New routes, layouts, nesting, indexes, dynamic segments, splats**: [references/adding-routes.md](references/adding-routes.md)
- **Loaders, route params, search params, client loaders, streaming, redirects**: [references/loading-data.md](references/loading-data.md)
- **Forms, actions, Conform/Zod validation, file upload, inline mutations**: [references/form-validation.md](references/form-validation.md)
- **Links, nav bars, active states, programmatic navigation, scroll restoration**: [references/navigation.md](references/navigation.md)
- **Protected pages, login redirects, session access, ownership checks, roles**: [references/protecting-routes.md](references/protecting-routes.md)
- **Loading states, submit pending, optimistic UI, skeletons, fetcher state**: [references/pending-ui.md](references/pending-ui.md)
- **ErrorBoundary, expected 404/403, not-found pages, validation failure responses**: [references/errors-and-boundaries.md](references/errors-and-boundaries.md)
- **Resource routes, upload/download endpoints, webhooks, JSON endpoints**: [references/resource-routes.md](references/resource-routes.md)
- **`app/root.tsx`, `app/routes.ts`, middleware, `appContext`, SSR/prerender**: [references/app-files-and-context.md](references/app-files-and-context.md)

## Review Checklist

- [ ] `app/routes.ts` is the only route registry and existing routes are preserved.
- [ ] Every new route has a clear path, route file, and loader/action decision.
- [ ] Route modules import generated types from `./+types/<route-file>`.
- [ ] Loaders and actions use `context.get(appContext)` for server dependencies.
- [ ] Protected loaders and actions authenticate before any private data access.
- [ ] Resource mutations check ownership or role permissions.
- [ ] Actions validate form data before mutating and redirect after successful page-level POSTs.
- [ ] Search and filter forms use `<Form method="get">`.
- [ ] Inline non-navigating mutations use `useFetcher`.
- [ ] No server-only services, secrets, or storage clients imported into client components.
