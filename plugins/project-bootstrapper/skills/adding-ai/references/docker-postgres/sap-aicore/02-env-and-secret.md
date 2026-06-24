# 02 - Environment Variables (SAP AI Core)

## Set up credentials and model ID

SAP AI Core authenticates via OAuth client credentials. All five variables are required; `AICORE_RESOURCE_GROUP` defaults to `default` if omitted but should be explicit.

Ask the user to provide the values — they come from the SAP BTP service key for the AI Core instance.

Add to `.env`:

```env
AICORE_BASE_URL=<ai-core-base-url>
AICORE_AUTH_URL=<oauth-token-url>
AICORE_CLIENT_ID=<client-id>
AICORE_CLIENT_SECRET=<client-secret>
AICORE_RESOURCE_GROUP=default
AICORE_MODEL_ID=<deployment-model-id>
```

Add placeholders to `.env.example`:

```env
AICORE_BASE_URL=
AICORE_AUTH_URL=
AICORE_CLIENT_ID=
AICORE_CLIENT_SECRET=
AICORE_RESOURCE_GROUP=default
AICORE_MODEL_ID=
```

For production deployments, document in the target project's `README.md` that all `AICORE_*` variables must be set in the deployment environment and must never be committed to the repository.

## Expected Results

- `.env` contains all six `AICORE_*` variables.
- `.env.example` documents all six with placeholder values.
- No `OPENAI_*` variables are added for this provider.
