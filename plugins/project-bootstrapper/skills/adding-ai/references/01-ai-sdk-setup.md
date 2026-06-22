# 01 - AI SDK Setup

## Steps

1. Check the latest AI SDK package versions before installing.

```sh
pnpm view ai version
pnpm view @ai-sdk/openai version
```

2. Install AI SDK packages.

```sh
pnpm add ai@latest @ai-sdk/openai@latest
```

3. Verify `zod` is installed (required for structured output schemas).

If `zod` is not already a dependency:

```sh
pnpm add zod@latest
```

## Expected Results

- `ai` and `@ai-sdk/openai` are installed.
- `zod` is available for structured output schemas.
