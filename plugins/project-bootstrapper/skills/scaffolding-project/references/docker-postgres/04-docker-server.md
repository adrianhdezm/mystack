# 04 - Docker Server (docker-postgres target)

Sets up the Node.js server entry point using Hono, creates `docker-compose.yml` for local development with Postgres, and wires `@hono/vite-dev-server` into Vite so Hono handles requests during development.

## Steps

1. Check the latest Hono package versions.

```sh
pnpm view hono version
pnpm view @hono/node-server version
pnpm view @hono/vite-dev-server version
```

2. Install Hono and the Node.js server adapter. Install the Vite dev server plugin as a dev dependency.

```sh
pnpm add hono@latest @hono/node-server@latest
pnpm add -D @hono/vite-dev-server@latest
```

3. Create `server/app.ts` — the Hono app entry point. Keep it minimal at this stage; React Router context and the production `serve()` call are added in the next step.

```ts
import { Hono } from 'hono';

const app = new Hono();

export default app;
```

4. Create `docker-compose.yml` for local development.

```yaml
services:
  postgres:
    image: postgres:16-alpine
    restart: unless-stopped
    environment:
      POSTGRES_USER: app
      POSTGRES_PASSWORD: app
      POSTGRES_DB: app
    ports:
      - "5432:5432"
    volumes:
      - .docker-data/postgres:/var/lib/postgresql/data
```

5. Create `.env.example` with required environment variables (no secrets).

```env
DATABASE_URL=postgres://app:app@localhost:5432/app
PORT=3000
APP_NAME=<project-name>
```

6. Create `.env` from the template. This file is gitignored and holds local secrets.

```sh
cp .env.example .env
```

7. Update `vite.config.ts` to wire `@hono/vite-dev-server` into the Vite plugin pipeline. The `exclude` patterns ensure that Vite-owned requests (static assets, HMR, React Router data routes) are not intercepted by Hono.

```ts
import devServer, { defaultOptions } from '@hono/vite-dev-server';
import { reactRouter } from '@react-router/dev/vite';
import { defineConfig } from 'vite';

export default defineConfig({
  plugins: [
    devServer({
      entry: 'server/app.ts',
      exclude: [/\.data(\?.*)?$/, ...defaultOptions.exclude],
    }),
    reactRouter(),
  ],
  resolve: {
    tsconfigPaths: true,
  },
});
```

8. Add server scripts to `package.json`.

```json
{
  "scripts": {
    "dev": "react-router dev",
    "build": "react-router build",
    "start": "node server/app.js",
    "preview": "react-router build && node server/app.js"
  }
}
```

## Expected Results

- `hono`, `@hono/node-server` are installed as dependencies.
- `@hono/vite-dev-server` is installed as a development dependency.
- `server/app.ts` exports a minimal Hono app.
- `vite.config.ts` includes `devServer` with `entry: 'server/app.ts'` and React Router data route exclusion.
- `docker-compose.yml` exists with a Postgres 16 service.
- `.docker-data/` is in `.gitignore`.
- `.env.example` exists with `DATABASE_URL`, `PORT`, and `APP_NAME`.
- `.env` exists (gitignored) with local development values.
- `package.json` includes `dev`, `build`, `start`, and `preview` scripts.
