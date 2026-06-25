# Data Access Architecture

## Layers

Data access is split into three layers. Each layer has a single responsibility and a clear boundary.

| Layer | Location | Responsibility |
| --- | --- | --- |
| DAO | `app/db/daos/<entity>.dao.ts` | Single-table CRUD. No joins, no business logic. |
| Query | `app/db/queries/<parent>-<child>.query.ts` | Cross-table reads. Joins and aggregations. Read-only. |
| Service | `app/services/<entity>.service.ts` | Business workflows. Composes DAOs and Queries. Owns transactions. |

Route loaders and actions call Services (or DAOs/Queries directly for simple reads). They never access `db` directly.

## DAO Conventions

A DAO receives a `db` instance in its constructor and exposes standard CRUD methods:

```ts
export class ProjectDao {
  constructor(private db: DrizzleD1Database) {}

  async create(data: NewProject): Promise<Project> { ... }
  async get(id: string): Promise<Project | null> { ... }
  async getAll(filters: ProjectFilters): Promise<{ items: Project[]; total: number }> { ... }
  async update(id: string, data: Partial<NewProject>): Promise<Project> { ... }
  async delete(id: string): Promise<void> { ... }
}
```

- `getAll` always returns `{ items, total }` — never a bare array.
- Filters are typed; never accept raw SQL strings from callers.
- DAOs do not call other DAOs — cross-table work belongs in a Query or Service.

## Query Conventions

A Query is read-only and handles joins across multiple tables:

```ts
export class ProjectMemberQuery {
  constructor(private db: DrizzleD1Database) {}

  async get(projectId: string): Promise<ProjectWithMembers | null> { ... }
  async getAll(filters: ProjectMemberFilters): Promise<{ items: ProjectWithMembers[]; total: number }> { ... }
}
```

- Queries never mutate data.
- Before creating a new Query, check `app/db/queries/` — reuse an existing one if the join is already defined.

## Service Conventions

A Service owns business logic and transactions:

```ts
export class ProjectService {
  constructor(private db: DrizzleD1Database) {}

  async createProject(input: CreateProjectInput): Promise<Project> {
    return this.db.batch([
      // atomic operations
    ]);
  }
}
```

- Services call DAOs and Queries — they do not write raw SQL.
- Transactions (`.batch()`) live in services, never in DAOs or routes.
- Services throw typed errors for known failure cases (not raw strings).

## Known Type Gotchas

### jsonb columns

`createSelectSchema` on a `jsonb` column infers the TypeScript type as `Json`, but Drizzle's `.returning()` resolves the column value to `unknown` at runtime. Cast explicitly at the DAO boundary — do not let `unknown` leak into service or route layers:

```ts
const [row] = await this.db.insert(analysisRecords).values(data).returning();
return row as AnalysisRecord;
```

Apply the same cast to `.update().returning()` and `.select()` results on jsonb columns.
