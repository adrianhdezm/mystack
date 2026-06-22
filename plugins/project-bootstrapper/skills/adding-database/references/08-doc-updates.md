# Documentation Updates for D1 / Drizzle

Use this reference alongside [documentation-updates.md](../../../shared/references/documentation-updates.md) for the D1-specific content to add during step 8.

## Stack addition

`Drizzle ORM, Cloudflare D1`

## Structure additions

- `app/db/` — schema.ts, data-access.ts, daos/, queries/
- `app/services/`
- `db/migrations/`

## Data model link

Add `See [data-model.md](data-model.md)` in the architecture Data Model section.

## New convention: `docs/conventions/data-access.md`

Seed from [data-access-architecture.md](../../../shared/references/data-access-architecture.md). Include:

- DAO interface contract — one DAO per table, type ownership (`<Entity>Record`, `Create<Entity>`, `Update<Entity>`, `<Entity>Filters`), `getAll()` for filtered access.
- `drizzle-zod` validation schema co-location — record, create, and update schemas live in the DAO file, not in separate validation files.
- Service atomic write boundaries using `db.batch()`.
- When to create a service: multiple tables, atomic writes, multiple DAOs, business workflow, custom SQL, aggregations.
- Relation queries for cross-table reads — create a Query in `app/db/queries/<parent>-<child>.query.ts` implementing `RelationQuery<CompositeType, Filters>` from `~/db/data-access` with read-only `get()` and `getAll()` methods, using Drizzle's relational API `db.query.*` and `db.batch()` for items + count. Composite type naming: `<Parent>With<Child>`. Services call Queries for joined data — they never import schema tables or write raw Drizzle queries.
- Schema requires `relations()` declarations for tables with foreign keys.
- Dependency graph: Routes → Services → Queries / DAOs → Database.

**Anti-patterns:**

- No custom public query methods on DAOs.
- No DAO-to-DAO imports.
- No business logic in DAOs.
- No raw joins in services — use a Query.
- No write methods on Queries.
- No query-builder joins in Queries — use the relational API.
- No `Promise.all` for D1 queries — D1 is SQLite; all queries run sequentially over a single connection, so `Promise.all` adds overhead without parallelism. Use sequential `await` instead.
- No looped individual queries for batch operations — use a single query with `inArray()` (e.g. `db.delete(table).where(inArray(table.id, ids))`).
- No `db.transaction()` on D1 — D1 does not support interactive SQL transactions; `db.transaction()` throws at runtime. Use `db.batch()` for atomic multi-statement writes, which executes sequentially and rolls back on failure.
- No conditional reads between `db.batch()` statements — all queries are declared upfront; read first, then batch the writes.

## New convention: `docs/conventions/testing.md`

Seed from [testing-conventions.md](../../../shared/references/testing-conventions.md). Include: directory structure, test type inference, `applyMigrations`/`getTestDb` import patterns, component test patterns, and layer-specific testing guidance.

## README additions

- D1 setup instructions.
- Required environment variables: `CLOUDFLARE_ACCOUNT_ID`, `CLOUDFLARE_DATABASE_ID`, `CLOUDFLARE_D1_TOKEN`.
- Migration commands: `pnpm db:generate`, `pnpm db:migrate`, `pnpm db:local:migrate`.

## AGENTS.md additions

- Database-specific instructions.
- `docs/data-model.md` reference in the Project Documentation section.
- `pnpm test` in the verification commands list.
