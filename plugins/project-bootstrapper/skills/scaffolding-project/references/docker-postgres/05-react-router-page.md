# 05 - React Router Page (docker-postgres target)

Wires React Router into the Docker/Postgres Node.js project using a Node.js-compatible context. The difference from the Cloudflare variant is that the server entry is `server/app.ts` (Hono) and the context contains Node.js environment variables, not Cloudflare bindings.

## Steps

Before adding or changing these files, load `react-router-patterns` and follow its app-level file, route config, route module, loader, error boundary, and context patterns.

1. Check the latest React and React Router package versions.

```sh
pnpm view react version
pnpm view react-dom version
pnpm view react-router version
pnpm view isbot version
pnpm view @react-router/dev version
```

2. Install React and React Router dependencies. React does not bundle its own TypeScript types — install `@types/react` and `@types/react-dom` as dev dependencies.

```sh
pnpm add react@latest react-dom@latest react-router@latest isbot@latest
pnpm add -D @react-router/dev@latest @types/react@latest @types/react-dom@latest
```

3. Create `react-router.config.ts`.

```ts
import type { Config } from '@react-router/dev/config';

export default {
  ssr: true,
} satisfies Config;
```

4. Update `tsconfig.node.json` to include `react-router.config.ts`.

```json
{
  "include": ["vite.config.ts", "react-router.config.ts"]
}
```

5. Create `app/root.tsx` (identical to the Cloudflare variant).

```tsx
import type { ReactNode } from 'react';
import {
  Links,
  Meta,
  Outlet,
  Scripts,
  ScrollRestoration,
  isRouteErrorResponse,
} from 'react-router';
import type { Route } from './+types/root';

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
  let message = 'Oops!';
  let details = 'An unexpected error occurred.';
  let stack: string | undefined;

  if (isRouteErrorResponse(error)) {
    message = error.status === 404 ? '404' : 'Error';
    details =
      error.status === 404
        ? 'The requested page could not be found.'
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

6. Create `app/entry.server.tsx` (identical to the Cloudflare variant).

```tsx
import type { EntryContext } from 'react-router';
import { ServerRouter } from 'react-router';
import { isbot } from 'isbot';
import { renderToReadableStream } from 'react-dom/server';

export default async function handleRequest(
  request: Request,
  responseStatusCode: number,
  responseHeaders: Headers,
  routerContext: EntryContext
) {
  let shellRendered = false;
  const userAgent = request.headers.get('user-agent');

  const body = await renderToReadableStream(
    <ServerRouter context={routerContext} url={request.url} />,
    {
      onError(error: unknown) {
        responseStatusCode = 500;
        if (shellRendered) {
          console.error(error);
        }
      },
    }
  );
  shellRendered = true;

  if ((userAgent && isbot(userAgent)) || routerContext.isSpaMode) {
    await body.allReady;
  }

  responseHeaders.set('Content-Type', 'text/html');
  return new Response(body, {
    headers: responseHeaders,
    status: responseStatusCode,
  });
}
```

7. Create `app/routes.ts`.

```ts
import { index, type RouteConfig } from '@react-router/dev/routes';

export default [index('routes/home.tsx')] satisfies RouteConfig;
```

8. Create `app/context.ts`. For the Docker/Postgres target the context holds Node.js process environment, not Cloudflare bindings.

```ts
import { createContext } from 'react-router';

export const appContext = createContext<{
  env: {
    APP_NAME: string;
  };
}>();
```

9. Create `app/routes/home.tsx`.

```tsx
import { appContext } from '../context';
import type { Route } from './+types/home';

export function meta() {
  return [
    { title: '<project-name>' },
    { name: 'description', content: '<project-description>' },
  ];
}

export function loader({ context }: Route.LoaderArgs) {
  const app = context.get(appContext);
  return { message: `Welcome to ${app.env.APP_NAME}` };
}

export default function Home({ loaderData }: Route.ComponentProps) {
  return <h1>{loaderData.message}</h1>;
}
```

10. Create a `public` folder with a `favicon.ico` placeholder.

11. Update `server/app.ts` to wire React Router and add the production `serve()` call. In development, `@hono/vite-dev-server` handles requests via Vite; in production, `serve()` from `@hono/node-server` drives the server.

```ts
import { serve } from '@hono/node-server';
import { Hono } from 'hono';
import { createRequestHandler, RouterContextProvider } from 'react-router';

import { appContext } from '../app/context';

const app = new Hono();

const requestHandler = createRequestHandler(
  () => import('virtual:react-router/server-build'),
  import.meta.env.MODE,
);

app.all('*', async (c) => {
  const routerContext = new RouterContextProvider();
  routerContext.set(appContext, {
    env: {
      APP_NAME: process.env.APP_NAME ?? '<project-name>',
    },
  });
  return requestHandler(c.req.raw, routerContext);
});

const port = Number(process.env.PORT) || 3000;

serve({ fetch: app.fetch, port }, () => {
  console.log(`Server running at http://localhost:${port}`);
});

export default app;
```

Context checklist:
- Treat the middleware context API as always enabled — React Router v8 default.
- Define request-scoped dependencies with a typed `appContext` key from `createContext<T>()`.
- Include Node.js environment values under `appContext` as `env: { ... }`.
- Create a `RouterContextProvider` for each request in `server/app.ts`.
- Pass `routerContext` as the second argument to `requestHandler(request, routerContext)`.
- Read dependencies in routes from `context.get(appContext)`.
- Do not use `AppLoadContext` or plain object context.

12. Update `vite.config.ts` to use the React Router Vite plugin.

```ts
import { reactRouter } from '@react-router/dev/vite';
import { defineConfig } from 'vite';

export default defineConfig({
  plugins: [reactRouter()],
  resolve: {
    tsconfigPaths: true,
  },
});
```

## Expected Results

- `react`, `react-dom`, `react-router`, and `isbot` are installed as dependencies.
- `@react-router/dev` is installed as a development dependency.
- `react-router.config.ts` exists with SSR enabled. No `future` flags — all v8 behaviors are defaults.
- `tsconfig.node.json` includes `react-router.config.ts`.
- `app/root.tsx`, `app/entry.server.tsx`, `app/routes.ts`, `app/context.ts`, and `app/routes/home.tsx` exist.
- `app/context.ts` exports `appContext` with `env: { APP_NAME: string }`.
- `app/routes/home.tsx` reads `APP_NAME` from `context.get(appContext).env`.
- `public/favicon.ico` exists.
- `server/app.ts` creates a per-request `RouterContextProvider`, sets `appContext`, and does not use `AppLoadContext`.
- `vite.config.ts` uses `reactRouter()` (no Cloudflare plugin).
