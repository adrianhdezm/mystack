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

4. Create `.gitignore` with these entries:

```gitignore
.DS_Store
.env
/node_modules/
*.tsbuildinfo

# React Router
/.react-router/
/build/

# Cloudflare
.mf
.wrangler
.dev.vars*
worker-configuration.d.ts
```

5. Create `AGENTS.md` with these instructions:

````markdown
# Agent Instructions

## Project Context

This project is a React Router v7 application deployed to Cloudflare Workers.

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

6. Create a `CLAUDE.md` symlink pointing to `AGENTS.md`.

```sh
ln -s AGENTS.md CLAUDE.md
```

## Expected Results

- `package.json` exists and contains the project name, description, `private: true`, `type: "module"`, and `packageManager: "pnpm@<pnpm-version>"`.
- `README.md` exists with the project name as the heading and the project description below it.
- `.gitignore` exists with macOS, environment, dependency, TypeScript build info, React Router, and Cloudflare generated-file entries.
- `AGENTS.md` exists and tells future agents this is a React Router v7 project deployed to Cloudflare Workers, packages are managed with pnpm, and commit messages use the project Conventional Commits format.
- `CLAUDE.md` is a symlink to `AGENTS.md`.
