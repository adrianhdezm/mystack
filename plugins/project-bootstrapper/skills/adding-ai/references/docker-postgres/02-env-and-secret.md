# 02 - Environment Variables (docker-postgres target)

## Set up API key and model IDs

Retrieve the OpenAI API key from the macOS Keychain or ask the user. Add to `.env`:

```env
OPENAI_API_KEY=<api-key>
OPENAI_MODEL_ID=gpt-4o
OPENAI_IMAGE_MODEL_ID=dall-e-3
```

Add placeholders to `.env.example`:

```env
OPENAI_API_KEY=
OPENAI_MODEL_ID=gpt-4o
OPENAI_IMAGE_MODEL_ID=dall-e-3
```

For production deployments, document in the target project's `README.md` that `OPENAI_API_KEY` must be set as an environment variable in the deployment configuration and must never be committed to the repository.

## Expected Results

- `.env` contains `OPENAI_API_KEY`, `OPENAI_MODEL_ID`, and `OPENAI_IMAGE_MODEL_ID`.
- `.env.example` documents all three with placeholder values.
