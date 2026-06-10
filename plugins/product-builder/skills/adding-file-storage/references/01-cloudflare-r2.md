# 01 - Cloudflare R2

## Steps

1. Confirm Wrangler authentication.

```sh
pnpm wrangler whoami
```

2. Create the Cloudflare R2 bucket when it does not already exist.

Prefer the user's requested bucket name. If none is supplied, derive a
lowercase hyphen-case name from the project and suffix `-files`.

```sh
pnpm wrangler r2 bucket create <bucket-name> --binding=APP_FILES --update-config
```

Example:

```sh
pnpm wrangler r2 bucket create example-product-files --binding=APP_FILES --update-config
```

3. Verify `wrangler.jsonc` includes the generated R2 binding.

Do not replace existing bindings. Preserve the generated bucket name and only
normalize formatting if the repository already formats `wrangler.jsonc`.

```jsonc
{
  "r2_buckets": [
    {
      "binding": "APP_FILES",
      "bucket_name": "example-product-files"
    }
  ]
}
```

4. Regenerate Cloudflare types after adding the R2 binding.

```sh
pnpm cf-typegen
```

If the project does not have `cf-typegen`, run:

```sh
pnpm wrangler types
```

## Expected Results

- An R2 bucket exists in Cloudflare.
- `wrangler.jsonc` binds the bucket as `APP_FILES`.
- Generated `Env` types include `APP_FILES: R2Bucket`.
