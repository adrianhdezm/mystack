# Adding Routes

Use this guide when creating or reviewing React Router route maps, page routes, layout routes, nested routes, dynamic routes, index routes, catch-all routes, or route modules.

## Route Planning

Before implementation, turn the approved product design into a route map:

- Public pages, protected pages, account/auth pages, and resource/API routes.
- Each route path, route file, and whether it has a `loader`, `action`, or both.
- The data each loader returns and the mutation each action performs.
- Redirect behavior after login, logout, create, update, and delete actions.
- Permission checks for user-owned, admin, team, or private records.

Prefer resource-oriented paths:

```text
/dashboard
/projects
/projects/new
/projects/:projectId
/projects/:projectId/edit
/api/auth/*
```

Avoid ambiguous paths such as `/view`, `/details`, `/item`, or `/submit` unless they are nested under a clear resource path.

## Route Configuration

Keep all route registration in `app/routes.ts`.

```ts
import { index, route, type RouteConfig } from "@react-router/dev/routes";

export default [
  index("routes/home.tsx"),
  route("login", "routes/login.tsx"),
  route("logout", "routes/logout.tsx"),
  route("dashboard", "routes/dashboard.tsx"),
  route("projects", "routes/projects.tsx"),
  route("projects/new", "routes/projects-new.tsx"),
  route("projects/:projectId", "routes/projects-detail.tsx"),
  route("projects/:projectId/edit", "routes/projects-edit.tsx"),
  route("api/auth/*", "routes/auth.tsx"),
] satisfies RouteConfig;
```

When adding routes:

- Merge entries into the existing route array; preserve unrelated routes.
- Keep route files named for their path or role, such as `projects-detail.tsx`, `projects-new.tsx`, or `dashboard.tsx`.
- Use dynamic params with meaningful names like `:projectId`, `:teamId`, or `:fileId`.
- Keep Better Auth endpoints at `api/auth/*`.
- Do not create ad-hoc client-side routers or route tables outside `app/routes.ts`.

## Route Helpers

Use React Router route helpers from `@react-router/dev/routes`:

- `index("routes/home.tsx")` for an index route.
- `route("projects", "routes/projects.tsx")` for a named path.
- `layout("routes/app-layout.tsx", [...])` for shared layout UI with an `Outlet`.
- `prefix("projects", [...])` to group paths without adding layout UI.

Prefer layout routes when a group of pages shares navigation, shell UI, data, or error boundaries.

## Nested Routes And Layouts

Use nested routes for sections such as dashboards, account pages, projects, or admin areas.

```ts
import {
  index,
  layout,
  route,
  type RouteConfig,
} from "@react-router/dev/routes";

export default [
  layout("routes/dashboard-layout.tsx", [
    route("dashboard", "routes/dashboard.tsx"),
    route("projects", "routes/projects.tsx"),
    route("projects/:projectId", "routes/projects-detail.tsx"),
  ]),
] satisfies RouteConfig;
```

The layout route should render an `Outlet`:

```tsx
import { Outlet } from "react-router";

export default function DashboardLayout() {
  return (
    <div>
      <DashboardNav />
      <Outlet />
    </div>
  );
}
```

Avoid flattening every route into independent pages when those pages share the same shell, auth behavior, or error handling.

## Dynamic, Optional, And Splat Segments

Use dynamic params for resource IDs:

```ts
route("projects/:projectId", "routes/projects-detail.tsx");
route("teams/:teamId/members/:memberId", "routes/team-member.tsx");
```

Validate params in loaders and actions before using them. Do not assume route params are valid database IDs.

Use optional segments only when both URL shapes genuinely map to the same screen. Prefer explicit routes when the behavior differs.

Use splats for catch-all behavior:

```ts
route("files/*", "routes/files.tsx");
route("*", "routes/not-found.tsx");
```

Place catch-all routes after more specific routes.

## Route Module Shape

Each route module should export only the React Router functions it needs:

- `meta` for page title and metadata.
- `loader` for server-side reads, auth checks, and page data.
- `action` for form submissions and mutations.
- `default` for the page component.
- `ErrorBoundary` when the route needs specific error UI.
- `headers`, `links`, `handle`, or `shouldRevalidate` only when the route actually needs them.

Use generated route types:

```tsx
import { data } from "react-router";
import { appContext, userContext } from "~/context";
import type { Route } from "./+types/projects-detail";

export async function loader({ context, params }: Route.LoaderArgs) {
  const { projectDao } = context.get(appContext);
  const user = context.get(userContext);

  const project = await projectDao.get(params.projectId);
  if (!project || project.userId !== user.id) {
    throw data("Project not found", { status: 404 });
  }

  return { project };
}

export default function ProjectDetail({ loaderData }: Route.ComponentProps) {
  return <h1>{loaderData.project.name}</h1>;
}
```

Do not type loaders, actions, params, or component props manually when the generated `Route` type is available.

## Route Exports

Use these exports intentionally:

- `default`: route component.
- `loader`: server loader for route data.
- `clientLoader`: browser loader for client-only data or cache hydration.
- `action`: server action for mutations.
- `clientAction`: browser action only for client-only mutations.
- `ErrorBoundary`: route-level error UI.
- `HydrateFallback`: fallback during hydration when needed.
- `headers`: HTTP headers for the route response.
- `links`: route-specific stylesheets or preloads.
- `meta`: page metadata.
- `handle`: static route metadata for app conventions.
- `shouldRevalidate`: opt out of default revalidation only with a concrete reason.

Do not export placeholder functions.

## Checklist

- [ ] The route map preserves existing routes.
- [ ] The path is resource-oriented and unambiguous.
- [ ] The route file name matches the path or route role.
- [ ] Dynamic params have meaningful names.
- [ ] The route has a clear `loader` and `action` decision.
- [ ] The route module imports generated types from `./+types/<route-file>`.
- [ ] Shared shells use layout routes and `Outlet`.
- [ ] Catch-all routes are placed after specific routes.
- [ ] No client-side route table bypasses `app/routes.ts`.
