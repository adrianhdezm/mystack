---
name: adding-landing-page
description: Adds a public-facing landing page to an existing Product Builder project using React Router, shadcn/ui, and Tailwind CSS. Use when the user asks to add a landing page, marketing page, homepage, or public entry point to an existing Cloudflare Workers React Router project.
---

# Adding Landing Page

Creates a public layout route and an index landing page at `/`, built from real product copy, using shadcn/ui components and Tailwind. Adds a unit test and seeds the landing-page convention doc.

## Context

**Guard** — stop before changing any files if `context.project.name` is missing:

```text
Stop — docs/context.json is missing project.name. Run scaffolding-project first, then re-run this skill.
```

Set `skills.adding-landing-page` to `in-progress` at the start. Derive `PROJECT_PATH` from `context.repository.local_path`. On success write:

```json
{
  "capabilities": { "landing_page": true },
  "skills": { "adding-landing-page": "done" }
}
```

## Rules

- Load `react-router-patterns` → `adding-routes.md` before touching `app/routes.ts` or any route module.
- Register all routes in `app/routes.ts` using `layout()` and `index()` helpers — never filename-based routing.
- The landing page must be public — never wrap it in a protected layout.
- Use shadcn/ui and Tailwind for all UI — do not introduce additional styling libraries.
- Extract reusable sections (Hero, Features, CTA) as components in `app/components/landing/`. Keep route files thin.
- Do not hardcode placeholder copy — use product name, problem statement, and key features from `docs/prd.md` (if present) or the user's brief. Ask the user if neither is available.

## Workflow

1. Read `docs/context.json`. Confirm `project.name` is present. Set `skills.adding-landing-page` to `in-progress`.
2. Read `docs/prd.md` (if present) to gather product name, headline copy, and key features.
3. Load `react-router-patterns` → `adding-routes.md`, then create the public layout route, index route, and register both in `app/routes.ts` using [01-routes-and-layout.md](references/01-routes-and-layout.md).
4. Build landing page section components using [02-landing-page-sections.md](references/02-landing-page-sections.md).
5. Write unit tests for the landing page route using [03-tests.md](references/03-tests.md).
6. Update project documentation using [documentation-updates.md](../../shared/references/documentation-updates.md): structure additions, new `docs/conventions/landing-page.md` seeded with public/authenticated layout split and content sourcing from `docs/prd.md`, README and AGENTS.md additions.
7. Write `capabilities.landing_page = true` and `skills.adding-landing-page = "done"` to `docs/context.json`.
8. Run `pnpm format`, `pnpm typecheck`, `pnpm lint`, `pnpm test`, and `pnpm build`. Fix any failures before committing.
9. Commit using the repository's Conventional Commits format.

## References

- **Routes and layout**: [references/01-routes-and-layout.md](references/01-routes-and-layout.md)
- **Landing page sections**: [references/02-landing-page-sections.md](references/02-landing-page-sections.md)
- **Tests**: [references/03-tests.md](references/03-tests.md)
- **Documentation updates**: [documentation-updates.md](../../shared/references/documentation-updates.md)

## Review Checklist

- [ ] `docs/context.json` guard passed (`project.name` present).
- [ ] `app/routes/public-layout.tsx` renders with `<Outlet />` and no auth guard.
- [ ] `app/routes/home.tsx` renders at `/`.
- [ ] Both routes registered in `app/routes.ts` with `layout()` and `index()`.
- [ ] Route modules import generated types from `./+types/public-layout` and `./+types/home`.
- [ ] Landing page sections in `app/components/landing/`.
- [ ] Copy sourced from `docs/prd.md` or user brief — no placeholder text.
- [ ] Authenticated layout (if present) is unaffected.
- [ ] `tests/unit/routes/home.test.tsx` exists and passes.
- [ ] `docs/conventions/landing-page.md` created with layout split and content sourcing patterns.
- [ ] `pnpm format`, `pnpm typecheck`, `pnpm lint`, `pnpm test`, and `pnpm build` pass.
- [ ] `docs/context.json` updated with `capabilities.landing_page = true` and `skills.adding-landing-page = "done"`.
- [ ] Changes committed with Conventional Commit message.
