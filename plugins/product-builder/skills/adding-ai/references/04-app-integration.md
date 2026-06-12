# 04 - App Integration

Before changing React Router context or Worker request handling, load `react-router-patterns` and follow its app-level file and context patterns.

## Steps

1. Update `app/context.ts`.

Preserve existing context fields and add the `AIService` import and `ai` field.

```ts
import { createContext } from "react-router";
import { AIService } from "~/services/ai.service";

export const appContext = createContext<{
  cloudflare: {
    env: Env;
    ctx: ExecutionContext;
  };
  // ... preserve existing fields (db, auth, files, etc.)
  ai: AIService;
}>();
```

2. Update `workers/app.ts`.

Preserve the existing `createRequestHandler`, `RouterContextProvider`, and any other service setup. Import `AIService` and inject an instance into router context.

```ts
import { createRequestHandler, RouterContextProvider } from "react-router";
import { appContext } from "~/context";
import { AIService } from "~/services/ai.service";

const requestHandler = createRequestHandler(
  () => import("virtual:react-router/server-build"),
  import.meta.env.MODE,
);

export default {
  async fetch(request, env, ctx) {
    const routerContext = new RouterContextProvider();

    routerContext.set(appContext, {
      cloudflare: { env, ctx },
      // ... preserve existing services (db, auth, files, etc.)
      ai: new AIService(
        env.OPENAI_API_KEY,
        env.OPENAI_MODEL_ID,
        env.OPENAI_IMAGE_MODEL_ID,
      ),
    });

    return requestHandler(request, routerContext);
  },
} satisfies ExportedHandler<Env>;
```

3. Run the project's Cloudflare type generation command after configuration changes:

```sh
pnpm cf-typegen
```

If the project uses a different command, inspect `package.json`.

4. Run the project's normal verification commands when present.

```sh
pnpm format
pnpm typecheck
pnpm lint
pnpm build
```

## Failure Handling

- If `OPENAI_API_KEY`, `OPENAI_MODEL_ID`, or `OPENAI_IMAGE_MODEL_ID` are not in the generated `Env` types after running `cf-typegen`, add them manually to `worker-configuration.d.ts`.
- If Cloudflare type generation fails because Wrangler is not authenticated, report the exact command that failed and leave source changes in place.

## Expected Results

- Route loaders and actions can read `ai` from `appContext`.
- The Worker constructs `AIService` with the API key and model IDs from the `env` object.
- Generated `Env` types include `OPENAI_API_KEY`, `OPENAI_MODEL_ID`, and `OPENAI_IMAGE_MODEL_ID`.
- Project verification commands pass or failures are explained.
