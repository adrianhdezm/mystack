# Errors And Boundaries

## Contents

- Error Boundary Pattern
- Expected Errors
- Validation Errors
- Not-Found Routes
- Unexpected Errors
- Error Boundaries And Layouts
- Checklist

Use this guide when adding or reviewing route `ErrorBoundary` exports, expected 404/403 responses, validation failure responses, not-found pages, unexpected error reporting, or route-level error UI.

## Error Boundary Pattern

Add an `ErrorBoundary` export when the route needs custom error UI:

```tsx
import { isRouteErrorResponse, useRouteError } from "react-router";

export function ErrorBoundary() {
  const error = useRouteError();

  if (isRouteErrorResponse(error)) {
    return (
      <main>
        <h1>{error.status}</h1>
        <p>{error.statusText}</p>
      </main>
    );
  }

  return (
    <main>
      <h1>Something went wrong</h1>
      <p>Please try again.</p>
    </main>
  );
}
```

Use parent layout boundaries for shared shells and child route boundaries for resource-specific errors.

## Expected Errors

Use expected route responses for states the app understands:

```tsx
import { data } from "react-router";

if (!project) {
  throw data("Project not found", { status: 404 });
}

if (!canEditProject) {
  throw data("Forbidden", { status: 403 });
}
```

Common expected states:

- 400: malformed params, invalid query values, or invalid form submissions.
- 401: unauthenticated API/resource endpoint response.
- 403: authenticated user lacks permission.
- 404: resource does not exist or should not be visible to the user.
- 409: conflict such as duplicate names or stale edits.

Use 404 instead of 403 when revealing that a private resource exists would leak information.

## Validation Errors

Return validation failures from actions with status 400 so the route component can render field errors:

```tsx
if (submission.status !== "success") {
  return data(submission.reply(), { status: 400 });
}
```

Do not throw an error boundary for normal user-correctable form validation.

## Not-Found Routes

Use a catch-all route for unknown paths:

```ts
route("*", "routes/not-found.tsx");
```

For missing resources inside valid routes, throw a 404 from the loader or action. This keeps the URL and route ownership clear.

## Unexpected Errors

Unexpected errors should reach an error boundary and be reported through the project's logging or monitoring mechanism when one exists.

Do not expose stack traces, secrets, SQL fragments, access tokens, or internal service details to users.

## Error Boundaries And Layouts

Place boundaries according to recovery scope:

- Root boundary: global fallback for unexpected app errors.
- Layout boundary: section-level failures, such as dashboard shell errors.
- Route boundary: resource-specific not-found or forbidden states.

Avoid adding identical boilerplate boundaries to every route. Use a shared component when routes need the same visual treatment.

## Checklist

- [ ] Expected 400/401/403/404/409 states use route responses.
- [ ] Form validation returns action data instead of throwing boundaries.
- [ ] Private missing resources use 404 when existence should not leak.
- [ ] Error boundaries are placed at the right recovery scope.
- [ ] Unexpected errors do not expose sensitive implementation details.
- [ ] Catch-all routes handle unknown paths.
