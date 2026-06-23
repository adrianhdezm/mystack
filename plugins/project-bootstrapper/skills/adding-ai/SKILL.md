---
name: adding-ai
description: Adds Vercel AI SDK with OpenAI provider to a bootstrapped project. Dispatches Cloudflare (Wrangler secrets) or Docker/Postgres (.env + process.env) based on deployment_target. Use when capabilities.ai is planned and scaffolding-project has run.
---

# Adding AI

Installs the Vercel AI SDK with OpenAI provider, creates an `AIService` class, wires it into the server and app context, and configures API key and model ID environment variables.

## Context

**Guard** — stop before changing any files if `context.project.name` is missing:

```text
Stop — docs/context.json is missing project.name. Run scaffolding-project first, then re-run this skill.
```

Derive `PROJECT_PATH` from `context.repository.local_path`. Derive `DEPLOYMENT_TARGET` from `context.project.deployment_target`.

On success write:

```json
{
  "capabilities": { "ai": "ready" }
}
```

## Hard rules

- Load `react-router-patterns` before changing React Router context or server request handling.
- Use Vercel AI SDK (`ai`) with the OpenAI provider (`@ai-sdk/openai`).
- Do not hardcode API keys in source.
- Keep the AI service in `app/services/ai.service.ts` as a thin provider wrapper.
- AI SDK functions (`generateText`, `streamText`, `generateImage`, `Output`) must only be used inside `app/services/ai.service.ts`. Routes call service methods, never the SDK directly.
- The foundation skill creates the base service with provider configuration. Feature implementations extend the service with domain-specific methods.
- Preserve existing server entry, React Router request handling, and app context.
- Read [app-architecture.md](../../shared/references/app-architecture.md) before modifying `workers/app.ts`. Wire capabilities inline — no helper files under `workers/`.

**Cloudflare target only:**

- Cloudflare Workers do not have `process.env`. The OpenAI API key must come from the Worker `env` object, not `process.env`.
- `OPENAI_API_KEY` is a Wrangler secret — set via `wrangler secret put` for remote deployments.
- Model IDs go in `wrangler.jsonc` vars (not secrets).
- The default OpenAI provider (`import { openai } from "@ai-sdk/openai"`) reads from `process.env` — always use `createOpenAI({ apiKey })` instead.

**Docker/Postgres target only:**

- API key and model IDs go in `.env` and are read via `process.env`.
- `AIService` can be constructed once at module scope in `workers/app.ts`.

## Workflow

1. Read `docs/context.json`. Confirm guard passes. Derive `PROJECT_PATH` and `DEPLOYMENT_TARGET`.
2. Install AI SDK packages using [references/01-ai-sdk-setup.md](references/01-ai-sdk-setup.md).
3. **Set up environment variables and secrets:**
   - `cloudflare` → [references/cloudflare/02-env-and-secret.md](references/cloudflare/02-env-and-secret.md)
   - `docker-postgres` → [references/docker-postgres/02-env-and-secret.md](references/docker-postgres/02-env-and-secret.md)
4. Create the AI service using [references/03-ai-service.md](references/03-ai-service.md).
5. **Wire the service into app context and the server:**
   - `cloudflare` → [references/cloudflare/04-app-integration.md](references/cloudflare/04-app-integration.md)
   - `docker-postgres` → [references/docker-postgres/04-app-integration.md](references/docker-postgres/04-app-integration.md)
6. Update project documentation using [documentation-updates.md](../../shared/references/documentation-updates.md).
7. Write `capabilities.ai = "ready"` to `docs/context.json`.
8. Run `pnpm format`, `pnpm typecheck`, `pnpm lint`, and `pnpm build`. Fix any failures before proceeding.

## References

**Shared (both targets):**

- [references/01-ai-sdk-setup.md](references/01-ai-sdk-setup.md)
- [references/03-ai-service.md](references/03-ai-service.md)
- [shared/references/documentation-updates.md](../../shared/references/documentation-updates.md)
- [shared/references/app-architecture.md](../../shared/references/app-architecture.md)

**Cloudflare target:**

- [references/cloudflare/02-env-and-secret.md](references/cloudflare/02-env-and-secret.md)
- [references/cloudflare/04-app-integration.md](references/cloudflare/04-app-integration.md)

**Docker/Postgres target:**

- [references/docker-postgres/02-env-and-secret.md](references/docker-postgres/02-env-and-secret.md)
- [references/docker-postgres/04-app-integration.md](references/docker-postgres/04-app-integration.md)

## Review Checklist

- [ ] Guard passed — `project.name` present in `docs/context.json`.
- [ ] `ai` and `@ai-sdk/openai` installed.
- [ ] `OPENAI_API_KEY` set in `.env`; `.env.example` has empty placeholder.
- [ ] `app/services/ai.service.ts` exports `AIService` with a configured OpenAI provider.
- [ ] `app/context.ts` exposes `ai: AIService`.
- [ ] Server entry constructs `new AIService(...)` and passes it to context.
- [ ] `docs/architecture.md` includes Vercel AI SDK / OpenAI in the Stack section.
- [ ] `pnpm format`, `pnpm typecheck`, `pnpm lint`, and `pnpm build` pass.
- [ ] `docs/context.json` updated with `capabilities.ai = "ready"`.

# Adding AI

## Context

**Guard** — stop before changing any files if `context.project.name` is missing from `docs/context.json`. Stop with:

```text
Stop — docs/context.json is missing project.name. Run scaffolding-project first, then re-run this skill.
```

On successful completion, write:

**Writes:**

```json
{
  "capabilities": { "ai": "ready" }
}
```

## Required inputs

Work in the target project repository. Derive `PROJECT_PATH` from `context.repository.local_path`. If the context file is missing, ask for only the path before changing files.

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
- Read [app-architecture.md](../../shared/references/app-architecture.md) when modifying `workers/app.ts`. New bindings must be wired inline — do not create helper files in `workers/`.

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
7. Write `capabilities.ai = "ready"` to `docs/context.json`.
8. Run formatting, typecheck, lint, and build. If any command fails, fix the issue and re-run until it passes before committing.
9. Commit the generated and updated files in the repository using the repository's Conventional Commits format.

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
- [ ] `docs/context.json` guards passed (`project.name` present).
- [ ] `docs/context.json` was updated with `capabilities.ai = "ready"`.
- [ ] Generated and updated files were committed with a Conventional Commit message.
