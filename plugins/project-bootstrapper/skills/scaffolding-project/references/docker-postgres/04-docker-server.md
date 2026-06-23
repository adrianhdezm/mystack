# 04 - Docker Server (docker-postgres target)

Sets up the Hono app entry point, the root `server.ts` dev/prod entry, creates `docker-compose.yml` for local development with Postgres, and configures Vite for SSR builds.

## Steps

1. Check the latest Hono package versions.

```sh
pnpm view hono version
pnpm view @hono/node-server version
```

2. Install Hono and the Node.js server adapter.

```sh
pnpm add hono@latest @hono/node-server@latest
```

3. Create `workers/app.ts` — the Hono app. No `serve()` call here; the root `server.ts` handles process lifecycle.

```ts
import { Hono } from "hono";

const app = new Hono();

export default app;
```

4. Create `server.ts` at the project root. In development it starts a Vite dev server and delegates to `workers/app.ts` via SSR module loading. In production it serves the built output from `build/`.

```ts
import { getRequestListener, serve } from "@hono/node-server";
import { serveStatic } from "@hono/node-server/serve-static";
import type { Hono } from "hono";
import { Hono as HonoApp } from "hono";
import { createServer } from "node:http";

const DEV = process.env.NODE_ENV === "development";
const PORT = Number(process.env.PORT) || 3000;

if (DEV) {
  const vite = await import("vite");
  const viteServer = await vite.createServer({
    server: { middlewareMode: true },
  });

  createServer((req, res) => {
    viteServer.middlewares(req, res, () => {
      viteServer
        .ssrLoadModule("./workers/app.ts")
        .then(async (mod) => {
          const devApp = mod.default as Hono;
          await getRequestListener(devApp.fetch.bind(devApp))(req, res);
        })
        .catch((e: unknown) => {
          if (e instanceof Error) viteServer.ssrFixStacktrace(e);
          res.statusCode = 500;
          res.end();
        });
    });
  }).listen(PORT, () => console.log(`Dev server at http://localhost:${PORT}`));
} else {
  const { default: app } = (await import("./build/server/index.js")) as {
    default: Hono;
  };

  const wrapper = new HonoApp();

  wrapper.use(
    "/assets/*",
    serveStatic({ root: "./build/client" }),
    async (c, next) => {
      c.header("Cache-Control", "public, max-age=31536000, immutable");
      await next();
    },
  );
  wrapper.use(
    "/*",
    serveStatic({ root: "./build/client" }),
    async (c, next) => {
      c.header("Cache-Control", "public, max-age=3600");
      await next();
    },
  );
  wrapper.all("*", (c) => app.fetch(c.req.raw));

  serve({ fetch: wrapper.fetch, port: PORT }, () =>
    console.log(`Server running at http://localhost:${PORT}`),
  );
}
```

5. Create `db/scripts/init.sql`. This script runs once when the container is first started and creates a dedicated project database.

```sql
CREATE DATABASE <project_name>_db;
GRANT ALL PRIVILEGES ON DATABASE <project_name>_db TO postgres;
```

Replace `<project_name>` with the lowercase snake-case project name.

6. Create `docker-compose.yml` for local development.

```yaml
services:
  postgres:
    image: postgres:17-alpine
    restart: unless-stopped
    environment:
      POSTGRES_PASSWORD: ${POSTGRES_PASSWORD:-s3cr3t}
    ports:
      - "${POSTGRES_PORT:-5432}:5432"
    volumes:
      - ./db/data:/var/lib/postgresql/data
      - ./db/scripts/init.sql:/docker-entrypoint-initdb.d/init.sql
```

7. Add `db/data/` to `.gitignore` — it holds the Postgres data volume and must not be committed.

```gitignore
# Docker
db/data/
```

8. Create `.env.example` with required environment variables (no secrets).

```env
DATABASE_URL=postgres://postgres:s3cr3t@localhost:5432/<project_name>_db
POSTGRES_PASSWORD=s3cr3t
POSTGRES_PORT=5432
PORT=3000
NODE_ENV=development
APP_NAME=<project-name>
```

9. Create `.env` from the template. This file is gitignored and holds local secrets.

```sh
cp .env.example .env
```

10. Update `vite.config.ts`. No dev server plugin needed — `server.ts` handles dev via Vite middleware mode. The `environments.ssr` block tells `react-router build` to compile `workers/app.ts` into `build/server/index.js`.

```ts
import { reactRouter } from "@react-router/dev/vite";
import { defineConfig } from "vite";

export default defineConfig({
  plugins: [reactRouter()],
  resolve: {
    tsconfigPaths: true,
  },
  environments: {
    ssr: {
      build: {
        rollupOptions: {
          input: "./workers/app.ts",
        },
      },
    },
  },
});
```

11. Add server scripts to `package.json`. Both dev and prod use the same `server.ts` entry point — `NODE_ENV` in `.env` controls which branch runs.

```json
{
  "scripts": {
    "dev": "node server.ts",
    "build": "react-router build",
    "start": "node server.ts"
  }
}
```

## Expected Results

- `hono` and `@hono/node-server` are installed as dependencies.
- `workers/app.ts` exports a minimal Hono app with no `serve()` call.
- `server.ts` exists at the project root with a dev/prod branch on `NODE_ENV`.
- `vite.config.ts` uses `reactRouter()` with `environments.ssr` pointing to `workers/app.ts`. No `@hono/vite-dev-server` plugin.
- `db/scripts/init.sql` exists and creates a dedicated project database.
- `docker-compose.yml` exists with a Postgres 17 service, init script volume, and `db/data/` data volume.
- `db/data/` is in `.gitignore`.
- `.env.example` exists with `DATABASE_URL`, `POSTGRES_PASSWORD`, `POSTGRES_PORT`, `PORT`, `NODE_ENV`, and `APP_NAME`.
- `.env` exists (gitignored) with `NODE_ENV=development`.
- `package.json` includes `dev`, `build`, and `start` scripts.
