# Form Validation

## Contents

- Choose The Right Form Pattern
- Route Action Pattern
- Component Pattern (Conform + Zod)
- Search And Filter Forms
- Inline Mutations (useFetcher)
- Multiple Actions Per Route
- Uploads
- Validation Rules
- Redirect Rules
- Anti-Patterns
- Review Checklist

Use this guide when creating or reviewing React Router route modules that render forms, submit mutations, upload files, or validate user input.

## Choose The Right Form Pattern

| Use case | Pattern | Route behavior |
| --- | --- | --- |
| Search and filters | `<Form method="get">` | Loader reads `request.url` search params |
| Page-level create, edit, login, signup, logout | `<Form method="post">` | Action validates, mutates, then redirects |
| Delete confirmation | `useFetcher` inside shadcn `Dialog` | Fetcher submits delete; dialog closes and page revalidates |
| Inline toggles, row actions, autosave, ratings | `useFetcher` | Action validates and mutates without navigation |
| Multiple independent mutations on one page | `useFetcher` | Each fetcher tracks its own pending state |

Default to server route actions for mutations. Keep database writes, auth calls, storage operations, and secret-bearing logic out of client components.

## Route Action Pattern

Every mutating route action should follow the same sequence:

1. Read request-scoped dependencies from `context.get(appContext)`.
2. Authenticate the user when the route is protected.
3. Parse `await request.formData()`.
4. Validate the form data before mutating anything.
5. Check ownership or role permissions for resource-specific mutations.
6. Perform the mutation.
7. Redirect after success when the submission represents a completed page-level action.

Use structured validation errors for user-correctable input:

```tsx
import { parseWithZod } from "@conform-to/zod/v4";
import { data, redirect } from "react-router";
import { z } from "zod";
import { appContext } from "~/context";
import type { Route } from "./+types/projects-new";

const schema = z.object({
  title: z.string().min(1, "Title is required"),
});

export async function action({ context, request }: Route.ActionArgs) {
  const { db } = context.get(appContext);
  const formData = await request.formData();
  const submission = parseWithZod(formData, { schema });

  if (submission.status !== "success") {
    return data(submission.reply(), { status: 400 });
  }

  await createProject(db, submission.value);
  return redirect("/projects");
}
```

## Component Pattern

Use React Router `<Form>` for route-backed submissions. If Conform is used, pass the previous action result into `useForm` and render field-level errors from the returned field metadata.

```tsx
import { useForm } from "@conform-to/react";
import { parseWithZod } from "@conform-to/zod/v4";
import { Form } from "react-router";
import type { Route } from "./+types/projects-new";

export default function ProjectNew({ actionData }: Route.ComponentProps) {
  const [form, fields] = useForm({
    lastResult: actionData,
    shouldValidate: "onBlur",
    onValidate({ formData }) {
      return parseWithZod(formData, { schema });
    },
  });

  return (
    <Form method="post" id={form.id} onSubmit={form.onSubmit}>
      <input name={fields.title.name} />
      {fields.title.errors && <p>{fields.title.errors}</p>}
      <button type="submit">Create</button>
    </Form>
  );
}
```

## Search And Filter Forms

Search and filter forms should submit with GET. Do not intercept submit events just to call `setSearchParams`.

```tsx
import { Form } from "react-router";

export async function loader({ request }: Route.LoaderArgs) {
  const url = new URL(request.url);
  const query = url.searchParams.get("q") ?? "";
  return { results: await searchProjects(query) };
}

export default function SearchPage() {
  return (
    <Form method="get">
      <input name="q" />
      <button type="submit">Search</button>
    </Form>
  );
}
```

## Inline Mutations

Use `useFetcher` when a mutation should update part of the page without navigating. This is the right pattern for checkboxes, favorite buttons, row actions, autosave, and independent actions inside a list. This example also appears in `pending-ui.md` — keep both in sync.

```tsx
import { useFetcher } from "react-router";

function FavoriteButton({
  itemId,
  isFavorite,
}: {
  itemId: string;
  isFavorite: boolean;
}) {
  const fetcher = useFetcher();
  const optimistic = fetcher.formData
    ? fetcher.formData.get("favorite") === "true"
    : isFavorite;

  return (
    <fetcher.Form method="post" action={`/items/${itemId}/favorite`}>
      <button name="favorite" value={String(!optimistic)}>
        {optimistic ? "Favorited" : "Favorite"}
      </button>
    </fetcher.Form>
  );
}
```

Fetcher actions still need the same server-side validation and permission checks as normal route actions.

## Delete Confirmation Dialog

Use a shadcn `Dialog` with `useFetcher` for delete actions instead of a separate delete route or page. Install the component with `pnpm dlx shadcn@latest add dialog`. The dialog keeps the user on the current page while the fetcher handles the mutation and triggers revalidation.

```tsx
import { useEffect, useState } from "react";
import { useFetcher } from "react-router";
import { Button } from "~/components/ui/button";
import {
  Dialog,
  DialogContent,
  DialogDescription,
  DialogFooter,
  DialogHeader,
  DialogTitle,
  DialogTrigger,
} from "~/components/ui/dialog";

function DeleteProjectDialog({
  projectId,
  projectName,
}: {
  projectId: string;
  projectName: string;
}) {
  const [open, setOpen] = useState(false);
  const fetcher = useFetcher();

  useEffect(() => {
    if (fetcher.state === "idle" && fetcher.data) {
      setOpen(false);
    }
  }, [fetcher.state, fetcher.data]);

  return (
    <Dialog open={open} onOpenChange={setOpen}>
      <DialogTrigger asChild>
        <Button variant="destructive" size="sm">
          Delete
        </Button>
      </DialogTrigger>
      <DialogContent>
        <DialogHeader>
          <DialogTitle>Delete project</DialogTitle>
          <DialogDescription>
            This will permanently delete &ldquo;{projectName}&rdquo;. This
            action cannot be undone.
          </DialogDescription>
        </DialogHeader>
        <DialogFooter>
          <Button variant="outline" onClick={() => setOpen(false)}>
            Cancel
          </Button>
          <fetcher.Form method="post">
            <input type="hidden" name="intent" value="delete" />
            <input type="hidden" name="projectId" value={projectId} />
            <Button
              type="submit"
              variant="destructive"
              disabled={fetcher.state !== "idle"}
            >
              {fetcher.state !== "idle" ? "Deleting…" : "Delete"}
            </Button>
          </fetcher.Form>
        </DialogFooter>
      </DialogContent>
    </Dialog>
  );
}
```

The route action handles the delete intent alongside other mutations on the same route:

```tsx
export async function action({ context, request }: Route.ActionArgs) {
  const { projectDao } = context.get(appContext);
  const user = context.get(userContext);
  const formData = await request.formData();
  const intent = formData.get("intent");

  if (intent === "delete") {
    const projectId = String(formData.get("projectId"));
    const project = await projectDao.get(projectId);
    if (!project || project.userId !== user.id) {
      throw data("Not found", { status: 404 });
    }
    await projectDao.delete(projectId);
    return { ok: true };
  }

  return data({ error: "Invalid action" }, { status: 400 });
}
```

After the delete succeeds, React Router revalidates the page loader and the deleted item disappears from the list. The `useEffect` closes the dialog when the fetcher returns to idle with data.

## Multiple Actions Per Route

When a route supports multiple mutations, include an explicit intent field:

```tsx
const intent = formData.get("intent");

switch (intent) {
  case "archive":
    return archiveProject();
  case "restore":
    return restoreProject();
  default:
    return data({ error: "Invalid action" }, { status: 400 });
}
```

Prefer separate resource routes when independent mutations have different permissions, redirect behavior, or reuse needs.

## Uploads

Handle uploads in route actions. Validate file presence, content type, size, and ownership before writing to storage. Keep R2, database, and secret-bearing logic server-side.

```tsx
export async function action({ context, request }: Route.ActionArgs) {
  const formData = await request.formData();
  const file = formData.get("file");

  if (!(file instanceof File) || file.size === 0) {
    return data({ error: "Please select a file" }, { status: 400 });
  }

  if (file.size > 10 * 1024 * 1024) {
    return data({ error: "File must be under 10 MB" }, { status: 400 });
  }

  const { files } = context.get(appContext);
  const record = await files.upload(file);
  return redirect(`/files/${record.id}`);
}
```

Return structured 400 responses for user-correctable upload failures. Redirect after successful page-level uploads.

## Validation Rules

Treat all submitted form data as untrusted:

- Validate required strings, numbers, booleans, dates, enum values, and IDs.
- Coerce form values intentionally in the schema instead of scattered action code.
- Return `data(..., { status: 400 })` for validation failures the user can fix.
- Throw `data(..., { status: 404 })` or `Response` for not-found resources.
- Throw `redirect(...)` for auth and navigation control flow.
- Do not silently replace invalid values with defaults unless the UI makes that behavior explicit.

## Redirect Rules

Use redirects to complete page-level mutations:

- Create: redirect to the created resource or list page.
- Edit: redirect to the updated resource or back to the list.
- Delete (dialog on list page): no redirect; the fetcher revalidates the page and the item disappears. Return `{ ok: true }` from the action.
- Delete (detail page where the resource is gone): redirect to the parent list.
- Login/signup: redirect to a safe `redirectTo` target or dashboard.
- Logout: redirect to login or public home.

Redirecting after successful POST avoids duplicate submissions on refresh and keeps the browser URL aligned with the current page state.

## Anti-Patterns

- Do not mutate data in loaders.
- Do not use browser `fetch` for application mutations that should be route actions.
- Do not use raw `<form>` when React Router `<Form>` gives the intended behavior.
- Do not use manual `setSearchParams` submission handling for search forms.
- Do not use page-navigating `<Form method="post">` for tiny inline toggles when `useFetcher` fits better.
- Do not create separate routes or pages for delete confirmations. Use a shadcn `Dialog` with `useFetcher` on the list or detail page.
- Do not import database clients, auth secrets, or storage clients into client components.

## Review Checklist

- [ ] The route has a clear choice: GET form, POST form, or fetcher.
- [ ] Mutations are implemented in route actions or server-only services.
- [ ] The action validates `request.formData()` before mutating.
- [ ] Validation failures return a structured 400 response.
- [ ] Protected actions authenticate before reading or mutating private data.
- [ ] Resource mutations check ownership or permissions.
- [ ] Successful page-level mutations redirect.
- [ ] Inline mutations use `useFetcher` and can show pending or optimistic UI.
- [ ] Delete actions use a confirmation `Dialog` with `useFetcher`, not a separate route.
- [ ] Search and filter forms use `<Form method="get">`.
