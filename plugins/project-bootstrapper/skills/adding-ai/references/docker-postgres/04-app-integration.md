# 04 - App Integration (docker-postgres target)

## App context

Update `app/context.ts` to include `AIService` alongside existing context values.

```ts
import { createContext } from 'react-router';
import type { NodePgDatabase } from 'drizzle-orm/node-postgres';
import type { AIService } from '~/services/ai.service';

import { schema } from './db/schema';

export const appContext = createContext<{
  env: {
    APP_NAME: string;
  };
  db: NodePgDatabase<typeof schema>;
  ai: AIService;
  // auth and files if present
}>();
```

Preserve any additional context values already used by the app.

## Server entrypoint

Update `server/app.ts` to construct `AIService` once at module scope — `process.env` is available at startup in Node.js.

```ts
import { AIService } from '../app/services/ai.service';

const ai = new AIService(
  process.env.OPENAI_API_KEY!,
  process.env.OPENAI_MODEL_ID ?? 'gpt-4o',
  process.env.OPENAI_IMAGE_MODEL_ID ?? 'dall-e-3'
);
```

Wire `ai` into the `RouterContextProvider` in the Hono request handler:

```ts
routerContext.set(appContext, {
  env: { APP_NAME: process.env.APP_NAME ?? '' },
  db,
  ai,
  // auth, files if present
});
```

## Expected Results

- `app/context.ts` exposes `ai: AIService`.
- `server/app.ts` constructs `new AIService(...)` at module scope using `process.env`.
- `AIService` is passed into `RouterContextProvider` on every request.
