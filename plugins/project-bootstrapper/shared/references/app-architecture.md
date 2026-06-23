# App Architecture

## `workers/app.ts` — the Hono application

Both deployment targets use the same structural pattern for `workers/app.ts`:

- A single `Hono` app instance
- One `app.all('*', ...)` handler that builds a `RouterContextProvider` per request and calls `requestHandler`
- `export default app` — no `serve()` call, no lifecycle management

The server lifecycle (dev server, production listener, static asset serving) is handled externally:
- **Cloudflare**: the Worker runtime drives `app.fetch`
- **Docker/Postgres**: `server.ts` at the project root drives dev (Vite middleware mode) and production (`@hono/node-server`)

```text
workers/
└── app.ts       ← Hono app, RouterContextProvider, export default app

app/
├── context.ts   ← Shared appContext type (used by workers AND routes)
├── db/          ← Schema, DAOs
├── services/    ← Business logic
└── routes/      ← React Router route modules

server.ts        ← Docker/Postgres only: dev/prod entry point
```

## Entry pattern

Every `workers/app.ts` follows this structure:

1. Construct shared dependencies at module scope when the runtime allows it (Docker/Postgres)
2. Inside `app.all('*', ...)`: initialize per-request dependencies, build `RouterContextProvider`, call `requestHandler`

```ts
import { Hono } from 'hono';
import { createRequestHandler, RouterContextProvider } from 'react-router';
import { appContext } from '~/context';

const app = new Hono(); // <{ Bindings: Env }> for Cloudflare

const requestHandler = createRequestHandler(
  () => import('virtual:react-router/server-build'),
  import.meta.env.MODE,
);

app.all('*', async (c) => {
  // Initialize per-request or per-runtime dependencies
  const routerContext = new RouterContextProvider();
  routerContext.set(appContext, {
    // db, auth, files, ai, etc.
  });
  return requestHandler(c.req.raw, routerContext);
});

export default app;
```

## Target differences inside the handler

| Concern | Cloudflare | Docker/Postgres |
|---|---|---|
| Hono type | `new Hono<{ Bindings: Env }>()` | `new Hono()` |
| Env/config | `c.env.*` | `process.env.*` |
| DB client | Per-request: `drizzle(c.env.APP_DB, { schema })` | Module scope: `new Pool(...)` + `drizzle(pool, { schema })` |
| Auth | Per-request: `betterAuth(...)` (env only in fetch) | Module scope: `betterAuth(...)` (stable process) |
| Export | `export default app` | `export default app` |

## When skills add capabilities

When a skill wires a new capability (database, auth, file storage, AI), it modifies the existing `workers/app.ts` — it does not create new files in `workers/`. Shared code (context types, schemas, services) always lives in `app/`, never in `workers/`.

## Anti-pattern: extracted helpers

Do not create a `workers/request-handler.ts` or similar helper file. The context types are in `app/context.ts`; the handler has exactly one call site. Extraction adds indirection without benefit.
