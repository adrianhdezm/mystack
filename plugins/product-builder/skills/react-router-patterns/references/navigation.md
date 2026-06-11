# Navigation

Use this guide when adding or reviewing links, nav bars, active navigation, redirects, search-param navigation, relative navigation, programmatic navigation, or scroll restoration.

## Choose The Right Navigation Pattern

| Use case                                        | Pattern               |
| ----------------------------------------------- | --------------------- |
| User clicks to another page                     | `Link`                |
| Navigation item needs active or pending styling | `NavLink`             |
| Loader/action decides the next page             | `redirect(...)`       |
| Search or filter changes URL params             | `<Form method="get">` |
| Client-only imperative transition               | `useNavigate()`       |
| Nested route navigation                         | Relative `to` values  |

Prefer declarative navigation with `Link`, `NavLink`, and route redirects. Reach for `useNavigate` only when navigation is a client-side effect of an interaction that cannot be modeled as a link or form.

## Links

Use `Link` for normal route navigation:

```tsx
import { Link } from "react-router";

<Link to="/projects/new">New project</Link>;
```

Use meaningful URLs that match the route map. Do not use buttons with click handlers for ordinary page navigation.

## Active Navigation

Use `NavLink` when the UI needs active or pending state:

```tsx
import { NavLink } from "react-router";

<NavLink
  to="/projects"
  className={({ isActive, isPending }) =>
    isActive ? "font-semibold" : isPending ? "opacity-70" : undefined
  }
>
  Projects
</NavLink>;
```

Keep active styling consistent across the app shell.

## Redirects

Use `redirect(...)` in loaders and actions for server-side navigation decisions:

```tsx
import { redirect } from "react-router";

export async function action({ request }: Route.ActionArgs) {
  await createProject(await request.formData());
  return redirect("/projects");
}
```

Common redirect cases:

- Anonymous user tries to access a protected route.
- Login/signup completes and returns to a safe target.
- Logout completes.
- Create/edit/delete completes.
- Deprecated or alias routes should canonicalize to the preferred path.

## Search Forms

Use `<Form method="get">` for search, filters, sorting, pagination controls, and other URL-owned state.

```tsx
import { Form } from "react-router";

<Form method="get">
  <input name="q" defaultValue={query} />
  <button type="submit">Search</button>
</Form>;
```

Do not intercept submit events only to call `setSearchParams`.

## Programmatic Navigation

Use `useNavigate` for client-only flows such as closing a modal route, returning after a browser-only interaction, or navigating after an effect that is not a route action.

```tsx
import { useNavigate } from "react-router";

function CloseButton() {
  const navigate = useNavigate();
  return <button onClick={() => navigate("..")}>Close</button>;
}
```

Avoid using `useNavigate` after a successful server mutation. Return `redirect(...)` from the action instead.

## Relative Navigation

Use relative paths in nested routes when the relationship is local and clear:

```tsx
<Link to="edit">Edit</Link>
<Link to="..">Back</Link>
```

Prefer absolute paths for global navigation, app shells, and links that should not depend on nesting.

## Type-Safe URLs

When the project has generated route helpers available, prefer them for paths with params. Otherwise centralize URL construction in small helpers for repeated resource paths.

```ts
function projectPath(projectId: string) {
  return `/projects/${projectId}`;
}
```

Do not scatter fragile string concatenation for the same route across many components.

## Scroll Restoration

Use React Router scroll restoration at the root when the app needs browser-like scroll behavior across route transitions.

Avoid manual scroll management unless there is a specific UI reason.

## Checklist

- [ ] Ordinary navigation uses `Link`.
- [ ] Active navigation uses `NavLink`.
- [ ] Server decisions use `redirect(...)`.
- [ ] Search/filter URL changes use `<Form method="get">`.
- [ ] Programmatic navigation is limited to client-only UI flows.
- [ ] Relative navigation is used only where route nesting is clear.
- [ ] URL construction for repeated dynamic routes is consistent.
