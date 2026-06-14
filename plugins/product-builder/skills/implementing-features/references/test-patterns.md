# Test Patterns

Test templates for DAOs, Queries, and Services. Each test file lives in a `__tests__/` subdirectory next to the source file.

All integration tests import `getTestDb` from `~/db/__tests__/setup` to get a Drizzle instance backed by a Miniflare D1 database with migrations applied.

## DAO Test

File: `app/db/daos/__tests__/<entity>.dao.test.ts`

```ts
import { describe, expect, it } from 'vitest'

import { getTestDb } from '~/db/__tests__/setup'

import { <Entity>Dao } from '../<entity>.dao'

describe('<Entity>Dao', () => {
  const db = getTestDb()
  const dao = new <Entity>Dao(db)

  it('creates a record', async () => {
    const created = await dao.create({
      // required fields
    })
    expect(created).toBeDefined()
    expect(created.id).toBeDefined()
  })

  it('gets a record by id', async () => {
    const created = await dao.create({ /* fields */ })
    const found = await dao.get(created.id)
    expect(found).toEqual(created)
  })

  it('returns all records', async () => {
    await dao.create({ /* fields */ })
    await dao.create({ /* fields */ })
    const result = await dao.getAll({})
    expect(result.items.length).toBeGreaterThanOrEqual(2)
    expect(result.total).toBeGreaterThanOrEqual(2)
  })

  it('filters records', async () => {
    await dao.create({ /* fields with distinct value */ })
    await dao.create({ /* fields with different value */ })
    const result = await dao.getAll({ /* filter to one */ })
    expect(result.items).toHaveLength(1)
  })

  it('updates a record', async () => {
    const created = await dao.create({ /* fields */ })
    const updated = await dao.update(created.id, { /* changed field */ })
    expect(updated./* changed field */).toBe(/* new value */)
  })

  it('deletes a record', async () => {
    const created = await dao.create({ /* fields */ })
    await dao.delete(created.id)
    const found = await dao.get(created.id)
    expect(found).toBeNull()
  })

  it('deletes many records', async () => {
    const a = await dao.create({ /* fields */ })
    const b = await dao.create({ /* fields */ })
    await dao.deleteMany([a.id, b.id])
    const result = await dao.getAll({})
    expect(result.items).toHaveLength(0)
  })
})
```

Test every standard CRUD method. Add tests for filter combinations that encode business rules — for example, if `getAll` supports filtering by `status`, test each status value.

## Query Test

File: `app/db/queries/__tests__/<parent>-<child>.query.test.ts`

```ts
import { describe, expect, it } from 'vitest'

import { getTestDb } from '~/db/__tests__/setup'
import { <Parent>Dao } from '~/db/daos/<parent>.dao'
import { <Child>Dao } from '~/db/daos/<child>.dao'

import { <Parent><Child>Query } from '../<parent>-<child>.query'

describe('<Parent><Child>Query', () => {
  const db = getTestDb()
  const parentDao = new <Parent>Dao(db)
  const childDao = new <Child>Dao(db)
  const query = new <Parent><Child>Query(db)

  it('gets a record with relations', async () => {
    const parent = await parentDao.create({ /* fields */ })
    await childDao.create({ parentId: parent.id, /* fields */ })

    const result = await query.get(parent.id)
    expect(result).toBeDefined()
    expect(result!.<children>).toHaveLength(1)
  })

  it('returns all with count', async () => {
    const parent = await parentDao.create({ /* fields */ })
    await childDao.create({ parentId: parent.id, /* fields */ })

    const result = await query.getAll({})
    expect(result.items.length).toBeGreaterThanOrEqual(1)
    expect(result.total).toBeGreaterThanOrEqual(1)
    expect(result.items[0].<children>).toBeDefined()
  })

  it('filters results', async () => {
    const p1 = await parentDao.create({ /* fields with value A */ })
    const p2 = await parentDao.create({ /* fields with value B */ })
    await childDao.create({ parentId: p1.id, /* fields */ })
    await childDao.create({ parentId: p2.id, /* fields */ })

    const result = await query.getAll({ /* filter to p1 */ })
    expect(result.items).toHaveLength(1)
  })
})
```

Seed data using DAOs, not raw SQL. Verify that composite types include nested relations and that `getAll` returns both `items` and `total`.

## Service Test

File: `app/services/__tests__/<entity>.service.test.ts`

```ts
import { describe, expect, it } from 'vitest'

import { getTestDb } from '~/db/__tests__/setup'
import { <Entity>Dao } from '~/db/daos/<entity>.dao'
// Import other DAOs and Queries the service composes

import { <Entity>Service } from '../<entity>.service'

describe('<Entity>Service', () => {
  const db = getTestDb()
  const dao = new <Entity>Dao(db)
  // Instantiate other DAOs and Queries
  const service = new <Entity>Service(db)

  it('performs the workflow', async () => {
    // Call the service method
    const result = await service.<workflowMethod>({ /* input */ })

    // Assert the return value
    expect(result).toBeDefined()

    // Assert state via DAOs — not by inspecting service internals
    const record = await dao.get(result.id)
    expect(record).toBeDefined()
    expect(record!./* field */).toBe(/* expected value */)
  })

  it('handles error cases', async () => {
    await expect(
      service.<workflowMethod>({ /* invalid input */ })
    ).rejects.toThrow()
  })
})
```

Test each business workflow method. Assert state by reading back through DAOs after the service call. Focus on the happy path and meaningful error states — do not test Drizzle internals or `db.batch()` mechanics.
