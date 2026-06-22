# 01 - MinIO Setup (docker-postgres target)

Sets up MinIO (S3-compatible object storage) in Docker Compose for local development and configures the AWS SDK v3 client.

## Steps

1. Add the MinIO service to `docker-compose.yml`. If the file doesn't exist, it was created in `scaffolding-project`.

```yaml
services:
  minio:
    image: minio/minio:latest
    restart: unless-stopped
    command: server /data --console-address ":9001"
    environment:
      MINIO_ROOT_USER: minioadmin
      MINIO_ROOT_PASSWORD: minioadmin
    ports:
      - "9000:9000"
      - "9001:9001"
    volumes:
      - .docker-data/minio:/data
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

4. Add MinIO environment variables to `.env`.

```env
MINIO_ENDPOINT=http://localhost:9000
MINIO_ACCESS_KEY=minioadmin
MINIO_SECRET_KEY=minioadmin
MINIO_BUCKET=app-files
```

5. Add MinIO placeholder to `.env.example`.

```env
MINIO_ENDPOINT=http://localhost:9000
MINIO_ACCESS_KEY=
MINIO_SECRET_KEY=
MINIO_BUCKET=app-files
```

6. Start Docker Compose to spin up MinIO:

```sh
docker compose up -d
```

7. Create the bucket in MinIO. You can use the MinIO console at `http://localhost:9001` (login: minioadmin/minioadmin) or the AWS CLI:

```sh
AWS_ACCESS_KEY_ID=minioadmin AWS_SECRET_ACCESS_KEY=minioadmin aws s3 mb s3://app-files --endpoint-url http://localhost:9000
```

## Expected Results

- `@aws-sdk/client-s3` and `@aws-sdk/s3-request-presigner` are installed.
- `docker-compose.yml` has a MinIO service with data volume mounted.
- `.env` contains `MINIO_ENDPOINT`, `MINIO_ACCESS_KEY`, `MINIO_SECRET_KEY`, and `MINIO_BUCKET`.
- `.env.example` documents MinIO variables.
- MinIO is accessible at `http://localhost:9000`.
