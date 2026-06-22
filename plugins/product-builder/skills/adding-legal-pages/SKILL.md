---
name: adding-legal-pages
description: Adds Impressum, Privacy Policy, and Terms of Service pages to an existing Product Builder project using React Router and shadcn/ui. Use when the user asks to add legal pages, an Impressum, a privacy policy, or terms of service to an existing Cloudflare Workers React Router project.
---

# Adding Legal Pages

## Context

Read [context-schema.md](../../shared/references/context-schema.md) for the full `docs/context.json` schema, field reference, and guard pattern.

**Guard** — stop before changing any files if `context.capabilities.landing_page` is not `true` in `docs/context.json`. Stop with:

```text
Stop — docs/context.json is missing capabilities.landing_page = true. Run adding-landing-page first, then re-run this skill.
```

Set `skills.adding-legal-pages` to `in-progress` at the start of the workflow. On successful completion, write the following and set the status to `done`.

**Reads:** `context.operator.*` — if `operator.name`, `operator.address`, and `operator.email` are already present, use them and skip asking the user. If any are missing, collect them from the user and write them to `docs/context.json` before proceeding.

**Writes:**

```json
{
  "operator": {
    "name": "<full legal name>",
    "address": "<full postal address>",
    "email": "<contact email>"
  },
  "capabilities": { "legal_pages": true },
  "skills": { "adding-legal-pages": "done" }
}
```

## Required inputs

Work in the target project repository. Derive `PROJECT_PATH` from `context.repository.local_path`. If the context file is missing, ask for only the path before changing files.

```text
PROJECT_PATH: <absolute path>
```

## Required content

Legal pages require real business and operator information. First check `docs/context.json` for `operator.name`, `operator.address`, and `operator.email` — if all three are present, use them directly. Only ask the user for values that are missing from context.

Also collect the following before writing any page content:

```text
OPERATOR_NAME: <full legal name of the individual or company operating the product>
OPERATOR_ADDRESS: <full postal address>
OPERATOR_EMAIL: <contact email address>
OPERATOR_COUNTRY: <country of operation (determines legal requirements, e.g. Germany requires an Impressum)>
INCLUDE_IMPRESSUM: <yes/no — required for German/Austrian/Swiss operators; optional elsewhere>
INCLUDE_PRIVACY_POLICY: <yes/no — required if personal data is processed>
INCLUDE_TERMS: <yes/no — optional terms of service page>
```

If operator fields are missing from both context and the user's prompt, ask before writing any legal content. Incorrect or missing legal information can create liability — never fill gaps with invented data.

## Hard rules

- Load `react-router-patterns` → `adding-routes.md` before touching `app/routes.ts` or any route module. All route registration must follow those patterns.
- Register all routes in `app/routes.ts` inside the existing public layout group. Never use filename-based routing conventions.
- Route modules must import generated types from `./+types/<route-file>`. Do not manually type `MetaFunction` or component props.
- Legal pages must be public — they must not require authentication to view.
- Legal pages must be placed inside the `layout("routes/public-layout.tsx", [...])` group in `app/routes.ts`. If no public layout exists yet, create one using the pattern from [adding-landing-page/references/01-routes-and-layout.md](../adding-landing-page/references/01-routes-and-layout.md).
- Do not generate legal text from templates. Content must come from the user. The skill creates the route and page shell; the user provides and owns the legal text.
- After adding legal routes, link them from `SiteFooter` (if present) and from any existing cookie banner or consent UI.

## Workflow

1. Read `docs/context.json`. Confirm `capabilities.landing_page = true`. Stop if the guard fails.
2. Read `operator.*` from context. Collect any missing operator values from the user and write them to `docs/context.json` before continuing.
3. Verify the target project is a bootstrapped Product Builder-style Cloudflare Workers, Vite, React Router, TypeScript, and pnpm project.
4. Collect any remaining required content (see above). Do not proceed until `OPERATOR_NAME`, `OPERATOR_ADDRESS`, `OPERATOR_EMAIL`, and which pages to include are confirmed.
5. Create legal page routes using [01-legal-routes.md](references/01-legal-routes.md).
6. Populate page content using [02-legal-content.md](references/02-legal-content.md).
7. Update `SiteFooter` to link to the new pages using [03-footer-links.md](references/03-footer-links.md).
8. Update project documentation using [documentation-updates.md](../../shared/references/documentation-updates.md) with these specifics:
   - **Stack addition**: none.
   - **Structure additions**: route files for each legal page (`app/routes/impressum.tsx`, `app/routes/privacy-policy.tsx`, `app/routes/terms.tsx`) registered under the public layout in `app/routes.ts`.
   - **No new convention file needed** — legal pages follow standard static route patterns.
   - **README additions**: note the URLs of legal pages and the requirement to keep content up to date.
   - **AGENTS.md additions**: legal page locations and a reminder that legal content must be reviewed by the operator before going live.
9. Write `operator.*`, `capabilities.legal_pages = true`, and `skills.adding-legal-pages = "done"` to `docs/context.json`.
10. Run formatting, typecheck, lint, and build. If any command fails, fix the issue and re-run until it passes before committing.
11. Commit the generated and updated files in the repository using the repository's Conventional Commits format.

## Validation checklist

- [ ] Each requested page (`/impressum`, `/privacy-policy`, `/terms`) is served publicly with no authentication requirement.
- [ ] All pages are registered inside the `layout("routes/public-layout.tsx", [...])` group in `app/routes.ts` — they render with `SiteHeader` and `SiteFooter`.
- [ ] Route modules import generated types from `./+types/<route-file>`.
- [ ] `SiteFooter` contains links to every legal page that was created using React Router `<Link>`.
- [ ] Page content uses real operator information provided by the user — no placeholder text.
- [ ] `react-router-patterns` → `adding-routes.md` was loaded and followed.
- [ ] `docs/architecture.md` is updated with the new route files.
- [ ] `README.md` and `AGENTS.md` document the legal page URLs.
- [ ] Project verification commands pass or failures are explained.
- [ ] `docs/context.json` guards passed (`capabilities.landing_page = true`).
- [ ] `docs/context.json` was updated with `operator.*`, `capabilities.legal_pages = true`, and `skills.adding-legal-pages = "done"`.
- [ ] Generated and updated files were committed with a Conventional Commit message.
