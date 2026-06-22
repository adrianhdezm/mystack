---
name: adding-legal-pages
description: Adds Impressum, Privacy Policy, and Terms of Service pages to an existing Product Builder project using React Router and shadcn/ui. Use when the user asks to add legal pages, an Impressum, a privacy policy, or terms of service to an existing Cloudflare Workers React Router project.
---

# Adding Legal Pages

Adds static Impressum, Privacy Policy, and/or Terms of Service routes under the existing public layout, populated with real operator information, and links them from `SiteFooter`.

## Context

**Guard** — stop before changing any files if `context.capabilities.landing_page` is not `"ready"`:

```text
Stop — docs/context.json is missing capabilities.landing_page = "ready". Run adding-landing-page first, then re-run this skill.
```

**Reads:** `context.operator.*` — if `operator.name`, `operator.address`, and `operator.email` are present, use them directly. Only ask the user for fields that are missing.

Derive `PROJECT_PATH` from `context.repository.local_path`. On success write:

```json
{
  "operator": {
    "name": "<full legal name>",
    "address": "<full postal address>",
    "email": "<contact email>"
  },
  "capabilities": { "legal_pages": "ready" }
}
```

## Required Content

Legal pages need real operator information — incorrect or missing data creates liability. Never invent placeholder values. Collect any fields missing from context before proceeding:

```text
OPERATOR_NAME:    full legal name of the individual or company
OPERATOR_ADDRESS: full postal address
OPERATOR_EMAIL:   contact email address
OPERATOR_COUNTRY: country of operation (Germany/Austria/Switzerland requires an Impressum)
INCLUDE_IMPRESSUM:      yes/no
INCLUDE_PRIVACY_POLICY: yes/no
INCLUDE_TERMS:          yes/no
```

## Rules

- Load `react-router-patterns` → `adding-routes.md` before touching `app/routes.ts` or any route module.
- Register all legal routes inside the existing `layout("routes/public-layout.tsx", [...])` group. If no public layout exists, create one using the pattern from [adding-landing-page/references/01-routes-and-layout.md](../adding-landing-page/references/01-routes-and-layout.md).
- Route modules must import generated types from `./+types/<route-file>` — do not manually type `MetaFunction` or props.
- Legal pages must be public — never require authentication to view them.
- Do not generate legal text from templates — the skill creates the route shell; the user owns the content.
- Link all created legal pages from `SiteFooter` (if present) and any existing cookie banner.

## Workflow

1. Read `docs/context.json`. Confirm `capabilities.landing_page = "ready"`. Read `operator.*` and write any missing fields after collecting from the user. Derive `PROJECT_PATH` from `context.repository.local_path`.
2. Confirm which pages to create (`INCLUDE_IMPRESSUM`, `INCLUDE_PRIVACY_POLICY`, `INCLUDE_TERMS`) and that all operator fields are present.
3. Create legal page routes using [01-legal-routes.md](references/01-legal-routes.md).
4. Populate page content using [02-legal-content.md](references/02-legal-content.md).
5. Update `SiteFooter` to link to the new pages using [03-footer-links.md](references/03-footer-links.md).
6. Update project documentation using [documentation-updates.md](../../shared/references/documentation-updates.md): structure additions, README and AGENTS.md additions.
7. Write `operator.*` and `capabilities.legal_pages = "ready"` to `docs/context.json`.
8. Run `pnpm format`, `pnpm typecheck`, `pnpm lint`, and `pnpm build`. Fix any failures before committing.
9. Commit using the repository's Conventional Commits format.

## References

- **Legal routes**: [references/01-legal-routes.md](references/01-legal-routes.md)
- **Legal content**: [references/02-legal-content.md](references/02-legal-content.md)
- **Footer links**: [references/03-footer-links.md](references/03-footer-links.md)
- **Documentation updates**: [documentation-updates.md](../../shared/references/documentation-updates.md)
- **Public layout pattern**: [adding-landing-page/references/01-routes-and-layout.md](../adding-landing-page/references/01-routes-and-layout.md)

## Review Checklist

- [ ] `docs/context.json` guard passed (`capabilities.landing_page = "ready"`).
- [ ] All operator fields present in context before page content was written.
- [ ] Each requested page (`/impressum`, `/privacy-policy`, `/terms`) is public with no auth requirement.
- [ ] All pages registered inside `layout("routes/public-layout.tsx", [...])` in `app/routes.ts`.
- [ ] Route modules import generated types from `./+types/<route-file>`.
- [ ] `SiteFooter` links to every created legal page using React Router `<Link>`.
- [ ] Page content uses real operator information — no placeholder text.
- [ ] `pnpm format`, `pnpm typecheck`, `pnpm lint`, and `pnpm build` pass.
- [ ] `docs/context.json` updated with `operator.*` and `capabilities.legal_pages = "ready"`.
- [ ] Changes committed with Conventional Commit message.
