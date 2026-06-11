# 05 - Data Access Architecture

## Purpose

Use this reference when adding or changing application tables, DAOs, services, transactions, data validation schemas, or data access workflows in a Product Builder project.

The data access architecture is designed for React Router v7 applications using Cloudflare D1, Drizzle ORM, and `drizzle-zod`.

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
│   ├── dao.ts
│   └── daos/
│       ├── user.dao.ts
│       ├── organization.dao.ts
│       └── ...
├── services/
│   ├── user.service.ts
│   ├── organization.service.ts
│   └── ...
└── routes/
```

Keep Drizzle table definitions and the exported Drizzle `schema` object in `app/db/schema.ts`. Keep DAO-specific `drizzle-zod` validation schemas in the DAO file that owns the entity.

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

Each DAO accepts a typed Drizzle database instance.

```ts
constructor(private readonly db: DrizzleD1Database<typeof schema>) {}
```

This allows DAOs to be instantiated with either the request database client or a transaction client.

### Shared DAO Interface

Create the shared DAO interface in `app/db/dao.ts` when the first DAO is added.

```ts
export interface GetAllOptions<F = object> {
  filters?: F;
  limit?: number;
  offset?: number;
}

export interface GetAllResult<T> {
  items: T[];
  total?: number;
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

### DAO Restrictions

DAOs must not:

- Import other DAOs.
- Import services.
- Coordinate multiple tables.
- Implement business workflows.
- Contain custom joins.
- Contain reporting queries.
- Contain workflow-specific SQL.
- Contain application-specific logic.

A DAO should be understandable without knowing the business workflow that uses it.

## Service Layer

Services coordinate business workflows. Use services for operations that span multiple tables, require transactions, or represent domain behavior.

Services compose DAOs.

### Service Location

```txt
app/services/
```

### When To Create A Service

Use a service when an operation:

- Touches multiple tables.
- Requires a transaction.
- Coordinates multiple DAOs.
- Represents a business workflow.
- Requires custom SQL.
- Performs joins or aggregations.

Examples:

```txt
Create user + profile
Create order + order items
Invite organization member
Delete project and dependencies
Provision workspace
```

### Transaction Convention

Services own transaction boundaries. If a workflow performs multiple related writes, execute it inside a transaction.

```ts
export async function createUserWithProfile(
  db: DrizzleD1Database<typeof schema>,
  attrs: CreateUserWithProfile,
) {
  return db.transaction(async (tx) => {
    const userDao = new UserDao(tx);
    const profileDao = new ProfileDao(tx);

    const user = await userDao.create(attrs.user);

    const profile = await profileDao.create({
      userId: user.id,
      ...attrs.profile,
    });

    return { user, profile };
  });
}
```

Use a transaction when:

- Multiple tables are modified.
- Multiple related records are created.
- Multiple related records are deleted.
- Data consistency must be guaranteed.

A transaction is generally unnecessary for:

- Single-table CRUD operations.
- Read-only operations.
- Simple lookups.

When in doubt, prefer a transaction for multi-write workflows.

## Cross-Table Reads

Cross-table reads do not belong in DAOs. Create dedicated query functions or service functions instead.

```ts
export async function getProjectDetails(
  db: DrizzleD1Database<typeof schema>,
  projectId: string,
) {
  return db
    .select()
    .from(projects)
    .leftJoin(organizations, eq(projects.organizationId, organizations.id))
    .where(eq(projects.id, projectId));
}
```

These functions are not DAOs and do not need to implement the DAO interface.

## Specialized SQL

The DAO layer intentionally supports only standard CRUD operations.

Implement operations such as these in services or dedicated query modules:

- Upserts.
- Bulk imports.
- Complex joins.
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
  -> DAOs
  -> Database
```

Not allowed:

```txt
DAO -> DAO
DAO -> Service
Service -> Route
```

Services may compose multiple DAOs. DAOs must remain independent.

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

A service is valid only if:

1. It lives in `app/services/`.
2. It owns business workflows.
3. It owns transaction boundaries.
4. It may compose multiple DAOs.
5. It may execute custom Drizzle queries.
6. It may coordinate multiple tables.
