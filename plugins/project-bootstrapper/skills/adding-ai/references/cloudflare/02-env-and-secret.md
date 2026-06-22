# 02 - Environment and Secret

## Steps

1. Retrieve the OpenAI API key from the macOS Keychain:

```sh
security find-generic-password -s OPENAI_API_KEY -w
```

If the command succeeds, use the returned value for `OPENAI_API_KEY`. If it fails (key not stored or not on macOS), ask the user to provide the key.

2. Write the key to `.env`. Preserve any existing variables.

```env
OPENAI_API_KEY=<retrieved-or-provided-key>
```

3. Update `.env.example` with an empty placeholder, not the real value.

```env
OPENAI_API_KEY=<your-openai-api-key-here>
```

4. Set the secret for the remote Cloudflare Worker. Read the key from `.env` and pipe it to avoid interactive prompts:

```sh
grep '^OPENAI_API_KEY=' .env | cut -d '=' -f2- | tr -d '"' | pnpm wrangler secret put OPENAI_API_KEY
```

If the command fails (not authenticated or no deployment yet), document this requirement in the target project's `README.md`:

````md
### Remote Cloudflare deployment

Before deploying to Cloudflare, set `OPENAI_API_KEY` in the remote Worker environment from an authenticated Wrangler session:

```sh
pnpm wrangler secret put OPENAI_API_KEY
```
````

5. Add model ID variables to `wrangler.jsonc`. These are non-secret configuration, so they go in `vars` rather than as Wrangler secrets.

Preserve existing `vars` and merge the new entries:

```jsonc
{
  "vars": {
    "OPENAI_MODEL_ID": "gpt-5",
    "OPENAI_IMAGE_MODEL_ID": "gpt-image-2",
  },
}
```

6. Regenerate Cloudflare types after adding the secret and vars.

```sh
pnpm cf-typegen
```

If the project does not have `cf-typegen`, run:

```sh
pnpm wrangler types
```

If `OPENAI_API_KEY`, `OPENAI_MODEL_ID`, or `OPENAI_IMAGE_MODEL_ID` do not appear in the generated `Env` interface, add them manually to `worker-configuration.d.ts`:

```ts
interface Env {
  // ... existing bindings
  OPENAI_API_KEY: string;
  OPENAI_MODEL_ID: string;
  OPENAI_IMAGE_MODEL_ID: string;
}
```

## Expected Results

- `.env` contains `OPENAI_API_KEY`.
- `.env.example` documents the variable with an empty placeholder.
- The remote Worker secret is set or documented for later deployment.
- `wrangler.jsonc` contains `OPENAI_MODEL_ID` and `OPENAI_IMAGE_MODEL_ID` in `vars`.
- Generated `Env` types include `OPENAI_API_KEY`, `OPENAI_MODEL_ID`, and `OPENAI_IMAGE_MODEL_ID`.
