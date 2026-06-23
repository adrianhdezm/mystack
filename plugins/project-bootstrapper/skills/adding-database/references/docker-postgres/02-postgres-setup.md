# 02 - Postgres Setup (docker-postgres target)

Configures the Postgres connection using `node-postgres` (`pg`) and `drizzle-kit`, and adds the database to `docker-compose.yml` if not already present.

## Steps

1. Verify Docker Compose is running with a Postgres service. If `docker-compose.yml` does not have a `postgres` service, add it along with the init script that creates the project database:

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

Create `db/scripts/init.sql` if not already present:

```sql
CREATE DATABASE <project_name>_db;
GRANT ALL PRIVILEGES ON DATABASE <project_name>_db TO postgres;
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

4. Add `DATABASE_URL` to `.env` with the local development connection string pointing to the project database created by the init script.

```env
DATABASE_URL=postgres://postgres:s3cr3t@localhost:5432/<project_name>_db
```

5. Add `DATABASE_URL` placeholder to `.env.example`:

```env
DATABASE_URL=postgres://postgres:s3cr3t@localhost:5432/<project_name>_db
```

6. Create `drizzle.config.ts` reading `DATABASE_URL` from the environment.

```ts
import { type Config, defineConfig } from "drizzle-kit";

if (!process.env.DATABASE_URL) {
  throw new Error("DATABASE_URL is required");
}

export default defineConfig({
  schema: "./app/db/schema.ts",
  out: "./db/migrations",
  dialect: "postgresql",
  dbCredentials: {
    url: process.env.DATABASE_URL,
  },
  migrations: {
    prefix: "timestamp",
    table: "__migrations__",
    schema: "public",
  },
}) satisfies Config;
```

7. Add database scripts to `package.json`. On Node ≥ 24 the `drizzle-kit` shell shim fails — invoke the CJS binary directly via `node` to avoid this:

```json
{
  "scripts": {
    "db:generate": "node --env-file=.env ./node_modules/drizzle-kit/bin.cjs generate",
    "db:migrate": "node --env-file=.env ./node_modules/drizzle-kit/bin.cjs migrate"
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
- `.env` contains `DATABASE_URL` pointing to the project-specific database.
- `.env.example` documents `DATABASE_URL`.
- `db/scripts/init.sql` creates the project database and grants privileges.
- `docker-compose.yml` includes a Postgres 17 service with the init script and `db/data/` volume.
- `package.json` includes `db:generate` and `db:migrate` scripts using `node` to invoke drizzle-kit directly.
- `docker-compose.yml` includes a Postgres service.
