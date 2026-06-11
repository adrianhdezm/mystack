# Loading Data

Use this guide when adding or reviewing route loaders, client loaders, route params, URL search params, redirects before render, streaming, or server data access.

## Server Loader Pattern

Use loaders for route data that must be available before render:

1. Read request-scoped dependencies from `context.get(appContext)`.
2. Authenticate first when the route is protected.
3. Validate params and search params.
4. Query server-side services, database clients, storage clients, or auth APIs.
5. Return plain serializable objects.
6. Throw `data(..., { status })` or `redirect(...)` for expected control flow.

```tsx
import { data, redirect } from "react-router";
import { appContext } from "~/context";
import type { Route } from "./+types/projects-detail";

export async function loader({ context, params, request }: Route.LoaderArgs) {
  const { auth, db } = context.get(appContext);
  const session = await auth.api.getSession({ headers: request.headers });

  if (!session) {
    const url = new URL(request.url);
    throw redirect(`/login?redirectTo=${encodeURIComponent(url.pathname)}`);
  }

  const projectId = params.projectId;
  if (!projectId) {
    throw data("Missing project id", { status: 400 });
  }

  const project = await getProjectForUser(db, projectId, session.user.id);
  if (!project) {
    throw data("Project not found", { status: 404 });
  }

  return { project };
}
```

Do not fetch Product Builder application data from the browser when the data can be loaded through a route loader.

## Reading Search Params

Use URL search params for filters, search, sort, pagination, and view state that belongs in the URL.

```tsx
export async function loader({ request }: Route.LoaderArgs) {
  const url = new URL(request.url);
  const query = url.searchParams.get("q") ?? "";
  const page = Number(url.searchParams.get("page") ?? "1");

  return {
    query,
    page,
    results: await searchProjects({ query, page }),
  };
}
```

Validate and coerce search params intentionally. Do not silently accept invalid numbers, booleans, enum values, or dates when they affect a query.

Use `<Form method="get">` for search and filters so the loader receives the submitted params.

## Route Params

Treat params as untrusted strings:

- Check required params before querying.
- Validate IDs with the same rules used by the database or service layer.
- Return or throw a clear 400 for malformed params.
- Throw 404 when the param is well-formed but the resource does not exist or is not visible to the user.

## Redirects And Responses

Use `redirect(...)` for navigation control flow before render:

```tsx
import { redirect } from "react-router";
import { appContext } from "~/context";

export async function loader({ context, request }: Route.LoaderArgs) {
  const { auth } = context.get(appContext);
  const session = await auth.api.getSession({ headers: request.headers });
  if (!session) {
    throw redirect("/login");
  }

  return { user: session.user };
}
```

Use `data(..., { status })` for expected route responses:

```tsx
import { data } from "react-router";

if (!project) {
  throw data("Project not found", { status: 404 });
}
```

Prefer route `ErrorBoundary` UI for expected 404/403 states that need a custom message.

## Client Loaders

Use `clientLoader` only for client-only needs such as browser APIs, local storage, client cache hydration, or data that intentionally must not participate in the server render.

```tsx
export async function clientLoader({ serverLoader }: Route.ClientLoaderArgs) {
  const serverData = await serverLoader();
  const localPreference = window.localStorage.getItem("view") ?? "grid";
  return { ...serverData, localPreference };
}
```

Do not move database reads or secret-bearing calls into `clientLoader`.

## Parallel Loading

React Router loads matched route loaders in parallel. Put shared data in the layout route only when children need the same data or the layout owns the decision, such as authentication for a protected shell.

Avoid duplicating the same expensive query across parent and child loaders.

## Streaming

Use streaming only when part of the page can render meaningfully before slower data is available.

Keep the critical path synchronous enough to render the route shell, permissions state, and not-found decisions. Do not stream data that is required to decide whether the user may see the page.

## Server Boundaries

- Keep database clients, storage clients, auth secrets, and service tokens server-side.
- Use `.server` modules for server-only helpers when needed.
- Pass only serializable loader data to route components.
- Keep browser-only APIs out of server loaders.

## Checklist

- [ ] Loader imports generated `Route.LoaderArgs`.
- [ ] Server dependencies come from `context.get(appContext)`.
- [ ] Auth runs before private data is queried.
- [ ] Params and search params are validated before use.
- [ ] Not-found and forbidden states use expected responses.
- [ ] Loader returns serializable data.
- [ ] Client loaders are used only for client-only concerns.
- [ ] No database, storage, auth secret, or server-only service is imported into client components.
