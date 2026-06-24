# 01 - AI SDK Setup (SAP AI Core)

## Steps

1. Check the latest package versions before installing.

```sh
pnpm view ai version
pnpm view @ai-foundry/sap-aicore-provider version
```

2. Install AI SDK packages.

```sh
pnpm add ai@latest @ai-foundry/sap-aicore-provider@latest
```

3. Verify `zod` is installed (required for structured output schemas).

If `zod` is not already a dependency:

```sh
pnpm add zod@latest
```

## Expected Results

- `ai` and `@ai-foundry/sap-aicore-provider` are installed.
- `zod` is available for structured output schemas.
