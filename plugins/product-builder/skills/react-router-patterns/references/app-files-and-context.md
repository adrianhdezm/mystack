# App-Level Files And Context

Use this guide when editing `app/root.tsx`, `app/routes.ts`, `react-router.config.ts`, `app/entry.server.tsx`, `app/entry.client.tsx`, middleware, `appContext`, `.server` modules, `.client` modules, global styles, or SSR/prerender behavior.

## App-Level Edit Rule

App-level files have broad impact. Before changing them, identify which route or feature requires the change and keep the edit scoped to that need.

Do not change root, config, entry files, or context setup as part of ordinary page work unless the route cannot be implemented correctly without it.

## app/routes.ts

`app/routes.ts` is the only route registry.

```ts
import { index, route, type RouteConfig } from "@react-router/dev/routes";

export default [
  index("routes/home.tsx"),
  route("dashboard", "routes/dashboard.tsx"),
] satisfies RouteConfig;
```

When editing:

- Preserve existing routes.
- Keep paths relative to the app root.
- Use route files under `app/routes/`.
- Keep Better Auth endpoints at `api/auth/*`.
- Place catch-all routes after specific routes.
- Avoid duplicate path definitions.

## app/root.tsx

Use `root.tsx` for app-wide document structure and shared React Router components:

- `Links`
- `Meta`
- `Outlet`
- `Scripts`
- `ScrollRestoration`
- global stylesheets and fonts
- root-level layout
- root-level error boundary

Keep route-specific data loading and UI out of `root.tsx`.

```tsx
import { Links, Meta, Outlet, Scripts, ScrollRestoration } from "react-router";

export default function App() {
  return <Outlet />;
}

export function Layout({ children }: { children: React.ReactNode }) {
  return (
    <html lang="en">
      <head>
        <meta charSet="utf-8" />
        <meta name="viewport" content="width=device-width, initial-scale=1" />
        <Meta />
        <Links />
      </head>
      <body>
        {children}
        <ScrollRestoration />
        <Scripts />
      </body>
    </html>
  );
}
```

## react-router.config.ts

Change React Router config only for app-wide behavior such as SSR, prerendering, or framework options.

Do not disable SSR or switch app modes to solve a route-local bug.

## Entry Files

Edit `app/entry.client.tsx` or `app/entry.server.tsx` only when changing hydration, server rendering, streaming response behavior, or provider setup that must wrap the entire app.

Do not put route-specific logic in entry files.

## Server Context

Product Builder projects should read request-scoped dependencies from `context.get(appContext)` in loaders and actions.

```tsx
export async function loader({ context }: Route.LoaderArgs) {
  const { db, auth } = context.get(appContext);
  return { userCount: await countUsers(db, auth) };
}
```

The Worker should pass context with `RouterContextProvider`. Do not use `AppLoadContext`, plain object context, or `context.cloudflare`.

When the project has authentication, define a `userContext` key in `app/context.ts` for the authenticated user set by middleware:

```ts
import { createContext } from "react-router";

export const userContext = createContext<{
  id: string;
  name: string;
  email: string;
} | null>(null);
```

Auth middleware sets it with `context.set(userContext, session.user)` and downstream loaders read it with `context.get(userContext)`.

## Middleware

Use middleware for shared request behavior:

- authentication setup used by many routes
- request logging
- response headers
- shared context values
- catch-all behavior that truly applies across a route branch

```ts
import { createContext } from "react-router";
import type { Route } from "./+types/protected-layout";

export const requestIdContext = createContext<string | null>(null);

async function requestIdMiddleware(
  { context }: Route.MiddlewareArgs,
  next: Route.MiddlewareFunction,
) {
  context.set(requestIdContext, crypto.randomUUID());
  return next();
}

export const middleware: Route.MiddlewareFunction[] = [requestIdMiddleware];
```

Keep route-specific ownership checks in loaders/actions or server services.

## .server And .client Modules

Use `.server` modules for code that must never enter the browser bundle:

- database clients
- storage clients
- auth secrets
- service tokens
- server-only SDKs

Use `.client` modules for browser-only APIs:

- `window`
- `document`
- local storage
- browser-only SDKs

Do not import `.server` modules into client components.

## Stylesheets And Fonts

Put global styles and font setup at the root. Put route-specific styles close to the route or component that owns them.

Avoid adding global CSS for one route-specific exception when a local class or component change is enough.

## Checklist

- [ ] App-level edits are required by the feature being built.
- [ ] `app/routes.ts` remains the only route registry.
- [ ] Existing routes are preserved.
- [ ] Root layout contains document structure, not route-specific behavior.
- [ ] Config changes are app-wide and intentional.
- [ ] Entry file changes are limited to rendering or provider setup.
- [ ] Loaders/actions read dependencies from `context.get(appContext)`.
- [ ] Middleware handles shared request behavior only.
- [ ] Server-only and client-only modules stay on the correct side of the boundary.
