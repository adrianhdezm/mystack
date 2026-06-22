# Server Integration

## App context

Update the React Router server context module, commonly `app/context.ts`, to include Better Auth alongside Cloudflare and Drizzle:

```ts
import { createContext } from "react-router";
import type { DrizzleD1Database } from "drizzle-orm/d1";
import { betterAuth } from "better-auth";

import { schema } from "./db/schema";

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

Update `workers/app.ts` to create Better Auth per request with the current request origin as `baseURL`. Better Auth is constructed on every request because Cloudflare Workers only expose `env` bindings inside the `fetch` handler, not at module scope.

Preserve the existing `createRequestHandler`, `RouterContextProvider`, and Drizzle setup.

```ts
import { createRequestHandler, RouterContextProvider } from "react-router";
import { betterAuth, type BetterAuthOptions } from "better-auth";
import { drizzleAdapter } from "better-auth/adapters/drizzle";
import { drizzle } from "drizzle-orm/d1";
import { appContext } from "~/context";
import { schema } from "~/db/schema";

const requestHandler = createRequestHandler(
  () => import("virtual:react-router/server-build"),
  import.meta.env.MODE,
);

export default {
  async fetch(request, env, ctx) {
    const { protocol, host } = new URL(request.url);
    const baseURL = `${protocol}//${host}`;
    const db = drizzle(env.APP_DB, { schema });
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
      secret: env.AUTH_SECRET,
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
    const auth = betterAuth(betterAuthOptions);
    const routerContext = new RouterContextProvider();

    routerContext.set(appContext, {
      cloudflare: { env, ctx },
      db,
      auth,
    });

    return requestHandler(request, routerContext);
  },
} satisfies ExportedHandler<Env>;
```

## Types and Cloudflare env

Run the project's Cloudflare type generation command after adding `AUTH_SECRET` and any Wrangler configuration changes, commonly:

```sh
pnpm cf-typegen
```

If the project uses a different command, inspect `package.json`.
