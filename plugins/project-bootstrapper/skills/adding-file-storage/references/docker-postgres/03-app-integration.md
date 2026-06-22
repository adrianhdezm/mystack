# 03 - App Integration (docker-postgres target)

## App context

Update `app/context.ts` to expose `FilesService` alongside the existing context values.

```ts
import { createContext } from 'react-router';
import type { NodePgDatabase } from 'drizzle-orm/node-postgres';
import type { betterAuth } from 'better-auth';
import type { FilesService } from '~/services/file.service';

import { schema } from './db/schema';

export const appContext = createContext<{
  env: {
    APP_NAME: string;
  };
  db: NodePgDatabase<typeof schema>;
  auth: ReturnType<typeof betterAuth>;
  files: FilesService;
}>();
```

Omit context fields that are not yet present in the project (e.g. `auth` if `adding-authentication` hasn't run). Preserve all existing fields.

## Server entrypoint

Update `server/app.ts` to construct `FilesService` once at module scope (the S3 client is reusable across requests).

```ts
import { S3Client } from '@aws-sdk/client-s3';
import { FilesService } from '../app/services/file.service';

// Create S3 client once — RustFS is S3-compatible
const s3Client = new S3Client({
  endpoint: process.env.S3_ENDPOINT,
  region: 'us-east-1',  // required by AWS SDK, value ignored by RustFS
  credentials: {
    accessKeyId: process.env.S3_ACCESS_KEY!,
    secretAccessKey: process.env.S3_SECRET_KEY!,
  },
  forcePathStyle: true,  // required for RustFS
});

const bucketName = process.env.S3_BUCKET!;
const files = new FilesService(db, s3Client, bucketName);
```

Wire `files` into the `RouterContextProvider` in the Hono request handler:

```ts
routerContext.set(appContext, {
  env: { APP_NAME: process.env.APP_NAME ?? '' },
  db,
  files,
  // auth: auth (if added)
});
```

Add `S3_ENDPOINT`, `S3_ACCESS_KEY`, `S3_SECRET_KEY`, and `S3_BUCKET` to `.env` if not already present (they were added in `01-rustfs-setup.md`).

## Expected Results

- `app/context.ts` exposes `files: FilesService`.
- `server/app.ts` constructs `new S3Client(...)` and `new FilesService(db, s3Client, bucketName)` at module scope.
- `FilesService` is passed into `RouterContextProvider` on every request.
