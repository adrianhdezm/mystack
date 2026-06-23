# 03 - Server Integration (docker-postgres target)

## App context

Update `app/context.ts` to include Better Auth alongside the Node.js environment and Drizzle database:

```ts
import { createContext } from "react-router";
import type { NodePgDatabase } from "drizzle-orm/node-postgres";
import type { betterAuth } from "better-auth";

import type { schema } from "./db/schema";

export const appContext = createContext<{
  env: {
    APP_NAME: string;
  };
  db: NodePgDatabase<typeof schema>;
  auth: ReturnType<typeof betterAuth>;
}>();
```

Preserve any additional context values already used by the app.

## Server entrypoint

Update `workers/app.ts` to construct Better Auth once at module scope (Node.js has a stable connection pool, unlike Cloudflare Workers). The `Pool`, `db`, and `auth` instances are shared across requests. No `serve()` call — process lifecycle is owned by `server.ts` at the project root.

```ts
import { Hono } from "hono";
import { createRequestHandler, RouterContextProvider } from "react-router";
import { betterAuth } from "better-auth";
import { drizzleAdapter } from "better-auth/adapters/drizzle";
import { drizzle } from "drizzle-orm/node-postgres";
import type { NodePgDatabase } from "drizzle-orm/node-postgres";
import { Pool } from "pg";
import { appContext } from "../app/context";
import { schema } from "../app/db/schema";

const pool = new Pool({ connectionString: process.env.DATABASE_URL });
const db = drizzle(pool, { schema }) as NodePgDatabase<typeof schema>;

const auth = betterAuth({
  database: drizzleAdapter(db, {
    provider: "pg",
    schema: {
      ...schema,
      user: schema.users,
      session: schema.sessions,
      verification: schema.verifications,
      account: schema.accounts,
    },
  }),
  secret: process.env.AUTH_SECRET!,
  baseURL:
    process.env.BASE_URL ?? `http://localhost:${process.env.PORT ?? 3000}`,
  emailAndPassword: {
    enabled: true,
    autoSignIn: false,
  },
  session: {
    cookieCache: {
      enabled: true,
      maxAge: 5 * 60,
    },
  },
  advanced: {
    cookiePrefix: "App",
    database: {
      generateId: "uuid",
    },
  },
}) as ReturnType<typeof betterAuth>;

const app = new Hono();
const requestHandler = createRequestHandler(
  () => import("virtual:react-router/server-build"),
  import.meta.env.MODE,
);

app.all("*", async (c) => {
  const routerContext = new RouterContextProvider();
  routerContext.set(appContext, {
    env: { APP_NAME: process.env.APP_NAME ?? "" },
    db,
    auth,
  });
  return requestHandler(c.req.raw, routerContext);
});

export default app;
```

Add `AUTH_SECRET` and `BASE_URL` to `.env`:

```env
AUTH_SECRET=<generated-secret>
BASE_URL=http://localhost:3000
```

Add placeholder to `.env.example`:

```env
AUTH_SECRET=
BASE_URL=http://localhost:3000
```
