# Worker Architecture

## Single-file workers

Each Cloudflare Worker is a single file in `workers/`. The file contains all worker-specific setup: bindings, auth initialization, context creation, and request handling.

Do not extract handlers, utilities, or intermediate interfaces into separate files within `workers/`. Shared application code (context types, schema, services) belongs in `app/`.

```text
workers/
└── app.ts          # Single file: bindings, auth, context, handler

app/
├── context.ts      # Shared context types (used by workers AND routes)
├── db/             # Schema, DAOs
├── services/       # Business logic
└── routes/         # React Router route modules
```

## Worker entry pattern

Every worker follows this structure inside its `fetch` handler:

1. Initialize bindings (Drizzle, R2 services, etc.)
2. Initialize auth (if applicable)
3. Create a `RouterContextProvider`, set `appContext`, and call `requestHandler`

All three steps are inline in the `fetch` handler — no delegation to helper functions or separate files.

```ts
import { createRequestHandler, RouterContextProvider } from "react-router";
import { appContext } from "~/context";

const requestHandler = createRequestHandler(
  () => import("virtual:react-router/server-build"),
  import.meta.env.MODE,
);

export default {
  async fetch(request, env, ctx) {
    // 1. Initialize bindings
    // 2. Initialize auth (if applicable)
    // 3. Build context and handle request
    const routerContext = new RouterContextProvider();
    routerContext.set(appContext, {
      cloudflare: { env, ctx },
      // db, auth, files, etc.
    });
    return requestHandler(request, routerContext);
  },
} satisfies ExportedHandler<Env>;
```

## Anti-pattern: extracted request handler

Do not create a `workers/request-handler.ts` or similar file that wraps `RouterContextProvider` setup. This adds an intermediate interface and an extra file for logic with a single call site. The context types are already defined in `app/context.ts`.

## When skills add capabilities

When a skill wires a new binding (D1, R2, auth) into the worker, it modifies the existing `workers/app.ts` — it does not create new files in `workers/`.
