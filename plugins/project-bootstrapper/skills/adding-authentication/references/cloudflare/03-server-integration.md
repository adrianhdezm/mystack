# Server Integration

## App context

Update the React Router server context module, commonly `app/context.ts`, to include Better Auth alongside Cloudflare and Drizzle:

```ts
import { createContext } from "react-router";
import type { DrizzleD1Database } from "drizzle-orm/d1";
import { betterAuth } from "better-auth";
import type { schema } from "./db/schema";

export const appContext = createContext<{
  cloudflare: {
    env: Env;
    ctx: ExecutionContext;
  };
  db: DrizzleD1Database<typeof schema>;
  auth: ReturnType<typeof betterAuth>;
}>();
```

Preserve any additional context values already used by the app.

## Worker entrypoint

Update `workers/app.ts` to use Hono and construct Better Auth per request. Better Auth must be constructed inside the handler because Cloudflare Workers only expose `env` bindings inside the fetch handler, not at module scope.

```ts
import { Hono } from "hono";
import { createRequestHandler, RouterContextProvider } from "react-router";
import { betterAuth, type BetterAuthOptions } from "better-auth";
import { drizzleAdapter } from "better-auth/adapters/drizzle";
import { drizzle } from "drizzle-orm/d1";
import { appContext } from "~/context";
import { schema } from "~/db/schema";

const app = new Hono<{ Bindings: Env }>();

const requestHandler = createRequestHandler(
  () => import("virtual:react-router/server-build"),
  import.meta.env.MODE,
);

app.all("*", async (c) => {
  const { protocol, host } = new URL(c.req.url);
  const baseURL = `${protocol}//${host}`;
  const db = drizzle(c.env.APP_DB, { schema });
  const betterAuthOptions: BetterAuthOptions = {
    database: drizzleAdapter(db, {
      provider: "sqlite",
      schema: {
        ...schema,
        user: schema.users,
        session: schema.sessions,
        verification: schema.verifications,
        account: schema.accounts,
      },
    }),
    secret: c.env.AUTH_SECRET,
    baseURL,
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
    },
  };
  const auth = betterAuth(betterAuthOptions) as ReturnType<typeof betterAuth>;
  const routerContext = new RouterContextProvider();
  routerContext.set(appContext, {
    cloudflare: { env: c.env, ctx: c.executionCtx },
    db,
    auth,
  });
  return requestHandler(c.req.raw, routerContext);
});

export default app;
```

## Types and Cloudflare env

Run the project's Cloudflare type generation command after adding `AUTH_SECRET` and any Wrangler configuration changes, commonly:

```sh
pnpm cf-typegen
```

If the project uses a different command, inspect `package.json`.
