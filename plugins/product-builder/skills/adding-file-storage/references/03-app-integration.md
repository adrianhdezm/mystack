# 03 - App Integration

Before changing React Router context or Worker request handling, load `react-router-patterns` and follow its app-level file and context patterns.

## Steps

1. Update `app/context.ts`.

Preserve existing context fields and add the `FilesService` import and `files` field.

```ts
import { createContext } from "react-router";
import type { DrizzleD1Database } from "drizzle-orm/d1";
import { schema } from "~/db/schema";
import { FilesService } from "~/services/file.service";

export const appContext = createContext<{
  cloudflare: {
    env: Env;
    ctx: ExecutionContext;
  };
  db: DrizzleD1Database<typeof schema>;
  files: FilesService;
}>();
```

2. Update `workers/app.ts`.

Preserve the existing `createRequestHandler`, `RouterContextProvider`, and Drizzle setup. Import `FilesService` and inject an instance into router context.

```ts
import { createRequestHandler, RouterContextProvider } from "react-router";
import { drizzle } from "drizzle-orm/d1";
import { appContext } from "~/context";
import { schema } from "~/db/schema";
import { FilesService } from "~/services/file.service";

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
      files: new FilesService(db, env.APP_FILES),
    });

    return requestHandler(request, routerContext);
  },
} satisfies ExportedHandler<Env>;
```

## Expected Results

- Route loaders and actions can read `files` from `appContext`.
- The file service shares the same D1 client as the rest of the request.
- The Worker uses the generated `env.APP_FILES` R2 binding.
