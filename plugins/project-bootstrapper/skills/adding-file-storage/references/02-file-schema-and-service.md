# 02 - File Schema And Service

## Contents

- Steps (schema, service, rollback on failure)
- Implementation Notes
- Expected Results

## Steps

1. Update `app/db/schema.ts`.

Preserve existing tables and exports. Add the `files` table. Use the correct column types for the target — SQLite for Cloudflare D1, Postgres for Docker/Postgres.

**Cloudflare target (SQLite):**

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
```

**Docker/Postgres target:**

```ts
import { pgTable, sql, text, timestamp, uuid } from "drizzle-orm/pg-core";
import { integer } from "drizzle-orm/pg-core";

export const files = pgTable("files", {
  id: uuid("id")
    .default(sql`pg_catalog.gen_random_uuid()`)
    .primaryKey(),
  key: text("key").notNull().unique(),
  filename: text("filename").notNull(),
  contentType: text("content_type").notNull(),
  size: integer("size").notNull(),
  createdAt: timestamp("created_at").notNull().defaultNow(),
});
```

Ensure the exported `schema` object includes `files` alongside existing tables.

2. Create `app/services/file.service.ts`.

Use the repository's existing import style. Keep the service server-only; do not import it from client components. The constructor signature differs by target.

**Cloudflare target (R2):**

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
        .values({ key, filename: file.name, contentType, size: file.size })
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

**Docker/Postgres target (MinIO via S3):**

```ts
import { desc, eq } from "drizzle-orm";
import type { NodePgDatabase } from "drizzle-orm/node-postgres";
import {
  DeleteObjectCommand,
  PutObjectCommand,
  type S3Client,
} from "@aws-sdk/client-s3";

import { files, type schema } from "~/db/schema";

export class FilesService {
  constructor(
    private readonly db: NodePgDatabase<typeof schema>,
    private readonly s3: S3Client,
    private readonly bucket: string,
  ) {}

  async list() {
    return this.db.select().from(files).orderBy(desc(files.createdAt));
  }

  async upload(file: File) {
    const key = `${Date.now()}-${file.name}`;
    const contentType = file.type || "application/octet-stream";

    await this.s3.send(
      new PutObjectCommand({
        Bucket: this.bucket,
        Key: key,
        Body: Buffer.from(await file.arrayBuffer()),
        ContentType: contentType,
      }),
    );

    try {
      const [record] = await this.db
        .insert(files)
        .values({ key, filename: file.name, contentType, size: file.size })
        .returning();
      return record;
    } catch (error) {
      await this.s3.send(
        new DeleteObjectCommand({ Bucket: this.bucket, Key: key }),
      );
      throw error;
    }
  }

  async remove(id: string) {
    const [file] = await this.db.select().from(files).where(eq(files.id, id));
    if (!file) {
      return;
    }
    await this.db.delete(files).where(eq(files.id, id));
    await this.s3.send(
      new DeleteObjectCommand({ Bucket: this.bucket, Key: file.key }),
    );
  }
}
```

## Implementation Notes

- `FilesService` owns both object store and database operations for files. It does not use a separate DAO because every persistence call is paired with a corresponding object store call. This is an intentional exception to the one-DAO-per-table rule.
- Keep object keys unique. A timestamp prefix is acceptable for the default implementation.
- Use `application/octet-stream` for missing content types.
- If later adding downloads, fetch the metadata row first and use the stored key to retrieve the object.

## Expected Results

- Database stores queryable file metadata.
- Object store stores file bytes.
- Upload failures do not leave newly uploaded objects without metadata.
- Delete behavior removes both metadata and object storage entries.
