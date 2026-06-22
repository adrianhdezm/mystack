---
name: adding-landing-page
description: Adds a public-facing landing page to an existing Product Builder project using React Router, shadcn/ui, and Tailwind CSS. Use when the user asks to add a landing page, marketing page, homepage, or public entry point to an existing Cloudflare Workers React Router project.
---

# Adding Landing Page

## Context

Read [context-schema.md](../../shared/references/context-schema.md) for the full `docs/context.json` schema, field reference, and guard pattern.

**Guard** — stop before changing any files if `context.project.name` is missing from `docs/context.json`. Stop with:

```text
Stop — docs/context.json is missing project.name. Run scaffolding-project first, then re-run this skill.
```

Set `skills.adding-landing-page` to `in-progress` at the start of the workflow. On successful completion, write the following and set the status to `done`.

**Writes:**

```json
{
  "capabilities": { "landing_page": true },
  "skills": { "adding-landing-page": "done" }
}
```

## Required inputs

Work in the target project repository. Derive `PROJECT_PATH` from `context.repository.local_path`. If the context file is missing, ask for only the path before changing files.

```text
PROJECT_PATH: <absolute path>
```

## Hard rules

- Load `react-router-patterns` → `adding-routes.md` before touching `app/routes.ts` or any route module. All route registration and module shape must follow those patterns.
- Register all routes in `app/routes.ts` using `layout()` and `index()` helpers from `@react-router/dev/routes`. Never use filename-based routing conventions.
- The landing page must be public — it must not require authentication to view. Never wrap landing page routes in a protected layout.
- Use shadcn/ui components and Tailwind CSS for all UI. Do not introduce additional styling libraries.
- Extract reusable sections (Hero, Features, CTA) as components in `app/components/landing/`. Keep route files thin.
- Do not hardcode placeholder copy. Use the product name, problem statement, and key features from `docs/prd.md` (if present) or from the user's product brief. Ask the user for real copy if none is available.

## Workflow

1. Verify the target project is a bootstrapped Product Builder-style Cloudflare Workers, Vite, React Router, TypeScript, and pnpm project.
2. Read `docs/prd.md` (if present) and the product brief to gather product name, headline copy, and key features.
3. Load `react-router-patterns` → `adding-routes.md`, then create the public layout route file, index route file, and register both in `app/routes.ts` using [01-routes-and-layout.md](references/01-routes-and-layout.md).
4. Build the landing page section components using [02-landing-page-sections.md](references/02-landing-page-sections.md).
5. Write unit tests for the landing page route using [03-tests.md](references/03-tests.md).
6. Update project documentation using [documentation-updates.md](../../shared/references/documentation-updates.md) with these specifics:
   - **Stack addition**: none (shadcn/ui and Tailwind are already in the stack).
   - **Structure additions**: `app/components/landing/`, `app/routes/public-layout.tsx` (public layout), `app/routes/home.tsx` (landing page), `tests/unit/routes/home.test.tsx`.
   - **New convention**: `docs/conventions/landing-page.md` — seed with: public vs. authenticated layout split in `app/routes.ts`, component directory for landing sections, content sourced from `docs/prd.md`.
   - **README additions**: note that `/` is the public landing page and describe how to update copy.
   - **AGENTS.md additions**: landing page instructions — location of section components, how to update copy, how the public layout is separated from the authenticated layout.
7. Run `pnpm format`, `pnpm typecheck`, `pnpm lint`, `pnpm test`, and `pnpm build`. If any command fails, fix the issue and re-run until it passes before committing.
8. Write `capabilities.landing_page = true` and `skills.adding-landing-page = "done"` to `docs/context.json`.
9. Commit the generated and updated files using the repository's Conventional Commits format.

## Validation checklist

- [ ] `app/routes/public-layout.tsx` renders the public layout with `<Outlet />` and no authentication guard.
- [ ] `app/routes/home.tsx` renders the landing page at `/`.
- [ ] Both routes are registered in `app/routes.ts` using `layout()` and `index()` — no filename-based routing.
- [ ] Route modules import generated types from `./+types/public-layout` and `./+types/home`.
- [ ] Landing page sections are in `app/components/landing/` (e.g., `Hero.tsx`, `Features.tsx`, `CTASection.tsx`).
- [ ] Landing page copy reflects real product content from `docs/prd.md` or the user's brief.
- [ ] The authenticated app layout (if present) is unaffected — protected routes still require login.
- [ ] `tests/unit/routes/home.test.tsx` exists and all tests pass.
- [ ] `docs/architecture.md` is updated with the new route files and component directory.
- [ ] `docs/conventions/landing-page.md` exists and documents the public/authenticated layout split.
- [ ] `README.md` and `AGENTS.md` document the landing page location and how to update copy.
- [ ] Project verification commands pass or failures are explained.
- [ ] `docs/context.json` guards passed (`project.name` present).
- [ ] `docs/context.json` was updated with `capabilities.landing_page = true` and `skills.adding-landing-page = "done"`.
- [ ] Generated and updated files were committed with a Conventional Commit message.
