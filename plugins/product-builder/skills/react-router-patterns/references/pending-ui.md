# Pending And Optimistic UI

## Contents

- Choose The Right Pending Source
- useNavigation
- NavLink Pending State
- useFetcher For Local State
- Optimistic UI With fetcher.formData
- Page-Level Optimistic UI
- Skeletons And Empty States
- Disabling During Submission
- CSS Busy Indicators
- HydrateFallback
- Checklist

Use this guide when adding or reviewing route loading states, form submission states, optimistic UI, disabled controls, skeletons, pending navigation, or fetcher state.

## Choose The Right Pending Source

| UI need                                 | Pattern                    |
| --------------------------------------- | -------------------------- |
| Whole-page navigation pending state     | `useNavigation()`          |
| Active nav item pending state           | `NavLink` render props     |
| Inline mutation pending state           | `useFetcher()`             |
| Optimistic inline mutation              | `fetcher.formData`         |
| Page-level POST pending state           | `useNavigation().formData` |
| Initial route fallback during hydration | `HydrateFallback`          |

Keep pending UI close to the route or component that owns the interaction.

## useNavigation

Use `useNavigation` for global route transitions and page-level form submissions:

```tsx
import { useNavigation } from "react-router";

function SubmitButton() {
  const navigation = useNavigation();
  const isSubmitting = navigation.state === "submitting";

  return (
    <button type="submit" disabled={isSubmitting}>
      {isSubmitting ? "Saving..." : "Save"}
    </button>
  );
}
```

Navigation states:

- `idle`: no navigation is pending.
- `submitting`: a form submission is in progress.
- `loading`: loaders are running for the next page.

## NavLink Pending State

Use `NavLink` for navigation items that need active or pending styles:

```tsx
<NavLink
  to="/projects"
  className={({ isActive, isPending }) =>
    isActive ? "font-semibold" : isPending ? "opacity-70" : undefined
  }
>
  Projects
</NavLink>
```

## useFetcher For Local State

Use `useFetcher` for pending state that belongs to a specific button, row, toggle, autosave field, or card action.

```tsx
const fetcher = useFetcher();
const isBusy = fetcher.state !== "idle";

<fetcher.Form method="post" action={`/projects/${project.id}/archive`}>
  <button disabled={isBusy}>{isBusy ? "Archiving..." : "Archive"}</button>
</fetcher.Form>;
```

Fetcher states mirror navigation states: `idle`, `submitting`, and `loading`.

## Optimistic UI With fetcher.formData

Use `fetcher.formData` to render the submitted value before the action returns. This example also appears in `form-validation.md` — keep both in sync.

```tsx
function FavoriteButton({
  id,
  isFavorite,
}: {
  id: string;
  isFavorite: boolean;
}) {
  const fetcher = useFetcher();
  const optimistic = fetcher.formData
    ? fetcher.formData.get("favorite") === "true"
    : isFavorite;

  return (
    <fetcher.Form method="post" action={`/items/${id}/favorite`}>
      <button name="favorite" value={String(!optimistic)}>
        {optimistic ? "Favorited" : "Favorite"}
      </button>
    </fetcher.Form>
  );
}
```

Only use optimistic UI when the expected success path is clear and failures can be shown or recovered cleanly.

## Page-Level Optimistic UI

For full-page POSTs, `useNavigation().formData` can show pending submitted values. Prefer this for simple “creating...” or “saving...” states, not complex local cache behavior.

```tsx
const navigation = useNavigation();
const pendingTitle = navigation.formData?.get("title");
```

## Skeletons And Empty States

Use skeletons for route transitions where the page structure is stable and data is still loading. Use empty states when the loader completed successfully but returned no records.

Do not show a skeleton for validation errors, forbidden states, or not-found states. Those are completed route states, not loading states.

## Disabling During Submission

Disable controls that would create duplicate or conflicting submissions:

```tsx
const navigation = useNavigation();
const isSubmitting = navigation.state === "submitting";

<button type="submit" disabled={isSubmitting}>
  {isSubmitting ? "Saving..." : "Save"}
</button>;
```

Do not disable unrelated controls on the whole page when only one fetcher action is pending.

## CSS Busy Indicators

Use `aria-busy`, `aria-disabled`, and visible text changes where appropriate. Keep busy indicators accessible and avoid relying on color alone.

```tsx
<section aria-busy={navigation.state !== "idle"}>{children}</section>
```

## HydrateFallback

Export a `HydrateFallback` component from a route module to show a placeholder while the client bundle hydrates. This only renders on the initial page load when the route uses `clientLoader` without a server `loader`:

```tsx
export function HydrateFallback() {
  return <p>Loading...</p>;
}
```

Do not use `HydrateFallback` when the route has a server `loader` — the server already returns rendered HTML, so there is nothing to fall back to.

## Checklist

- [ ] Whole-page pending state uses `useNavigation`.
- [ ] Local mutation pending state uses `useFetcher`.
- [ ] Optimistic UI reads from `fetcher.formData` or `navigation.formData`.
- [ ] Duplicate submissions are prevented where they would cause problems.
- [ ] Pending state does not hide validation, forbidden, or not-found results.
- [ ] Busy indicators are accessible.
- [ ] Unrelated page controls are not disabled for local fetcher work.
