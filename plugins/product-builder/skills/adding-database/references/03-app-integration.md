# 03 - App Integration

Before changing React Router context or Worker request handling, load
`react-router-patterns` and follow its app-level file and
context patterns.

## Steps

1. Create `app/db/schema.ts`.

Start with an empty schema object unless the user has provided a data model.
Do not invent example tables.

```ts
export const schema = {};
```

2. Update `app/context.ts`.

Preserve existing context fields and add `db`. Keep Cloudflare spelled correctly
unless an existing public API already uses a misspelled key.

```ts
import { createContext } from "react-router";
import type { DrizzleD1Database } from "drizzle-orm/d1";
import { schema } from "~/db/schema";

export const appContext = createContext<{
  cloudflare: {
    env: Env;
    ctx: ExecutionContext;
  };
  db: DrizzleD1Database<typeof schema>;
}>();
```

3. Update `workers/app.ts`.

Preserve the existing `createRequestHandler` setup and pass a
`RouterContextProvider` containing the D1-backed Drizzle database.

```ts
import { createRequestHandler, RouterContextProvider } from "react-router";
import { drizzle } from "drizzle-orm/d1";
import { appContext } from "~/context";
import { schema } from "~/db/schema";

const requestHandler = createRequestHandler(
  () => import("virtual:react-router/server-build"),
  import.meta.env.MODE,
);

export default {
  async fetch(request, env, ctx) {
    const db = drizzle(env.APP_DB, { schema });
    const routerContext = new RouterContextProvider();

    routerContext.set(appContext, {
      cloudflare: { env, ctx },
      db,
    });

    return requestHandler(request, routerContext);
  },
} satisfies ExportedHandler<Env>;
```

## Expected Results

- `app/db/schema.ts` exports an empty `schema` object unless the user provided
  a data model.
- The app context exposes a typed Drizzle database.
- The Worker creates a Drizzle D1 client from `env.APP_DB` per request and
  passes it to React Router context.
