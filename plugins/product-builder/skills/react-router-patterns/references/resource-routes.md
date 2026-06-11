# Resource Routes And API Endpoints

## Contents

- When To Use A Resource Route
- Route Registration
- Loader Resource Responses
- Action Resource Responses
- Auth And Permissions
- Webhooks
- Response Data
- Checklist

Use this guide when adding or reviewing non-page responses, resource routes, upload/download endpoints, webhooks, auth endpoints, or JSON-style endpoints.

## When To Use A Resource Route

Use a resource route when the URL should return data or perform a mutation without rendering a page component.

Good uses:

- Better Auth endpoints at `api/auth/*`.
- File upload or download endpoints.
- Webhook receivers.
- Export endpoints such as CSV or JSON downloads.
- Fetcher-only row actions reused across pages.
- Small JSON endpoints for app-owned data when a page loader is not the right owner.

Do not use resource routes to bypass route loaders/actions for normal page data or form submissions.

## Route Registration

Register resource routes in `app/routes.ts` with clear resource paths:

```ts
route("api/auth/*", "routes/auth.tsx");
route("projects/:projectId/archive", "routes/projects-archive.tsx");
route("files/:fileId/download", "routes/files-download.tsx");
```

Prefer resource-oriented paths. Avoid vague endpoints like `/api/submit`, `/api/data`, or `/action`.

## Loader Resource Responses

Use loaders for read-only resource responses:

```tsx
import { data } from "react-router";
import { appContext } from "~/context";

export async function loader({ context, params, request }: Route.LoaderArgs) {
  const { db } = context.get(appContext);
  const file = await getVisibleFile(db, params.fileId, request);

  if (!file) {
    throw data("Not found", { status: 404 });
  }

  return new Response(file.body, {
    headers: {
      "content-type": file.contentType,
      "content-disposition": `attachment; filename="${file.name}"`,
    },
  });
}
```

## Action Resource Responses

Use actions for mutations:

```tsx
import { data } from "react-router";
import { appContext } from "~/context";

export async function action({ context, params, request }: Route.ActionArgs) {
  const { db, auth } = context.get(appContext);
  const session = await auth.api.getSession({ headers: request.headers });
  if (!session) {
    throw data("Unauthorized", { status: 401 });
  }

  const project = await getProjectForUser(
    db,
    params.projectId,
    session.user.id,
  );
  if (!project) {
    throw data("Not found", { status: 404 });
  }

  await archiveProject(db, project.id);
  return data({ ok: true });
}
```

Fetcher forms can submit to resource actions when the mutation should not navigate.

## Auth And Permissions

Resource routes must apply the same auth and authorization rules as page routes:

- Authenticate before private reads or writes.
- Validate params and request bodies.
- Check ownership, team membership, or role permissions.
- Use 404 when existence should not leak.
- Avoid trusting client-provided owner IDs or role fields.

## Webhooks

Webhook routes should validate signatures before parsing or trusting payloads. Return minimal responses and avoid leaking internal errors to the sender.

Keep webhook secrets server-side and read them from environment bindings or server context.

## Response Data

Return only the data the caller needs. Avoid returning full database rows, secret fields, internal IDs that are not part of the app contract, or authorization metadata.

Set content type and cache headers intentionally for file, JSON, and export responses.

## Checklist

- [ ] The endpoint has a clear resource-oriented path.
- [ ] The route is registered in `app/routes.ts`.
- [ ] Loader endpoints are read-only.
- [ ] Action endpoints mutate only after validation and authorization.
- [ ] Private endpoints authenticate before data access.
- [ ] Responses include only necessary data.
- [ ] File/export endpoints set appropriate headers.
- [ ] Webhooks validate signatures before trusting payloads.
