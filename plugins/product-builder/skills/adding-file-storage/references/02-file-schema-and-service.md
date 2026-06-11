# 02 - File Schema And Service

## Steps

1. Update `app/db/schema.ts`.

Preserve existing tables and exports. Add the `files` table, then ensure the
exported `schema` object includes every table.

```ts
import { integer, sqliteTable, text } from "drizzle-orm/sqlite-core";

export const files = sqliteTable("files", {
  id: integer("id").primaryKey({ autoIncrement: true }),
  key: text("key").notNull().unique(),
  filename: text("filename").notNull(),
  contentType: text("content_type").notNull(),
  size: integer("size").notNull(),
  createdAt: integer("created_at", { mode: "timestamp" })
    .notNull()
    .$defaultFn(() => new Date()),
});

export const schema = {
  files,
};
```

If `schema` already exists, add `files` to it instead of replacing it.

2. Create `app/services/file.service.ts`.

Use the repository's existing import style. Keep the service server-only; do not
import it from client components.

```ts
import { desc, eq } from "drizzle-orm";
import type { DrizzleD1Database } from "drizzle-orm/d1";

import { files, type schema } from "~/db/schema";

export class FilesService {
  constructor(
    private readonly db: DrizzleD1Database<typeof schema>,
    private readonly bucket: R2Bucket,
  ) {}

  async list() {
    return this.db.select().from(files).orderBy(desc(files.createdAt));
  }

  async upload(file: File) {
    const key = `${Date.now()}-${file.name}`;
    const contentType = file.type || "application/octet-stream";

    await this.bucket.put(key, await file.arrayBuffer(), {
      httpMetadata: { contentType },
    });

    try {
      const [record] = await this.db
        .insert(files)
        .values({
          key,
          filename: file.name,
          contentType,
          size: file.size,
        })
        .returning();

      return record;
    } catch (error) {
      await this.bucket.delete(key);
      throw error;
    }
  }

  async remove(id: number) {
    const [file] = await this.db.select().from(files).where(eq(files.id, id));

    if (!file) {
      return;
    }

    await this.db.delete(files).where(eq(files.id, id));
    await this.bucket.delete(file.key);
  }
}
```

## Implementation Notes

- `FilesService` owns both R2 and D1 operations for files. It does not use a
  separate DAO because every persistence call is paired with a corresponding R2
  call. This is an intentional exception to the one-DAO-per-table rule in
  `05-data-access-architecture.md`.
- Keep object keys unique. A timestamp prefix is acceptable for the default
  implementation; use a stronger key only when the project already has a
  random ID helper.
- Use `application/octet-stream` for missing content types.
- If later adding downloads, fetch the metadata row first and use `bucket.get`
  with the stored key.

## Expected Results

- D1 stores queryable file metadata.
- R2 stores file bytes.
- Upload failures do not leave newly uploaded objects without metadata.
- Delete behavior removes both metadata and object storage entries.
