---
name: adding-ai
description: Adds Vercel AI SDK to a bootstrapped project. Cloudflare target uses OpenAI provider. Docker/Postgres target lets the user choose between OpenAI and SAP AI Core. Dispatches references based on deployment_target and ai_provider. Use when capabilities.ai is planned and scaffolding-project has run.
---

# Adding AI

Installs the Vercel AI SDK with the chosen provider, creates an `AIService` class, wires it into the server and app context, and configures the required environment variables.

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
- Do not hardcode API keys or credentials in source.
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

**Docker/Postgres + OpenAI only:**

- API key and model IDs go in `.env` and are read via `process.env`.
- `AIService` can be constructed once at module scope in `workers/app.ts`.

**Docker/Postgres + SAP AI Core only:**

- SAP AI Core does not support image generation. Do not create an `imageModel` getter and do not set any `*_IMAGE_MODEL_ID` variable.
- All five `AICORE_*` credentials are sensitive — document them as required environment variables that must never be committed.
- `AIService` can be constructed once at module scope in `workers/app.ts`.

## Workflow

1. Read `docs/context.json`. Confirm guard passes. Derive `PROJECT_PATH` and `DEPLOYMENT_TARGET`.
2. **Select provider** (docker-postgres target only):
   - If `context.project.ai_provider` is already set, use that value.
   - Otherwise ask the user:
     ```
     Which AI provider would you like to use?
     1. OpenAI
     2. SAP AI Core
     ```
   - Write the choice to `docs/context.json` as `project.ai_provider` (`openai` or `sap-aicore`).
   - Cloudflare target always uses `openai` — skip this step.
3. Install AI SDK packages:
   - `cloudflare` or `docker-postgres` + `openai` → [references/01-ai-sdk-setup.md](references/01-ai-sdk-setup.md)
   - `docker-postgres` + `sap-aicore` → [references/docker-postgres/sap-aicore/01-ai-sdk-setup.md](references/docker-postgres/sap-aicore/01-ai-sdk-setup.md)
4. **Set up environment variables and secrets:**
   - `cloudflare` → [references/cloudflare/02-env-and-secret.md](references/cloudflare/02-env-and-secret.md)
   - `docker-postgres` + `openai` → [references/docker-postgres/02-env-and-secret.md](references/docker-postgres/02-env-and-secret.md)
   - `docker-postgres` + `sap-aicore` → [references/docker-postgres/sap-aicore/02-env-and-secret.md](references/docker-postgres/sap-aicore/02-env-and-secret.md)
5. **Create the AI service:**
   - `cloudflare` or `docker-postgres` + `openai` → [references/03-ai-service.md](references/03-ai-service.md)
   - `docker-postgres` + `sap-aicore` → [references/docker-postgres/sap-aicore/03-ai-service.md](references/docker-postgres/sap-aicore/03-ai-service.md)
6. **Wire the service into app context and the server:**
   - `cloudflare` → [references/cloudflare/04-app-integration.md](references/cloudflare/04-app-integration.md)
   - `docker-postgres` + `openai` → [references/docker-postgres/04-app-integration.md](references/docker-postgres/04-app-integration.md)
   - `docker-postgres` + `sap-aicore` → [references/docker-postgres/sap-aicore/04-app-integration.md](references/docker-postgres/sap-aicore/04-app-integration.md)
7. Update project documentation using [documentation-updates.md](../../shared/references/documentation-updates.md).
8. Write `capabilities.ai = "ready"` to `docs/context.json`.
9. Run `pnpm format`, `pnpm typecheck`, `pnpm lint`, and `pnpm build`. Fix any failures before proceeding.

## References

**Shared (cloudflare + docker-postgres/openai):**

- [references/01-ai-sdk-setup.md](references/01-ai-sdk-setup.md)
- [references/03-ai-service.md](references/03-ai-service.md)

**Cloudflare target:**

- [references/cloudflare/02-env-and-secret.md](references/cloudflare/02-env-and-secret.md)
- [references/cloudflare/04-app-integration.md](references/cloudflare/04-app-integration.md)

**Docker/Postgres + OpenAI:**

- [references/docker-postgres/02-env-and-secret.md](references/docker-postgres/02-env-and-secret.md)
- [references/docker-postgres/04-app-integration.md](references/docker-postgres/04-app-integration.md)

**Docker/Postgres + SAP AI Core:**

- [references/docker-postgres/sap-aicore/01-ai-sdk-setup.md](references/docker-postgres/sap-aicore/01-ai-sdk-setup.md)
- [references/docker-postgres/sap-aicore/02-env-and-secret.md](references/docker-postgres/sap-aicore/02-env-and-secret.md)
- [references/docker-postgres/sap-aicore/03-ai-service.md](references/docker-postgres/sap-aicore/03-ai-service.md)
- [references/docker-postgres/sap-aicore/04-app-integration.md](references/docker-postgres/sap-aicore/04-app-integration.md)

**Always:**

- [shared/references/documentation-updates.md](../../shared/references/documentation-updates.md)
- [shared/references/app-architecture.md](../../shared/references/app-architecture.md)

## Review Checklist

**All targets:**

- [ ] Guard passed — `project.name` present in `docs/context.json`.
- [ ] `context.project.ai_provider` set (`openai` for cloudflare; `openai` or `sap-aicore` for docker-postgres).
- [ ] `app/services/ai.service.ts` exports `AIService` with a configured provider.
- [ ] `app/context.ts` exposes `ai: AIService`.
- [ ] `docs/architecture.md` includes the chosen provider and Vercel AI SDK in the Stack section.
- [ ] `pnpm format`, `pnpm typecheck`, `pnpm lint`, and `pnpm build` pass.
- [ ] `docs/context.json` updated with `capabilities.ai = "ready"`.

**Cloudflare + docker-postgres/OpenAI only:**

- [ ] `ai` and `@ai-sdk/openai` installed.
- [ ] `OPENAI_API_KEY` set in `.env`; `.env.example` has empty placeholder.
- [ ] `OPENAI_MODEL_ID` and `OPENAI_IMAGE_MODEL_ID` configured.
- [ ] `AIService` has both `model` and `imageModel` getters.

**Docker/Postgres + SAP AI Core only:**

- [ ] `ai` and `@ai-foundry/sap-aicore-provider` installed.
- [ ] All six `AICORE_*` variables set in `.env`; `.env.example` has empty placeholders.
- [ ] `AIService` has only a `model` getter — no `imageModel`.
- [ ] No `OPENAI_*` variables added.
