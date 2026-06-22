# 04 - Docker Server (docker-postgres target)

Sets up the Node.js server entry point using Hono, and creates `docker-compose.yml` for local development with Postgres.

## Steps

1. Check the latest Hono package version and install it.

```sh
pnpm view hono version
pnpm add hono@latest
```

2. Create `server/app.ts` — the Node.js server entry point.

```ts
import { Hono } from 'hono';
import { serve } from '@hono/node-server';
import { createRequestHandler } from 'react-router';

const app = new Hono();

const requestHandler = createRequestHandler(
  () => import('virtual:react-router/server-build'),
  import.meta.env.MODE
);

app.all('*', async (c) => {
  return requestHandler(c.req.raw);
});

const port = Number(process.env.PORT) || 3000;

serve({ fetch: app.fetch, port }, () => {
  console.log(`Server running at http://localhost:${port}`);
});

export default app;
```

3. Install the Hono Node.js server adapter.

```sh
pnpm view @hono/node-server version
pnpm add @hono/node-server@latest
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
```

6. Create `.env` from the template. This file is gitignored and holds local secrets.

```sh
cp .env.example .env
```

7. Add server scripts to `package.json`.

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

- `hono` and `@hono/node-server` are installed as dependencies.
- `server/app.ts` exists with a Hono server that delegates all requests to the React Router request handler.
- `docker-compose.yml` exists with a Postgres 16 service.
- `.docker-data/` is in `.gitignore`.
- `.env.example` exists with `DATABASE_URL` and `PORT`.
- `.env` exists (gitignored) with local development values.
- `package.json` includes `dev`, `build`, `start`, and `preview` scripts.
