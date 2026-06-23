# 01 - Initialize pnpm and Base Files

## Steps

1. Check the pnpm version, then run `pnpm init` from the cloned repository root.

```sh
pnpm --version
pnpm init
```

2. Update the generated `package.json` so it includes these properties, replacing `<pnpm-version>` with the output from `pnpm --version`.

```json
{
  "name": "<project-name>",
  "description": "<project-description>",
  "private": true,
  "type": "module",
  "packageManager": "pnpm@<pnpm-version>"
}
```

3. Create `README.md` with this content:

```markdown
# <project-name>

<project-description>
```

4. Create `.gitignore`. Start with these common entries, then add the target-specific section below:

```gitignore
.DS_Store
.env
/node_modules/
*.tsbuildinfo

# React Router
/.react-router/
/build/
```

For `cloudflare` target, also add:

```gitignore
# Cloudflare
.mf
.wrangler
.dev.vars*
worker-configuration.d.ts
```

For `docker-postgres` target, also add:

```gitignore
# Docker
.docker-data/
```

5. Create `AGENTS.md` with these instructions. Replace `<deployment-context>` based on the target:
   - `cloudflare` → `a React Router application deployed to Cloudflare Workers`
   - `docker-postgres` → `a React Router application running on Node.js, deployed via Docker Compose with Postgres`

> **Minimum versions:** React Router v8 requires Node.js 22.22+, React 19.2.7+, and Vite 7+. Verify before bootstrapping.

````markdown
# Agent Instructions

## Project Context

This project is <deployment-context>.

## Package Management

Check latest versions first with `pnpm view`, then install with `@latest`.

## Bootstrap Safety

Files created earlier in this bootstrap run may be reused and updated as the project takes shape.

## Commit Messages

Use Conventional Commits with this project format:

```text
<type>[optional scope]: <gitmoji> <summary>
```

Types: `feat` ✨, `refactor` ♻️, `fix` 🐛, `docs` 📝, `test` ✅, `chore` 🔧.

- Keep scopes lowercase.
- Keep summaries imperative, under 72 characters, and without a final period.
- Use a `BREAKING CHANGE:` footer for breaking changes.

```text
docs(readme): 📝 Update project description
chore: 🔧 Update gitignore
feat(skills): ✨ Add prompt writing skill
fix(api): 🐛 Correct schema validation
```
````

6. Create `pnpm-workspace.yaml`. pnpm 11 requires explicit approval for packages that run postinstall scripts — create this file before any installs to avoid blocked build errors.

```yaml
allowBuilds:
  esbuild: true
```

7. Create a `CLAUDE.md` symlink pointing to `AGENTS.md`.

```sh
ln -s AGENTS.md CLAUDE.md
```

## Expected Results

- `package.json` exists and contains the project name, description, `private: true`, `type: "module"`, and `packageManager: "pnpm@<pnpm-version>"`.
- `README.md` exists with the project name as the heading and the project description below it.
- `.gitignore` exists with common entries plus the target-specific section (Cloudflare or Docker).
- `AGENTS.md` exists and tells future agents the deployment target, packages are managed with pnpm, and commit messages use the project Conventional Commits format.
- `pnpm-workspace.yaml` exists with `allowBuilds: { esbuild: true }`.
- `CLAUDE.md` is a symlink to `AGENTS.md`.
