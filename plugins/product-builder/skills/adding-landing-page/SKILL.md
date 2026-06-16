---
name: adding-landing-page
description: Adds a public-facing landing page to an existing Product Builder project using React Router, shadcn/ui, and Tailwind CSS. Use when the user asks to add a landing page, marketing page, homepage, or public entry point to an existing Cloudflare Workers React Router project.
---

# Adding Landing Page

## Required inputs

Work in the target project repository. If the project path is unclear, ask for only the path before changing files.

```text
PROJECT_PATH: <absolute path>
```

## Hard rules

- Use `pnpm` for package installation and scripts.
- Load `react-router-patterns` → `adding-routes.md` before touching `app/routes.ts` or any route module. All route registration and module shape must follow those patterns.
- Register all routes in `app/routes.ts` using `layout()` and `index()` helpers from `@react-router/dev/routes`. Never use filename-based routing conventions.
- Route modules must import generated types from `./+types/<route-file>`. Do not manually type `LoaderArgs`, `MetaFunction`, or component props.
- The landing page must be public — it must not require authentication to view.
- Use shadcn/ui components and Tailwind CSS for all UI. Do not introduce additional styling libraries.
- Separate the public layout from the authenticated app layout using sibling `layout()` groups in `app/routes.ts`. Never wrap landing page routes in a protected layout.
- The landing page route is `/` (index route under the public layout).
- Extract reusable sections (Hero, Features, CTA) as components in `app/components/landing/`. Keep route files thin.
- Do not hardcode placeholder copy. Use the product name, vision, and key features from `docs/vision.md` (if present) or from the user's product brief. Ask the user for real copy if none is available.

## Workflow

1. Verify the target project is a bootstrapped Product Builder-style Cloudflare Workers, Vite, React Router, TypeScript, and pnpm project.
2. Load `react-router-patterns` → read `adding-routes.md`.
3. Read `docs/vision.md` (if present) and the product brief to gather product name, headline copy, and key features.
4. Create the public layout route file, index route file, and register both in `app/routes.ts` using [01-routes-and-layout.md](references/01-routes-and-layout.md).
5. Build the landing page section components using [02-landing-page-sections.md](references/02-landing-page-sections.md).
6. Write unit tests for the landing page route using [03-tests.md](references/03-tests.md).
7. Update project documentation using [documentation-updates.md](../../shared/references/documentation-updates.md) with these specifics:
   - **Stack addition**: none (shadcn/ui and Tailwind are already in the stack).
   - **Structure additions**: `app/components/landing/`, `app/routes/public-layout.tsx` (public layout), `app/routes/home.tsx` (landing page), `tests/unit/routes/home.test.tsx`.
   - **New convention**: `docs/conventions/landing-page.md` — seed with: public vs. authenticated layout split in `app/routes.ts`, component directory for landing sections, content sourced from `docs/vision.md`.
   - **README additions**: note that `/` is the public landing page and describe how to update copy.
   - **AGENTS.md additions**: landing page instructions — location of section components, how to update copy, how the public layout is separated from the authenticated layout.
8. Run formatting, typecheck, lint, and build. If any command fails, fix the issue and re-run until it passes before committing.
9. Commit the generated and updated files using the repository's Conventional Commits format.

## Validation checklist

- [ ] `app/routes/public-layout.tsx` renders the public layout with `<Outlet />` and no authentication guard.
- [ ] `app/routes/home.tsx` renders the landing page at `/`.
- [ ] Both routes are registered in `app/routes.ts` using `layout()` and `index()` — no filename-based routing.
- [ ] Route modules import generated types from `./+types/public-layout` and `./+types/home`.
- [ ] Landing page sections are in `app/components/landing/` (e.g., `Hero.tsx`, `Features.tsx`, `CTASection.tsx`).
- [ ] Landing page copy reflects real product content from `docs/vision.md` or the user's brief.
- [ ] The authenticated app layout (if present) is unaffected — protected routes still require login.
- [ ] `tests/unit/routes/home.test.tsx` exists and all tests pass.
- [ ] `react-router-patterns` → `adding-routes.md` was loaded and followed.
- [ ] `docs/architecture.md` is updated with the new route files and component directory.
- [ ] `docs/conventions/landing-page.md` exists and documents the public/authenticated layout split.
- [ ] `README.md` and `AGENTS.md` document the landing page location and how to update copy.
- [ ] Project verification commands pass or failures are explained.
- [ ] Generated and updated files were committed with a Conventional Commit message.
