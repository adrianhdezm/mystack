# Protecting Routes

Use this guide when adding or reviewing authenticated pages, protected route groups, protected actions, login redirects, logout behavior, ownership checks, role checks, cookie sessions, or auth middleware.

## Product Builder Auth Preference

When Better Auth has been installed by `adding-authentication`, reuse the project's Better Auth helpers, session helpers, and safe redirect helpers. Do not introduce a parallel cookie session implementation unless the project explicitly does not use Better Auth.

## How Middleware Connects To Routes

Connect auth middleware by exporting `middleware` from a route module.

Middleware runs when that route is part of the matched route branch. If the middleware is exported from a layout route, it also applies to matched child routes.

Use this to create protected route groups:

```ts
import { layout, route, type RouteConfig } from "@react-router/dev/routes";

export default [
  route("login", "routes/login.tsx"),

  layout("routes/protected-layout.tsx", [
    route("dashboard", "routes/dashboard.tsx"),
    route("projects", "routes/projects.tsx"),
    route("projects/:projectId", "routes/projects-detail.tsx"),
  ]),
] satisfies RouteConfig;
```

Then export middleware from the layout route:

```tsx
import { Outlet, redirect } from "react-router";
import { appContext, userContext } from "~/context";
import type { Route } from "./+types/protected-layout";

async function requireUser({ context, request }: Route.MiddlewareArgs) {
  const { auth } = context.get(appContext);
  const session = await auth.api.getSession({ headers: request.headers });

  if (!session) {
    const url = new URL(request.url);
    throw redirect(`/login?redirectTo=${encodeURIComponent(url.pathname)}`);
  }

  context.set(userContext, session.user);
}

export const middleware: Route.MiddlewareFunction[] = [requireUser];

export default function ProtectedLayout() {
  return <Outlet />;
}
```

Now `/dashboard`, `/projects`, and `/projects/:projectId` are protected because they are children of `protected-layout.tsx`. `/login` is public because it is outside that layout branch.

## Default Pattern: Auth Middleware

Prefer auth middleware for protected route groups. Middleware should authenticate the request once, redirect anonymous users, and place the authenticated user or session in React Router context.

Do not repeat basic session checks in every protected loader or action when the route is already inside an auth middleware branch.

Include only safe local paths in `redirectTo`. Do not allow external redirects.

## Reading Auth Context In Loaders And Actions

Loaders and actions inside a protected branch should read the authenticated user from context:

```tsx
import { appContext, userContext } from "~/context";
import type { Route } from "./+types/projects";

export async function loader({ context }: Route.LoaderArgs) {
  const user = context.get(userContext);
  const { db } = context.get(appContext);

  return {
    projects: await listProjectsForUser(db, user.id),
  };
}
```

Actions should also read the authenticated user from context before mutating:

```tsx
import { parseWithZod } from "@conform-to/zod/v4";
import { data, redirect } from "react-router";
import { appContext, userContext } from "~/context";
import type { Route } from "./+types/projects-detail";

export async function action({ context, params, request }: Route.ActionArgs) {
  const user = context.get(userContext);
  const { db } = context.get(appContext);

  const project = await getProjectForUser(db, params.projectId, user.id);
  if (!project) {
    throw data("Project not found", { status: 404 });
  }

  const formData = await request.formData();
  const submission = parseWithZod(formData, { schema: updateProjectSchema });

  if (submission.status !== "success") {
    return data(submission.reply(), { status: 400 });
  }

  await updateProject(db, project.id, submission.value);
  return redirect(`/projects/${project.id}`);
}
```

Do not trust hidden form fields for user IDs, owner IDs, role names, or tenant IDs. Derive authorization from the authenticated session and server-side data.

## Route-Specific Authorization

Middleware answers: who is the user?

Routes and server services still answer: may this user access or mutate this specific resource?

Check permissions close to the data access or mutation:

- User-owned records: require `record.userId === user.id`.
- Team records: verify team membership before returning or mutating data.
- Admin records: verify admin role before loading admin data.
- Private files: check ownership before generating download URLs.
- Delete actions: check permission before deleting and before redirecting.

Use 404 when revealing the resource exists would leak private information. Use 403 when the user may know the resource exists but lacks permission.

Do not use middleware to hide route-specific ownership checks. Resource authorization belongs in the route or service that loads or mutates the resource.

## Login And Logout

Login routes should stay outside protected route groups.

Login actions should:

1. Validate credentials or delegate to Better Auth.
2. Reject invalid input with a structured 400 response.
3. Establish the session through the existing auth integration.
4. Redirect to a safe `redirectTo` target or the home page.

Sanitize redirect targets:

```ts
function safeRedirectTo(
  to: FormDataEntryValue | string | null | undefined,
  defaultRedirect = "/",
) {
  if (!to || typeof to !== "string") {
    return defaultRedirect;
  }

  if (!to.startsWith("/") || to.startsWith("//")) {
    return defaultRedirect;
  }

  return to;
}
```

Logout actions should clear or invalidate the session through the existing auth integration and redirect to login or public home.

Use POST for logout when it mutates session state.

## Cookie Sessions

Use React Router cookie/session storage only in projects that are not using Better Auth or where a small route-local session is explicitly needed.

Session cookies should be:

- `httpOnly: true`
- `secure: true` in production
- `sameSite: "lax"` unless the auth flow requires otherwise
- signed with a secret from environment bindings
- rotated carefully when secrets change

Flash session data is useful for one-time messages after redirects, but do not store sensitive data in flash messages.

## Fallback: Loader-Level Protection

Use loader-level auth only when middleware is not installed yet, the route is a one-off protected page, or the protection rule is intentionally route-local.

```tsx
import { redirect } from "react-router";
import { appContext } from "~/context";
import type { Route } from "./+types/dashboard";

export async function loader({ context, request }: Route.LoaderArgs) {
  const { auth } = context.get(appContext);
  const session = await auth.api.getSession({ headers: request.headers });

  if (!session) {
    const url = new URL(request.url);
    throw redirect(`/login?redirectTo=${encodeURIComponent(url.pathname)}`);
  }

  return { user: session.user };
}
```

Do not use loader-level protection repeatedly across a protected section when a layout route with auth middleware would express the route boundary more clearly.

## Checklist

- [ ] Protected route groups use auth middleware on a layout route.
- [ ] Public login routes are outside protected layout branches.
- [ ] Middleware redirects anonymous users and sets auth context.
- [ ] Protected loaders/actions read the authenticated user from context.
- [ ] `redirectTo` values are sanitized and local.
- [ ] Ownership, role, or team permissions are checked server-side.
- [ ] Hidden form fields are not trusted for authorization.
- [ ] 404 vs 403 is chosen intentionally.
- [ ] Better Auth projects reuse the installed Better Auth integration.
- [ ] Loader-level protection is used only for one-off or route-local cases.
