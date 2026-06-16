---
name: adding-ai
description: Adds Vercel AI SDK with OpenAI provider to an existing Product Builder project using a service class, Wrangler secrets, and React Router server context. Use when the user asks to add AI, LLM, text generation, image generation, structured output, OpenAI, or AI SDK to an existing Cloudflare Workers React Router project.
---

# Adding AI

## Required inputs

Work in the target project repository. If the project path is unclear, ask for only the path before changing files.

```text
PROJECT_PATH: <absolute path>
```

## Hard rules

- Load `react-router-patterns` before changing React Router context, Worker request handling, route modules, loaders, or actions. Any React Router code must follow those patterns.
- Use Vercel AI SDK (`ai`) with the OpenAI provider (`@ai-sdk/openai`).
- Do not hardcode API keys in source. Use environment variables and Wrangler secrets.
- Keep the AI service in `app/services/ai.service.ts` as a thin provider wrapper.
- AI SDK functions (`generateText`, `streamText`, `generateImage`, `Output`) must only be used inside `app/services/ai.service.ts`. Routes call service methods, never the SDK directly.
- The foundation skill creates the base service with provider configuration. Feature implementations extend the service with domain-specific methods (e.g., `summarize()`, `classify()`, `removeBackground()`).
- Preserve existing `wrangler.jsonc` settings, React Router request handling, and app context.
- Read [worker-architecture.md](../../shared/references/worker-architecture.md) when modifying `workers/app.ts`. New bindings must be wired inline — do not create helper files in `workers/`.

## Gotchas

- Cloudflare Workers do not have `process.env`. The OpenAI API key must come from the Worker `env` object passed to the `fetch` handler, not from `process.env.OPENAI_API_KEY`.
- `OPENAI_API_KEY` is a Worker secret, not a `wrangler.jsonc` binding. It must be set via `wrangler secret put` for remote deployments and added to `.env` for local development.
- The `ai` package's default OpenAI provider (`import { openai } from "@ai-sdk/openai"`) reads from `process.env`, which does not exist in Workers. Always use `createOpenAI({ apiKey })` to create a configured provider instance.
- The underlying OpenAI provider uses different accessors for text vs. image models: `openai(id)` for text and `openai.image(id)` for images. The `AIService` abstracts this internally — routes never import from `ai` or `@ai-sdk/openai` directly.

## Workflow

1. Verify the target project is a bootstrapped Product Builder-style Cloudflare Workers, Vite, React Router, TypeScript, and pnpm project.
2. Install AI SDK packages using [01-ai-sdk-setup.md](references/01-ai-sdk-setup.md).
3. Set up the OpenAI API key, model ID variables, and Worker secret using [02-env-and-secret.md](references/02-env-and-secret.md).
4. Create the AI service using [03-ai-service.md](references/03-ai-service.md).
5. Load `react-router-patterns`, then wire the service into app context and the Worker using [04-app-integration.md](references/04-app-integration.md).
6. Update project documentation using [documentation-updates.md](../../shared/references/documentation-updates.md) with these specifics:
   - **Stack addition**: `Vercel AI SDK, OpenAI`.
   - **Structure addition**: `app/services/ai.service.ts`.
   - **New convention**: `docs/conventions/ai-service.md` — seed with key patterns from [03-ai-service.md](references/03-ai-service.md): AI SDK imports (`generateText`, `streamText`, `generateImage`, `Output`) stay inside `ai.service.ts` only, routes call service methods never the SDK directly, feature implementations extend the service with domain-specific methods, the service owns provider configuration and model selection.
   - **README additions**: OpenAI API key setup, required environment variables, AI SDK usage examples.
   - **AGENTS.md additions**: AI service instructions, available capabilities (text generation, structured output, image generation, streaming), `docs/conventions/ai-service.md` reference.
7. Run formatting, typecheck, lint, and build. If any command fails, fix the issue and re-run until it passes before committing.
8. Commit the generated and updated files in the repository using the repository's Conventional Commits format.

## Validation checklist

- [ ] `ai` and `@ai-sdk/openai` are installed.
- [ ] `.env` contains `OPENAI_API_KEY` retrieved from the macOS Keychain or the user.
- [ ] `.env.example` documents `OPENAI_API_KEY` with an empty placeholder.
- [ ] `OPENAI_API_KEY` is set as a Wrangler secret or documented for later deployment.
- [ ] `app/services/ai.service.ts` exports `AIService` with a configured OpenAI provider.
- [ ] `app/context.ts` exposes `ai: AIService`.
- [ ] `wrangler.jsonc` contains `OPENAI_MODEL_ID` and `OPENAI_IMAGE_MODEL_ID` in `vars`.
- [ ] `workers/app.ts` constructs `new AIService(env.OPENAI_API_KEY, env.OPENAI_MODEL_ID, env.OPENAI_IMAGE_MODEL_ID)`.
- [ ] Generated `Env` types include `OPENAI_API_KEY`, `OPENAI_MODEL_ID`, and `OPENAI_IMAGE_MODEL_ID`.
- [ ] `react-router-patterns` was loaded and followed for any React Router context or Worker request-handling changes.
- [ ] `docs/architecture.md` includes Vercel AI SDK / OpenAI in the Stack section.
- [ ] `README.md` and `AGENTS.md` document AI setup, environment variables, and capabilities.
- [ ] Project verification commands pass or failures are explained.
- [ ] Generated and updated files were committed with a Conventional Commit message.
