---
name: bootstrapping-projects
description: Orchestrates Project Bootstrapper from an empty repository to a committed, runnable project infrastructure. Covers repository preparation, capability selection, scaffolding, and all foundation skills. Use when the user asks to bootstrap, create, or set up a new project from scratch.
---

# Bootstrapping Projects

Drives sequential phases from an empty repository to a fully scaffolded, committed project infrastructure. Resume signals come from data in `docs/context.json` — not from skill flags. Read context before each phase to determine what to skip and where to resume.

When this skill completes, the project is ready for `product-builder` → `creating-products` to write the PRD and build features.

## Context

At the start of each phase, check the resume signal for that phase. If `docs/context.json` does not exist, start from Phase 0.

## Resume Signals

| Phase | Skip when |
| --- | --- |
| 0 — Repository | `repository.local_path` is set in `docs/context.json` and the path exists on disk |
| 1 — Capabilities | `project.deployment_target` is set in `docs/context.json` |
| 2 — Scaffold | `project.name` is set in `docs/context.json` |
| 3 — Foundation | Every `capabilities.*` that is `"planned"` is now `"ready"` |

## Workflow

Each phase is a single goal. Complete all acceptance criteria before advancing.

### Phase 0 — Repository

```
/goal Complete when all acceptance criteria are met.

Acceptance criteria:
- [ ] preparing-repositories completed successfully
- [ ] repository.local_path is set in docs/context.json
- [ ] The cloned repository is empty (only metadata)

Skip this phase if repository.local_path is set in docs/context.json and the path exists on disk.

Run preparing-repositories. It will derive REPOSITORY and LOCAL_FOLDER from the user's prompt or
ask for only the missing value. Do not create fallback folders. Stop and report if it cannot complete.
```

### Phase 1 — Capabilities

```
/goal Complete when all acceptance criteria are met.

Acceptance criteria:
- [ ] selecting-capabilities completed successfully
- [ ] project.deployment_target is set in docs/context.json
- [ ] project.idea is set in docs/context.json
- [ ] All capabilities.* are set to "planned" or "skipped"

Skip this phase if project.deployment_target is already set in docs/context.json.

Run selecting-capabilities. It will collect the product idea, deployment target, and capability
selections from the user. Stop and report if it cannot complete.
```

### Phase 2 — Scaffold

```
/goal Complete when all acceptance criteria are met.

Acceptance criteria:
- [ ] scaffolding-project completed successfully
- [ ] pnpm dev starts without errors
- [ ] project.name is set in docs/context.json
- [ ] docs/architecture.md exists with base stack and deployment target
- [ ] docs/conventions/routes.md exists with seed React Router patterns
- [ ] README.md and AGENTS.md are updated

Skip this phase if project.name is already set in docs/context.json.

Run scaffolding-project. It reads deployment_target and dispatches to the correct reference set.
Confirm pnpm dev starts without errors before proceeding to Phase 3.
```

### Phase 3 — Foundation

```
/goal Complete when all acceptance criteria are met.

Acceptance criteria:
- [ ] Every capability with status "planned" is now "ready" in docs/context.json
- [ ] docs/architecture.md lists every capability with its integration point
- [ ] docs/data-model.md reflects all foundation tables (if database was added)
- [ ] docs/conventions/ contains entries from each foundation skill
- [ ] AGENTS.md is updated with all capability information

Skip each foundation capability skill if its capabilities.* is already "ready".

Run the foundation skill for each capability where capabilities.* = "planned", in dependency order.
Skip any where capabilities.* is already "ready". Run each skill only after all its dependencies
have set their capabilities.* to "ready" in docs/context.json:

| Capability       | Skill                   | Depends On   |
|------------------|-------------------------|--------------|
| database         | adding-database         | —            |
| authentication   | adding-authentication   | database     |
| file_storage     | adding-file-storage     | database     |
| ai               | adding-ai               | —            |
| landing_page     | adding-landing-page     | —            |
| legal_pages      | adding-legal-pages      | landing_page |

When both landing_page and authentication are planned, run adding-landing-page before
adding-authentication so the public layout route exists when auth routes are registered.

Verify each skill's doc updates before running the next. Stop and report if a skill fails
repeatedly and cannot be resolved without user input.
```

### Final Commit

After all foundation skills have run and Phase 3 acceptance criteria are met:

1. Run `pnpm format`, `pnpm typecheck`, `pnpm lint`, `pnpm test`, and `pnpm build`. Fix any failures.
2. Commit all scaffolded and foundation files using the repository's Conventional Commits format.
3. Report the commit hash and a summary of what was bootstrapped:
   - Deployment target
   - Foundation capabilities enabled
   - Key files created (`docs/architecture.md`, `docs/conventions/`, `docs/context.json`)
   - Next step: run `product-builder` → `creating-products` to write the PRD and build features.

## References

- **Context schema**: [../../shared/references/context-schema.md](../../shared/references/context-schema.md)

## Review Checklist

- [ ] Resume signals checked before each phase.
- [ ] Each phase completed all acceptance criteria before advancing.
- [ ] `project.deployment_target`, `project.idea`, and `project.name` all set in `docs/context.json`.
- [ ] All `capabilities.*` that were `"planned"` are now `"ready"`.
- [ ] `pnpm dev` starts without errors after scaffolding.
- [ ] Foundation skills run in dependency order.
- [ ] `docs/architecture.md`, `docs/data-model.md`, `docs/conventions/` updated by foundation skills.
- [ ] `pnpm format`, `pnpm typecheck`, `pnpm lint`, `pnpm test`, and `pnpm build` pass.
- [ ] All scaffolded and foundation files committed with a Conventional Commit message.
- [ ] Summary presented to the user with commit hash and next steps.
