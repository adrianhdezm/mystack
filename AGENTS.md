# Agent Instructions

## Repository Goal

This repository is a personal Codex stack for packaging and sharing coding-agent
capabilities. It is not a language-specific application repository: do not assume
there is a Node, Python, Go, Rust, or other runtime unless a specific skill or
plugin file introduces one.

The main artifacts in this repository are Codex plugins and `SKILL.md` files
that coding agents can load and follow. Treat the repository as agent tooling and
documentation, not as product source code.

## Repository Structure

- `README.md` describes the stack and the available plugins at a high level.
- `.agents/plugins/marketplace.json` registers local plugins for the Codex
  marketplace.
- `plugins/<plugin-name>/.codex-plugin/plugin.json` contains plugin metadata,
  marketplace presentation, capability declarations, and the skills path.
- `plugins/<plugin-name>/skills/<skill-name>/SKILL.md` contains the executable
  instructions for a skill.
- `plugins/<plugin-name>/skills/<skill-name>/references/` contains supporting
  reference material loaded by the skill only when needed.
- `plugins/<plugin-name>/assets/` contains icons, logos, and other plugin
  presentation assets.
- `plugins/<plugin-name>/agents/` contains agent configuration for a plugin.

## Working In This Repository

- Prefer Markdown and JSON edits that keep skill instructions precise,
  action-oriented, and easy for coding agents to follow.
- Keep skills self-contained. Put long supporting material in `references/`
  and link to it from `SKILL.md` instead of bloating the main skill file.
- Do not add language-specific build tooling, package managers, linters, or test
  frameworks at the repository root unless the repository itself gains source
  code that requires them.
- When updating plugin metadata, keep paths relative to the plugin directory and
  verify that declared assets and skills exist.
- Avoid broad rewrites of existing skills unless the request is specifically
  about behavior, structure, or clarity across the skill.

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
