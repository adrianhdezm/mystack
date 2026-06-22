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

7. Create the bucket using the AWS CLI (S3-compatible):

```sh
AWS_ACCESS_KEY_ID=rustfsadmin AWS_SECRET_ACCESS_KEY=rustfsadmin aws s3 mb s3://app-files --endpoint-url http://localhost:9000
```

## Expected Results

- `@aws-sdk/client-s3` and `@aws-sdk/s3-request-presigner` are installed.
- `docker-compose.yml` has a RustFS service with data volume mounted.
- `.env` contains `S3_ENDPOINT`, `S3_ACCESS_KEY`, `S3_SECRET_KEY`, and `S3_BUCKET`.
- `.env.example` documents S3 variables.
- RustFS is accessible at `http://localhost:9000`.
