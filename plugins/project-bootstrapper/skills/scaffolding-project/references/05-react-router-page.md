# 05 - React Router Page

## Contents

- Steps (package installation, app files, route config, root layout, home route, context, worker, entry files)
- Expected Results

Before adding or changing these files, load `react-router-patterns` and follow its app-level file, route config, route module, loader, error boundary, and context patterns.

## Steps

1. Check the latest React and React Router package versions. Pin `react-router` and `@react-router/dev` to `^7` — do not install v8 or higher.

```sh
pnpm view react version
pnpm view react-dom version
pnpm view react-router version
pnpm view isbot version
pnpm view @react-router/dev version
```

2. Install React, React Router, and Hono dependencies.

```sh
pnpm add react@latest react-dom@latest react-router@^7 isbot@latest hono@latest
pnpm add -D @react-router/dev@^7
```

3. Create `react-router.config.ts`.

```ts
import type { Config } from "@react-router/dev/config";

export default {
  ssr: true,
  future: {
    v8_middleware: true,
    v8_passThroughRequests: true,
    v8_splitRouteModules: true,
    v8_trailingSlashAwareDataRequests: true,
    v8_viteEnvironmentApi: true,
  },
} satisfies Config;
```

4. Update `tsconfig.node.json` to include `react-router.config.ts`.

```json
{
  "include": ["vite.config.ts", "react-router.config.ts"]
}
```

5. Create `app/root.tsx`.

```tsx
import type { ReactNode } from "react";
import {
  Links,
  Meta,
  Outlet,
  Scripts,
  ScrollRestoration,
  isRouteErrorResponse,
} from "react-router";
import type { Route } from "./+types/root";

export function Layout({ children }: { children: ReactNode }) {
  return (
    <html lang="en">
      <head>
        <meta charSet="utf-8" />
        <meta name="viewport" content="width=device-width, initial-scale=1" />
        <Meta />
        <Links />
      </head>
      <body>
        {children}
        <ScrollRestoration />
        <Scripts />
      </body>
    </html>
  );
}

export default function App() {
  return <Outlet />;
}

export function ErrorBoundary({ error }: Route.ErrorBoundaryProps) {
  let message = "Oops!";
  let details = "An unexpected error occurred.";
  let stack: string | undefined;

  if (isRouteErrorResponse(error)) {
    message = error.status === 404 ? "404" : "Error";
    details =
      error.status === 404
        ? "The requested page could not be found."
        : error.statusText || details;
  } else if (import.meta.env.DEV && error && error instanceof Error) {
    details = error.message;
    stack = error.stack;
  }

  return (
    <main className="pt-16 p-4 container mx-auto">
      <h1>{message}</h1>
      <p>{details}</p>
      {stack && (
        <pre className="w-full p-4 overflow-x-auto">
          <code>{stack}</code>
        </pre>
      )}
    </main>
  );
}
```

6. Create `app/entry.server.tsx`.

```tsx
import type { EntryContext } from "react-router";
import { ServerRouter } from "react-router";
import { isbot } from "isbot";
import { renderToReadableStream } from "react-dom/server";

export default async function handleRequest(
  request: Request,
  responseStatusCode: number,
  responseHeaders: Headers,
  routerContext: EntryContext,
) {
  let shellRendered = false;
  const userAgent = request.headers.get("user-agent");

  const body = await renderToReadableStream(
    <ServerRouter context={routerContext} url={request.url} />,
    {
      onError(error: unknown) {
        responseStatusCode = 500;
        // Log streaming rendering errors from inside the shell.  Don't log
        // errors encountered during initial shell rendering since they'll
        // reject and get logged in handleDocumentRequest.
        if (shellRendered) {
          console.error(error);
        }
      },
    },
  );
  shellRendered = true;

  // Ensure requests from bots and SPA Mode renders wait for all content to load before responding
  // https://react.dev/reference/react-dom/server/renderToPipeableStream#waiting-for-all-content-to-load-for-crawlers-and-static-generation
  if ((userAgent && isbot(userAgent)) || routerContext.isSpaMode) {
    await body.allReady;
  }

  responseHeaders.set("Content-Type", "text/html");
  return new Response(body, {
    headers: responseHeaders,
    status: responseStatusCode,
  });
}
```

7. Create `app/routes.ts`.

```ts
import { index, type RouteConfig } from "@react-router/dev/routes";

export default [index("routes/home.tsx")] satisfies RouteConfig;
```

8. Create `app/context.ts`.

```ts
import { createContext } from "react-router";

export const appContext = createContext<{
  cloudflare: {
    env: Env;
    ctx: ExecutionContext;
  };
}>();
```

9. Create `app/routes/home.tsx`.

```tsx
import { appContext } from "../context";
import type { Route } from "./+types/home";

export function meta() {
  return [
    { title: "<project-name>" },
    { name: "description", content: "<project-description>" },
  ];
}

export function loader({ context }: Route.LoaderArgs) {
  const app = context.get(appContext);
  return { message: `Welcome to ${app.cloudflare.env.APP_NAME}` };
}

export default function Home({ loaderData }: Route.ComponentProps) {
  return <h1>{loaderData.message}</h1>;
}
```

10. Create a `public` folder with a `favicon.ico` file. Use an empty file as a placeholder since agents cannot generate binary content. The user can replace it with a real favicon later.

11. Update the previously created `workers/app.ts` to use Hono and the React Router request handler.

This project always enables React Router's `v8_middleware` future flag, so pass request-scoped server dependencies with `RouterContextProvider`. Do not use `AppLoadContext` or a plain object context in this setup.

```ts
import { Hono } from "hono";
import { createRequestHandler, RouterContextProvider } from "react-router";
import { appContext } from "../app/context";

const app = new Hono<{ Bindings: Env }>();

const requestHandler = createRequestHandler(
  () => import("virtual:react-router/server-build"),
  import.meta.env.MODE,
);

app.all("*", async (c) => {
  const routerContext = new RouterContextProvider();
  routerContext.set(appContext, {
    cloudflare: { env: c.env, ctx: c.executionCtx },
  });
  return requestHandler(c.req.raw, routerContext);
});

export default app;
```

Context checklist:

- Treat `v8_middleware: true` as always enabled for this project.
- Define request-scoped dependencies with a typed `appContext` key from `createContext<T>()`.
- Include Cloudflare bindings under `appContext` as `cloudflare: { env, ctx }`.
- Create a `RouterContextProvider` for each request in the Hono handler.
- Set dependencies with `routerContext.set(appContext, { cloudflare: { env: c.env, ctx: c.executionCtx } })`.
- Pass `routerContext` as the second argument to `requestHandler(c.req.raw, routerContext)`.
- Read dependencies in routes from `context.get(appContext)`.
- Do not use `AppLoadContext`, plain object context, `ExportedHandler`, or `context.cloudflare`.

12. Add React Router scripts to `package.json`.

```json
{
  "scripts": {
    "dev": "react-router dev",
    "build": "react-router build",
    "preview": "react-router build && vite preview",
    "deploy": "react-router build && wrangler deploy"
  }
}
```

13. Update `vite.config.ts` to use the React Router Vite plugin after the Cloudflare plugin.

```ts
import { reactRouter } from "@react-router/dev/vite";
import { cloudflare } from "@cloudflare/vite-plugin";
import { defineConfig } from "vite";

export default defineConfig({
  plugins: [cloudflare({ viteEnvironment: { name: "ssr" } }), reactRouter()],
  resolve: {
    tsconfigPaths: true,
  },
});
```

Keep the page simple and functional; avoid marketing copy unless requested.

## Expected Results

- `react`, `react-dom`, `react-router` (v7), `isbot`, and `hono` are installed as dependencies.
- `@react-router/dev` (v7) is installed as a development dependency.
- `react-router.config.ts` exists with SSR enabled and the React Router v7 future flags for v8 configured.
- `tsconfig.node.json` includes `react-router.config.ts`.
- `app/root.tsx` exists with the layout, outlet, and route error boundary.
- `app/entry.server.tsx`, `app/routes.ts`, `app/context.ts`, and `app/routes/home.tsx` exist.
- `app/context.ts` exports `appContext` with `cloudflare: { env, ctx }`.
- `app/routes/home.tsx` loads `APP_NAME` from `context.get(appContext).cloudflare.env`.
- `public/favicon.ico` exists.
- `workers/app.ts` uses a Hono app with `app.all('*', ...)` handler, creates a per-request `RouterContextProvider`, sets `appContext` with `c.env` and `c.executionCtx`, and exports `app` as the default export.
- `workers/app.ts` does not use `ExportedHandler`, `AppLoadContext`, or plain object context.
- `package.json` includes `dev`, `build`, `preview`, and `deploy` scripts for React Router and Wrangler.
- `vite.config.ts` uses `reactRouter()` after `cloudflare({ viteEnvironment: { name: "ssr" } })`.
