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

4. Create `db/scripts/init.sql`. This script runs once when the container is first started and creates a dedicated project database.

```sql
CREATE DATABASE <project_name>_db;
GRANT ALL PRIVILEGES ON DATABASE <project_name>_db TO postgres;
```

Replace `<project_name>` with the lowercase snake-case project name.

5. Create `docker-compose.yml` for local development.

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

6. Add `db/data/` to `.gitignore` — it holds the Postgres data volume and must not be committed.

```gitignore
# Docker
.docker-data/
db/data/
```

7. Create `.env.example` with required environment variables (no secrets).

```env
DATABASE_URL=postgres://postgres:s3cr3t@localhost:5432/<project_name>_db
POSTGRES_PASSWORD=s3cr3t
POSTGRES_PORT=5432
PORT=3000
APP_NAME=<project-name>
```

8. Create `.env` from the template. This file is gitignored and holds local secrets.

```sh
cp .env.example .env
```

9. Update `vite.config.ts` to wire `@hono/vite-dev-server` into the Vite plugin pipeline.

The `exclude` array controls which requests Vite handles instead of Hono. The first pattern uses a negative lookahead to pass `.data` route URLs to React Router while blocking all other `/app/**` source file requests from reaching Hono.

```ts
import devServer, { defaultOptions } from '@hono/vite-dev-server';
import { reactRouter } from '@react-router/dev/vite';
import { defineConfig } from 'vite';

export default defineConfig({
  plugins: [
    devServer({
      entry: 'server/app.ts',
      exclude: [
        /^\/app\/(?!.*\.data(\?|$)).*\..*(\?.*)?$/,
        /\?import(\?.*)?$/,
        /^\/@.+$/,
        /^\/node_modules\/.*/,
        ...defaultOptions.exclude,
      ],
    }),
    reactRouter(),
  ],
  resolve: {
    tsconfigPaths: true,
  },
});
```

10. Add server scripts to `package.json`.

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
- `db/scripts/init.sql` exists and creates a dedicated project database.
- `docker-compose.yml` exists with a Postgres 17 service, init script volume, and `db/data/` data volume.
- `db/data/` is in `.gitignore`.
- `.env.example` exists with `DATABASE_URL`, `POSTGRES_PASSWORD`, `POSTGRES_PORT`, `PORT`, and `APP_NAME`.
- `.env` exists (gitignored) with local development values.
- `package.json` includes `dev`, `build`, `start`, and `preview` scripts.
