# 04 - App Integration (SAP AI Core)

## App context

Update `app/context.ts` following the same pattern as [docker-postgres/04-app-integration.md](../04-app-integration.md) — the context shape is identical regardless of provider. Preserve any additional context values already used by the app.

## Server entrypoint

Update `workers/app.ts` to construct `AIService` once at module scope — `process.env` is available at startup in Node.js.

Add a startup guard before constructing `AIService` to fail fast with a clear message if any required variable is missing:

```ts
import { AIService } from "../app/services/ai.service";

const requiredEnv = [
  "AICORE_BASE_URL",
  "AICORE_AUTH_URL",
  "AICORE_CLIENT_ID",
  "AICORE_CLIENT_SECRET",
  "AICORE_MODEL_ID",
];
const missingEnv = requiredEnv.filter((k) => !process.env[k]);
if (missingEnv.length) {
  throw new Error(
    `Missing required environment variables: ${missingEnv.join(", ")}`,
  );
}

const ai = new AIService(
  process.env.AICORE_BASE_URL!,
  process.env.AICORE_AUTH_URL!,
  process.env.AICORE_CLIENT_ID!,
  process.env.AICORE_CLIENT_SECRET!,
  process.env.AICORE_RESOURCE_GROUP ?? "default",
  process.env.AICORE_MODEL_ID!,
);
```

Wire `ai` into the `RouterContextProvider` in the server entrypoint:

```ts
routerContext.set(appContext, {
  env: { APP_NAME: process.env.APP_NAME ?? "" },
  db,
  ai,
  // auth, files if present
});
```

## Failure Handling

- **Missing env vars at startup** — the guard throws immediately with the names of the missing variables. Check `.env` against `.env.example` and ensure all `AICORE_*` vars are set.
- **Auth failure on first model call** — the provider fetches an OAuth token lazily. A `401` or `403` at call time means `AICORE_CLIENT_ID`, `AICORE_CLIENT_SECRET`, or `AICORE_AUTH_URL` is wrong. Verify the values against the SAP BTP service key.
- **Wrong `AICORE_BASE_URL`** — a network error or `404` on the first model call usually means the base URL is incorrect or the deployment is not active in SAP AI Core. Check the deployment status in the SAP AI Launchpad.
- **Wrong `AICORE_RESOURCE_GROUP`** — a `404` scoped to a specific resource may indicate the model deployment lives in a different resource group. Defaults to `default` if not set.

## Expected Results

- `app/context.ts` exposes `ai: AIService`.
- `workers/app.ts` constructs `new AIService(...)` at module scope using `process.env`.
- `AIService` is passed into `RouterContextProvider` on every request.
- No `OPENAI_*` variables are referenced.
