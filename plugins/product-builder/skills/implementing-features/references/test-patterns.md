# Test Patterns

Test templates for DAOs, Queries, Services, and Route Components.

Integration tests (DAOs, Queries, Services) live in `tests/integration/`, mirroring the `app/` structure. Unit and component tests live in `tests/unit/`, also mirroring the `app/` structure.

Integration tests import `getTestDb` from `db-test-utils.ts` to get a Drizzle instance backed by a Miniflare D1 database with migrations applied. Unit and component tests import source via the `~/` path alias.

## DAO Test

File: `tests/integration/db/daos/<entity>.dao.test.ts`

```ts
import { describe, expect, it } from 'vitest'

import { <Entity>Dao } from '~/db/daos/<entity>.dao'

import { getTestDb } from '../../db-test-utils'

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

File: `tests/integration/db/queries/<parent>-<child>.query.test.ts`

```ts
import { describe, expect, it } from 'vitest'

import { <Parent>Dao } from '~/db/daos/<parent>.dao'
import { <Child>Dao } from '~/db/daos/<child>.dao'
import { <Parent><Child>Query } from '~/db/queries/<parent>-<child>.query'

import { getTestDb } from '../../db-test-utils'

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

File: `tests/integration/services/<entity>.service.test.ts`

```ts
import { describe, expect, it } from 'vitest'

import { <Entity>Dao } from '~/db/daos/<entity>.dao'
// Import other DAOs and Queries the service composes
import { <Entity>Service } from '~/services/<entity>.service'

import { getTestDb } from '../db-test-utils'

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

## Route Component Test

File: `tests/unit/routes/<route>.test.tsx`

```tsx
import { page } from '@vitest/browser/context'
import { describe, expect, it } from 'vitest'
import { createRoutesStub } from 'react-router'
import { render } from 'vitest-browser-react'

import <Route> from '~/routes/<route>'

function render<Route>(loaderData) {
  const Stub = createRoutesStub([
    {
      path: '/<path>',
      Component: <Route>,
      loader: () => loaderData,
    },
  ])
  return render(<Stub initialEntries={['/<path>']} />)
}

describe('<Route>', () => {
  it('renders with loader data', async () => {
    await render<Route>({ /* loader data shape */ })

    await expect.element(page.getByText('Expected text')).toBeInTheDocument()
  })

  it('displays empty state', async () => {
    await render<Route>({ items: [] })

    await expect.element(page.getByText('No items')).toBeInTheDocument()
  })
})
```

### Testing action errors with Conform forms

Stub the `action` to return a Conform `SubmissionResult`. The `initialValue` field must be present or Conform silently ignores the result:

```tsx
function render<Route>WithAction(actionFn: () => unknown) {
  const Stub = createRoutesStub([
    {
      path: '/<path>',
      Component: <Route>,
      action: actionFn,
    },
  ])
  return render(<Stub initialEntries={['/<path>']} />)
}

it('shows form-level error from action', async () => {
  await render<Route>WithAction(() => ({
    status: 'error',
    initialValue: { email: 'test@example.com', password: 'wrongpassword' },
    error: { '': ['Incorrect username or password'] },
  }))

  await page.getByLabelText('Email').fill('test@example.com')
  await page.getByLabelText('Password').fill('wrongpassword')
  await page.getByRole('button', { name: /Log in/ }).click()

  await expect.element(page.getByRole('alert')).toBeInTheDocument()
})
```

The `error` key `''` (empty string) represents form-level errors — field-level errors use the field name as key.

### Testing with hydrationData

For forms where required inputs cannot be filled programmatically (e.g., `type="file"`), use `hydrationData` to pre-populate `actionData`:

```tsx
render(
  <Stub
    initialEntries={["/upload"]}
    hydrationData={{ actionData: { upload: { error: "message" } } }}
  />,
);
```

### Querying and assertions

Use `page` from `@vitest/browser/context` for Playwright locators (strict by default) and `expect.element()` for async assertions:

```tsx
// Locators
page.getByText("Welcome");
page.getByLabelText("Password", { exact: true });
page.getByRole("button", { name: /Upload/ }).first();
page.getByPlaceholder("e.g., La Trattoria");

// Assertions — always async
await expect.element(page.getByText("Welcome")).toBeInTheDocument();
await expect.element(page.getByRole("alert")).not.toBeInTheDocument();
await expect
  .element(page.getByText("Sign up"))
  .toHaveAttribute("href", expect.stringContaining("redirect"));
```

All test functions must be `async`. Cleanup is automatic — `vitest-browser-react` handles it between tests.
