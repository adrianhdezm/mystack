# 02 - Postgres Setup (docker-postgres target)

Configures the Postgres connection using `node-postgres` (`pg`) and `drizzle-kit`, and adds the database to `docker-compose.yml` if not already present.

## Steps

1. Verify Docker Compose is running with a Postgres service. If `docker-compose.yml` does not have a `postgres` service, add it:

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

2. Check the latest `pg` package version.

```sh
pnpm view pg version
pnpm view @types/pg version
```

3. Install the `pg` driver and its types.

```sh
pnpm add pg@latest
pnpm add -D @types/pg@latest
```

If `@types/pg` is in the lockfile but TypeScript can't resolve `pg`, run `pnpm install` again — pnpm occasionally skips symlinking on the first install.

4. Add `DATABASE_URL` to `.env` with the local development connection string.

```env
DATABASE_URL=postgres://app:app@localhost:5432/app
```

5. Add `DATABASE_URL` placeholder to `.env.example`:

```env
DATABASE_URL=postgres://user:password@localhost:5432/dbname
```

6. Create `drizzle.config.ts` reading `DATABASE_URL` from the environment.

```ts
import { defineConfig } from 'drizzle-kit';

export default defineConfig({
  schema: './app/db/schema.ts',
  out: './db/migrations',
  dialect: 'postgresql',
  dbCredentials: {
    url: process.env.DATABASE_URL!,
  },
});
```

7. Add database scripts to `package.json`. For Postgres, there is only one migration target (no local/remote split):

```json
{
  "scripts": {
    "db:generate": "drizzle-kit generate",
    "db:migrate": "drizzle-kit migrate"
  }
}
```

8. Start Docker Compose if not already running:

```sh
docker compose up -d
```

## Expected Results

- `pg` and `@types/pg` are installed.
- `drizzle.config.ts` exists reading `DATABASE_URL` from the environment with `dialect: "postgresql"`.
- `.env` contains `DATABASE_URL` pointing to the Docker Postgres instance.
- `.env.example` documents `DATABASE_URL`.
- `package.json` includes `db:generate` and `db:migrate` scripts.
- `docker-compose.yml` includes a Postgres service.
