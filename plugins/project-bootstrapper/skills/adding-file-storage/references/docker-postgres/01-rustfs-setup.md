# 01 - RustFS Setup (docker-postgres target)

Sets up RustFS (S3-compatible object storage) in Docker Compose for local development and configures the AWS SDK v3 client.

## Steps

1. Add the RustFS service to `docker-compose.yml`. If the file doesn't exist, it was created in `scaffolding-project`.

```yaml
services:
  rustfs:
    image: rustfs/rustfs:latest
    restart: unless-stopped
    environment:
      RUSTFS_ACCESS_KEY: rustfsadmin
      RUSTFS_SECRET_KEY: rustfsadmin
    ports:
      - "9000:9000"
    volumes:
      - .docker-data/rustfs:/data
    command: server /data
```

2. Check the latest AWS SDK S3 client package version.

```sh
pnpm view @aws-sdk/client-s3 version
pnpm view @aws-sdk/s3-request-presigner version
```

3. Install the AWS SDK S3 client and presigner.

```sh
pnpm add @aws-sdk/client-s3@latest @aws-sdk/s3-request-presigner@latest
```

4. Add RustFS environment variables to `.env`.

```env
S3_ENDPOINT=http://localhost:9000
S3_ACCESS_KEY=rustfsadmin
S3_SECRET_KEY=rustfsadmin
S3_BUCKET=app-files
```

5. Add RustFS placeholder to `.env.example`.

```env
S3_ENDPOINT=http://localhost:9000
S3_ACCESS_KEY=
S3_SECRET_KEY=
S3_BUCKET=app-files
```

6. Start Docker Compose to spin up RustFS:

```sh
docker compose up -d
```

7. Create the bucket using the AWS SDK v3 that was just installed — do not rely on the AWS CLI, which may not be present:

```sh
node --env-file=.env -e "
const { S3Client, CreateBucketCommand } = require('./node_modules/@aws-sdk/client-s3');
const s3 = new S3Client({
  endpoint: process.env.S3_ENDPOINT,
  region: 'us-east-1',
  credentials: { accessKeyId: process.env.S3_ACCESS_KEY, secretAccessKey: process.env.S3_SECRET_KEY },
  forcePathStyle: true,
});
s3.send(new CreateBucketCommand({ Bucket: process.env.S3_BUCKET }))
  .then(() => console.log('Bucket created: ' + process.env.S3_BUCKET))
  .catch(e => { console.error(e.message); process.exit(1); });
"
```

## Expected Results

- `@aws-sdk/client-s3` and `@aws-sdk/s3-request-presigner` are installed.
- `docker-compose.yml` has a RustFS service with data volume mounted.
- `.env` contains `S3_ENDPOINT`, `S3_ACCESS_KEY`, `S3_SECRET_KEY`, and `S3_BUCKET`.
- `.env.example` documents S3 variables.
- RustFS is accessible at `http://localhost:9000`.
- The S3 bucket named in `S3_BUCKET` is created using the AWS SDK v3 (no AWS CLI required).
