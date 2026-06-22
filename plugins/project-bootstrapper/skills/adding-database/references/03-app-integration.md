# 03 - App Integration

Before changing React Router context or server request handling, load `react-router-patterns` and follow its app-level file and context patterns.

## Steps

1. Create `app/db/schema.ts`.

Start with an empty schema object unless the user has provided a data model. Do not invent example tables.

```ts
export const schema = {};
```

2. Update `app/context.ts`. Preserve existing context fields and add `db`. The type differs by deployment target:

**Cloudflare target:**

```ts
import { createContext } from 'react-router';
import type { DrizzleD1Database } from 'drizzle-orm/d1';
import { schema } from '~/db/schema';

export const appContext = createContext<{
  cloudflare: {
    env: Env;
    ctx: ExecutionContext;
  };
  db: DrizzleD1Database<typeof schema>;
}>();
```

**Docker/Postgres target:**

```ts
import { createContext } from 'react-router';
import type { NodePgDatabase } from 'drizzle-orm/node-postgres';
import { schema } from '~/db/schema';

export const appContext = createContext<{
  env: {
    APP_NAME: string;
  };
  db: NodePgDatabase<typeof schema>;
}>();
```

3. Update the server entry to wire the database into request context. The entry file differs by deployment target:

**Cloudflare target** — update `workers/app.ts`:

```ts
import { createRequestHandler, RouterContextProvider } from 'react-router';
import { drizzle } from 'drizzle-orm/d1';
import { appContext } from '~/context';
import { schema } from '~/db/schema';

const requestHandler = createRequestHandler(
  () => import('virtual:react-router/server-build'),
  import.meta.env.MODE,
);

export default {
  async fetch(request, env, ctx) {
    const db = drizzle(env.APP_DB, { schema });
    const routerContext = new RouterContextProvider();
    routerContext.set(appContext, { cloudflare: { env, ctx }, db });
    return requestHandler(request, routerContext);
  },
} satisfies ExportedHandler<Env>;
```

**Docker/Postgres target** — update `server/app.ts`:

```ts
import { Hono } from 'hono';
import { serve } from '@hono/node-server';
import { createRequestHandler, RouterContextProvider } from 'react-router';
import { drizzle } from 'drizzle-orm/node-postgres';
import { Pool } from 'pg';
import { appContext } from '../app/context';
import { schema } from '../app/db/schema';

const pool = new Pool({ connectionString: process.env.DATABASE_URL });
const db = drizzle(pool, { schema });

const app = new Hono();
const requestHandler = createRequestHandler(
  () => import('virtual:react-router/server-build'),
  import.meta.env.MODE,
);

app.all('*', async (c) => {
  const routerContext = new RouterContextProvider();
  routerContext.set(appContext, {
    env: { APP_NAME: process.env.APP_NAME ?? '' },
    db,
  });
  return requestHandler(c.req.raw, routerContext);
});

const port = Number(process.env.PORT) || 3000;
serve({ fetch: app.fetch, port });

export default app;
```

## Expected Results

- `app/db/schema.ts` exports an empty `schema` object unless the user provided a data model.
- `app/context.ts` exposes a typed Drizzle database (type matches the target).
- The server entry creates a Drizzle client and passes it to React Router context per request.
