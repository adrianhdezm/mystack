# Server Integration

## App context

Update the React Router server context module, commonly `app/context.ts`, to
include Better Auth alongside Cloudflare and Drizzle:

```ts
import { createContext } from 'react-router';
import type { DrizzleD1Database } from 'drizzle-orm/d1';
import { betterAuth } from 'better-auth';

import { schema } from './db/schema';

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

Update `workers/app.ts` or the existing Worker entrypoint to create Better Auth
per request with the current request origin as `baseURL`:

```ts
import { betterAuth, type BetterAuthOptions } from 'better-auth';
import { drizzleAdapter } from 'better-auth/adapters/drizzle';
import { drizzle } from 'drizzle-orm/d1';

import { schema } from '../app/db/schema';
import { requestHandler } from './request-handler';

export default {
  async fetch(request, env, ctx) {
    const { protocol, host } = new URL(request.url);
    const baseURL = `${protocol}//${host}`;
    const db = drizzle(env.APP_DB, { schema });
    const betterAuthOptions: BetterAuthOptions = {
      database: drizzleAdapter(db, {
        provider: 'sqlite',
        schema: {
          ...schema,
          user: schema.users,
          session: schema.sessions,
          verification: schema.verifications,
          account: schema.accounts
        }
      }),
      secret: env.AUTH_SECRET,
      baseURL,
      emailAndPassword: {
        enabled: true,
        autoSignIn: false
      },
      session: {
        cookieCache: {
          enabled: true,
          maxAge: 5 * 60
        }
      },
      advanced: {
        cookiePrefix: 'App'
      }
    };
    const auth = betterAuth(betterAuthOptions);

    return requestHandler(request, {
      cloudflare: { env, ctx },
      db,
      auth
    });
  }
} satisfies ExportedHandler<Env>;
```

Adapt import paths to the target project. Do not replace unrelated request
handler behavior.

## Types and Cloudflare env

Run the project's Cloudflare type generation command after adding `AUTH_SECRET`
and any Wrangler configuration changes, commonly:

```sh
pnpm cf-typegen
```

If the project uses a different command, inspect `package.json`.
