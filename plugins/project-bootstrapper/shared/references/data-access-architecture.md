# Data Access Architecture

## Contents

- Purpose
- Directory Structure
- DAO Layer (interface, typing, CRUD, filters, validation)
- Query Layer (relation queries, composite types, relational API)
- Service Layer (transaction boundaries, composition, auth-scoped access)
- Dependency Rules
- Enforcement Rules

## Purpose

Use this reference when adding or changing application tables, DAOs, queries, services, transactions, data validation schemas, or data access workflows in a project.

The data access architecture is designed for React Router v7 applications using Drizzle ORM and `drizzle-zod`. The patterns are consistent across deployment targets; the key differences are noted in the **Query Execution** and **Atomic Writes** sections below.

**D1 (Cloudflare target):** SQLite-based, single connection, no interactive transactions — use `db.batch()` for atomic writes; do not use `Promise.all` for queries.
**Postgres (Docker/Postgres target):** Full Postgres with connection pool — use `db.transaction()` for atomic writes; `Promise.all` is fine for independent queries.

The goals are:

- Consistent data access patterns.
- Strong typing throughout the application.
- Clear separation between persistence and business logic.
- Predictable transaction boundaries.
- Minimal abstraction over Drizzle.

## Directory Structure

```txt
app/
├── db/
│   ├── schema.ts
│   ├── data-access.ts
│   ├── daos/
│   │   ├── user.dao.ts
│   │   ├── organization.dao.ts
│   │   └── ...
│   └── queries/
│       ├── order-line-items.query.ts
│       └── ...
├── services/
│   ├── user.service.ts
│   ├── organization.service.ts
│   └── ...
└── routes/
```

Keep Drizzle table definitions, the exported Drizzle `schema` object, and `relations()` declarations in `app/db/schema.ts`. Keep DAO-specific `drizzle-zod` validation schemas in the DAO file that owns the entity.

## Schema Relations

Tables with foreign keys must declare `relations()` in `app/db/schema.ts`. This enables Drizzle's relational query API, which the Query layer depends on.

```ts
export const ordersRelations = relations(orders, ({ many }) => ({
  lineItems: many(lineItems),
}));

export const lineItemsRelations = relations(lineItems, ({ one }) => ({
  order: one(orders, {
    fields: [lineItems.orderId],
    references: [orders.id],
  }),
}));
```

Always declare both sides of the relationship (parent `many` and child `one`).

## DAO Layer

DAOs provide table-scoped persistence operations. Each DAO maps to exactly one database table and is responsible only for CRUD operations and filtered list access.

DAOs are intentionally simple and must not contain business logic.

### DAO Location

Every table that needs application-level persistence access must have exactly one DAO in:

```txt
app/db/daos/
```

One table equals one DAO file:

```txt
users         -> user.dao.ts
organizations -> organization.dao.ts
projects      -> project.dao.ts
```

### DAO Constructor

Each DAO accepts a typed Drizzle database instance. The exact type depends on the deployment target:
- **D1 (Cloudflare):** `DrizzleD1Database<typeof schema>`
- **Postgres (Docker/Postgres):** `NodePgDatabase<typeof schema>` (from `drizzle-orm/node-postgres`)

```ts
constructor(private readonly db: DrizzleD1Database<typeof schema>) {}
// or for Postgres:
constructor(private readonly db: NodePgDatabase<typeof schema>) {}
```

This allows DAOs to be instantiated with either the request database client or a transaction client.

### Shared Data Access Interfaces

Create the shared data access interfaces in `app/db/data-access.ts` when the first DAO is added. This file contains both the `Dao` and `RelationQuery` interfaces.

```ts
export interface GetAllOptions<F = object> {
  filters?: F;
  limit?: number;
  offset?: number;
}

export interface GetAllResult<T> {
  items: T[];
  total: number;
}

export interface Dao<
  T,
  C = Omit<T, "id" | "createdAt" | "updatedAt">,
  U = Partial<Omit<T, "id" | "createdAt" | "updatedAt">>,
  F = object,
> {
  create(attrs: C): Promise<T>;
  get(id: string): Promise<T | null>;
  getAll(opts?: GetAllOptions<F>): Promise<GetAllResult<T>>;
  update(id: string, attrs: U): Promise<T>;
  delete(id: string): Promise<void>;
  deleteMany(ids: string[]): Promise<void>;
}

export interface RelationQuery<T, F = object> {
  get(id: string): Promise<T | null>;
  getAll(opts?: GetAllOptions<F>): Promise<GetAllResult<T>>;
}
```

### Allowed Public Methods

DAOs may expose only the shared DAO interface methods:

```ts
create(attrs);
get(id);
getAll(opts);
update(id, attrs);
delete id;
deleteMany(ids);
```

Do not add public custom query methods such as:

```ts
getByEmail();
findBySlug();
findActive();
listPending();
getOrganizationUsers();
archiveExpired();
```

### Querying Convention

All list-style queries must use `getAll(opts?: GetAllOptions<Filters>)`.

```ts
export interface UserFilters {
  organizationId?: string;
  status?: string;
}
```

```ts
await userDao.getAll({
  filters: {
    organizationId,
    status: "active",
  },
});
```

Represent all filtering through typed filter objects. Do not add custom public query methods for filtered reads.

### Type Ownership

The DAO owns the canonical domain types for its entity. Each DAO exports:

```txt
<Entity>Record
Create<Entity>
Update<Entity>
<Entity>Filters
```

For example:

```txt
UserRecord
CreateUser
UpdateUser
UserFilters
```

Other modules must import these types from the DAO instead of redefining equivalent shapes.

### Validation Schemas

Define DAO-specific `drizzle-zod` schemas in the same file as the DAO. Do not create separate validation schema files for DAO-owned entity shapes.

```ts
import { createInsertSchema, createSelectSchema } from "drizzle-zod";
```

Record schemas represent full rows returned by the database.

```ts
export const userRecordSchema = createSelectSchema(users);
```

Create schemas represent valid create input. Omit auto-generated fields.

```ts
export const createUserSchema = createInsertSchema(users).omit({
  id: true,
  createdAt: true,
  updatedAt: true,
});
```

Update schemas expose only mutable fields and make them optional.

```ts
export const updateUserSchema = createInsertSchema(users)
  .pick({
    name: true,
    email: true,
    status: true,
  })
  .partial();
```

### Query Execution

**D1 (Cloudflare target):** D1 is backed by SQLite with a single connection. All queries execute sequentially. There is no connection pool and no parallel query execution.

Do not use `Promise.all` to run multiple D1 queries concurrently — the queries still run one at a time and the promise overhead adds complexity without benefit.

```ts
// wrong — false parallelism on a single-connection database
const [items, [{ value: total }]] = await Promise.all([
  db.select().from(table).where(where).limit(limit).offset(offset),
  db.select({ value: count() }).from(table).where(where),
]);
```

Use sequential awaits instead:

```ts
// correct — explicit about the actual execution order
const items = await db
  .select()
  .from(table)
  .where(where)
  .limit(limit)
  .offset(offset);
const [{ value: total }] = await db
  .select({ value: count() })
  .from(table)
  .where(where);
```

**Postgres (Docker/Postgres target):** Postgres uses a connection pool. `Promise.all` is safe and beneficial for independent queries.

```ts
// correct for Postgres — runs in parallel
const [items, [{ value: total }]] = await Promise.all([
  db.select().from(table).where(where).limit(limit).offset(offset),
  db.select({ value: count() }).from(table).where(where),
]);
```

For batch operations on both targets, use a single query with `inArray()` instead of looping individual queries:

```ts
// wrong — N+1 deletes
const results = await Promise.all(ids.map((id) => this.delete(id)));

// correct — single DELETE statement
const result = await db.delete(table).where(inArray(table.id, ids)).returning();
```

### `db.transaction()` on D1

D1 does not support interactive SQL transactions. `db.transaction()` will throw at runtime. Use `db.batch()` instead — it provides atomicity (all-or-nothing) with sequential execution and rollback on failure.

```ts
// wrong — runtime error on D1
await db.transaction(async (tx) => {
  await tx.delete(entries).where(eq(entries.planId, planId));
  await tx.insert(entries).values({ id, planId, recipeId });
});
```

```ts
// correct for D1 — atomic batch via D1 Batch API
await db.batch([
  db.delete(entries).where(eq(entries.planId, planId)),
  db.insert(entries).values({ id, planId, recipeId }),
]);
```

**Postgres (Docker/Postgres target):** Standard `db.transaction()` works as expected. You may also use `db.batch()` if preferred.

```ts
// correct for Postgres
await db.transaction(async (tx) => {
  await tx.delete(entries).where(eq(entries.planId, planId));
  await tx.insert(entries).values({ id, planId, recipeId });
});
```

### DAO Restrictions

DAOs must not:

- Import other DAOs.
- Import services.
- Import queries.
- Coordinate multiple tables.
- Implement business workflows.
- Contain custom joins.
- Contain reporting queries.
- Contain workflow-specific SQL.
- Contain application-specific logic.

A DAO should be understandable without knowing the business workflow that uses it.

## Query Layer

Queries provide read-only access to data that spans multiple related tables. Each Query uses Drizzle's relational API to return composite types with nested relations, avoiding raw joins and manual row collapsing.

Queries are intentionally read-only and must not contain business logic or write operations. Writes always go through entity DAOs (directly or via `db.batch()` for atomic operations).

### Query Location

```txt
app/db/queries/
```

File naming follows the `<parent>-<child>.query.ts` convention:

```txt
order + line items  -> order-line-items.query.ts
post + author       -> post-author.query.ts
project + members   -> project-members.query.ts
```

### Query Constructor

Each Query accepts a typed Drizzle database instance, same type as DAOs (target-dependent).

```ts
constructor(private readonly db: DrizzleD1Database<typeof schema>) {}
// or for Postgres:
constructor(private readonly db: NodePgDatabase<typeof schema>) {}
```

### Query Interface

Queries implement the `RelationQuery` interface from `app/db/data-access.ts`:

```ts
export interface RelationQuery<T, F = object> {
  get(id: string): Promise<T | null>;
  getAll(opts?: GetAllOptions<F>): Promise<GetAllResult<T>>;
}
```

Only two methods: `get()` for a single composite record by parent ID, and `getAll()` for filtered lists with pagination.

### Composite Types

Each Query exports a composite record type that embeds related entity records. The naming convention is `<Parent>With<Child>`:

```ts
export interface OrderWithLineItems {
  id: string;
  userId: string;
  status: string;
  lineItems: LineItemRecord[];
  createdAt: Date;
  updatedAt: Date;
}
```

Import child record types from their entity DAOs. Do not redefine them.

### Typed Filters

Each Query exports a filters interface for its `getAll()` method:

```ts
export interface OrderWithLineItemsFilters {
  userId?: string;
  status?: string;
}
```

### Using the Relational API

Queries use Drizzle's relational API (`db.query.*`) exclusively. Do not use query builder joins (`db.select().from().innerJoin()`) in Queries — that is the pattern Queries replace.

The `get()` method uses `findFirst` with a `with` clause:

```ts
async get(id: string): Promise<OrderWithLineItems | null> {
  return (
    (await this.db.query.orders.findFirst({
      where: eq(orders.id, id),
      with: { lineItems: true },
    })) ?? null
  );
}
```

### `db.batch()` for `getAll()`

The `getAll()` method uses `db.batch()` to fetch items and count in a single round trip:

```ts
async getAll(
  opts?: GetAllOptions<OrderWithLineItemsFilters>
): Promise<GetAllResult<OrderWithLineItems>> {
  const { filters, limit, offset } = opts ?? {};

  const conditions = [];
  if (filters?.userId) conditions.push(eq(orders.userId, filters.userId));
  if (filters?.status) conditions.push(eq(orders.status, filters.status));
  const where = conditions.length > 0 ? and(...conditions) : undefined;

  const [items, [{ value: total }]] = await this.db.batch([
    this.db.query.orders.findMany({
      where,
      with: { lineItems: true },
      limit: limit ?? 100,
      offset: offset ?? 0,
    }),
    this.db.select({ value: count() }).from(orders).where(where),
  ]);

  return { items, total };
}
```

`db.batch()` sends both queries in a single round trip to D1. This is the correct pattern for Queries — it is not `Promise.all` (which adds overhead without parallelism on D1), and it is not two sequential awaits (which makes two round trips).

### When To Create A Query

Create a Query when a service needs to read data from two or more related tables in a single query.

Do not create a Query for:

- Single-table reads — use the entity DAO's `getAll()`.
- Write operations — use entity DAOs, with `db.batch()` for atomicity.
- Business logic that touches multiple tables — that belongs in a service.

### Query Restrictions

Queries must not:

- Import DAOs or services.
- Contain write methods (`create`, `update`, `delete`).
- Contain business logic.
- Use query builder joins (`db.select().from().innerJoin()`) — use the relational API.
- Add methods beyond `get()` and `getAll()`.

### Full Query Example

```ts
// app/db/queries/order-line-items.query.ts

import { and, count, eq } from "drizzle-orm";
import type { DrizzleD1Database } from "drizzle-orm/d1";

import type {
  GetAllOptions,
  GetAllResult,
  RelationQuery,
} from "~/db/data-access";
import type { LineItemRecord } from "~/db/daos/line-item.dao";
import { orders } from "~/db/schema";
import type { schema } from "~/db/schema";

export interface OrderWithLineItems {
  id: string;
  userId: string;
  status: string;
  lineItems: LineItemRecord[];
  createdAt: Date;
  updatedAt: Date;
}

export interface OrderWithLineItemsFilters {
  userId?: string;
  status?: string;
}

export class OrderLineItemsQuery implements RelationQuery<
  OrderWithLineItems,
  OrderWithLineItemsFilters
> {
  constructor(private readonly db: DrizzleD1Database<typeof schema>) {}

  async get(id: string): Promise<OrderWithLineItems | null> {
    return (
      (await this.db.query.orders.findFirst({
        where: eq(orders.id, id),
        with: { lineItems: true },
      })) ?? null
    );
  }

  async getAll(
    opts?: GetAllOptions<OrderWithLineItemsFilters>,
  ): Promise<GetAllResult<OrderWithLineItems>> {
    const { filters, limit, offset } = opts ?? {};

    const conditions = [];
    if (filters?.userId) conditions.push(eq(orders.userId, filters.userId));
    if (filters?.status) conditions.push(eq(orders.status, filters.status));
    const where = conditions.length > 0 ? and(...conditions) : undefined;

    const [items, [{ value: total }]] = await this.db.batch([
      this.db.query.orders.findMany({
        where,
        with: { lineItems: true },
        limit: limit ?? 100,
        offset: offset ?? 0,
      }),
      this.db.select({ value: count() }).from(orders).where(where),
    ]);

    return { items, total };
  }
}
```

## Service Layer

Services coordinate business workflows. Use services for operations that span multiple tables, require atomic writes, or represent domain behavior.

Services compose DAOs and Queries. Services do not import schema tables or build Drizzle queries directly.

### Service Location

```txt
app/services/
```

### When To Create A Service

Use a service when an operation:

- Touches multiple tables for writes.
- Requires atomic writes (`db.batch()`).
- Coordinates multiple DAOs.
- Represents a business workflow.
- Performs upserts, bulk imports, or aggregations.

Examples:

```txt
Create user + profile
Create order + order items
Invite organization member
Delete project and dependencies
Provision workspace
```

### How Services Use Queries

Services delegate cross-table reads to Queries. They do not import schema tables or write raw Drizzle join queries.

```ts
// order.service.ts — before (raw Drizzle in service)
import { orders, lineItems } from "~/db/schema";

export async function getOrdersWithItems(db, userId) {
  return db
    .select()
    .from(orders)
    .innerJoin(lineItems, eq(orders.id, lineItems.orderId))
    .where(eq(orders.userId, userId));
}

// order.service.ts — after (delegates to Query)
import { OrderLineItemsQuery } from "~/db/queries/order-line-items.query";

export async function getOrdersWithItems(db, userId) {
  const query = new OrderLineItemsQuery(db);
  return query.getAll({ filters: { userId } });
}
```

### Service Atomic Writes

**D1 (Cloudflare target):** D1 does not support interactive SQL transactions (`db.transaction()` will fail at runtime). For atomic multi-statement writes, use Drizzle's `db.batch()` API.

Each statement in the batch executes and commits sequentially. If any statement fails, the entire batch rolls back.

```ts
// Atomic delete-then-insert via Batch API (D1)
await db.batch([
  db.delete(entries).where(eq(entries.planId, planId)),
  db.insert(entries).values({ id, planId, recipeId }),
]);
```

**Postgres (Docker/Postgres target):** Use `db.transaction()` for atomic writes. `db.batch()` also works but `db.transaction()` is idiomatic for Postgres.

```ts
// Atomic delete-then-insert (Postgres)
await db.transaction(async (tx) => {
  await tx.delete(entries).where(eq(entries.planId, planId));
  await tx.insert(entries).values({ id, planId, recipeId });
});
```

`db.batch()` accepts an array of prepared query builders: `db.select()`, `db.insert()`, `db.update()`, `db.delete()`, `db.query.<table>.findMany()`, `db.query.<table>.findFirst()`.

The return type is a tuple matching each query's result type:

```ts
const [deleted, inserted] = await db.batch([
  db.delete(entries).where(eq(entries.planId, planId)).returning(),
  db.insert(entries).values({ id, planId, recipeId }).returning(),
]);
// deleted: { id: string; ... }[]
// inserted: { id: string; ... }[]
```

Use `db.batch()` when:

- Multiple tables are modified.
- Multiple related records are created.
- Multiple related records are deleted.
- Data consistency must be guaranteed.

`db.batch()` is unnecessary for:

- Single-table CRUD operations.
- Read-only operations (except Query `getAll()` which batches items + count).
- Simple lookups.

`db.batch()` declares all queries upfront — you cannot read a result mid-batch to decide the next query. If you need conditional logic between writes, read first, then batch the writes:

```ts
const existing = await db
  .select()
  .from(entries)
  .where(eq(entries.planId, planId));

if (existing.length > 0) {
  await db.batch([
    db.delete(entries).where(eq(entries.planId, planId)),
    db.insert(entries).values({ id, planId, recipeId }),
  ]);
} else {
  await db.insert(entries).values({ id, planId, recipeId });
}
```

When in doubt, prefer `db.batch()` for multi-write workflows.

## Specialized SQL

The DAO and Query layers intentionally support only standard operations (CRUD for DAOs, relational reads for Queries).

Implement operations such as these in services:

- Upserts.
- Bulk imports.
- Aggregations.
- Analytics queries.
- Search queries.
- Queue processing.
- Reporting.

## Dependency Rules

Allowed:

```txt
Routes
  -> Services
  -> Queries
  -> DAOs
  -> Database
```

Not allowed:

```txt
DAO -> DAO
DAO -> Query
DAO -> Service
Query -> DAO
Query -> Service
Service -> Route
```

Services may compose multiple DAOs and Queries. DAOs and Queries must remain independent.

## Enforcement Rules

A DAO is valid only if:

1. It lives in `app/db/daos/`.
2. It maps to exactly one table.
3. It implements `Dao`.
4. It exposes only DAO interface methods.
5. It uses `getAll()` for filtered list access.
6. It exports canonical entity types.
7. It co-locates `drizzle-zod` validation schemas with the DAO.
8. It contains no business logic.
9. It contains no cross-table workflows.
10. It contains no workflow-specific SQL.
11. For **D1 target**: does not use `Promise.all` for D1 queries. For **Postgres target**: `Promise.all` is allowed for independent queries.
12. It uses `inArray()` for batch operations instead of looping individual queries.

A Query is valid only if:

1. It lives in `app/db/queries/`.
2. It joins two or more related tables using Drizzle's relational API (`db.query.*`).
3. It implements `RelationQuery`.
4. It exposes only `get()` and `getAll()` — no write methods.
5. It exports a composite type following the `<Parent>With<Child>` naming.
6. It uses `db.batch()` in `getAll()` for items + count in one round trip.
7. It contains no business logic.
8. It does not import DAOs or services.

A service is valid only if:

1. It lives in `app/services/`.
2. It owns business workflows.
3. For **D1 target**: uses `db.batch()` for atomic writes (not `db.transaction()`, which fails on D1). For **Postgres target**: uses `db.transaction()` or `db.batch()` for atomic writes.
4. It may compose multiple DAOs and Queries.
5. It does not import schema tables or build Drizzle queries directly.
6. It does not perform joins — it uses a Query instead.
