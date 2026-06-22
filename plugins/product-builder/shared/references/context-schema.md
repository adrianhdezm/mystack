# Context Schema

`docs/context.json` schema is defined and maintained by the `project-bootstrapper` plugin.

See the canonical reference: [project-bootstrapper/shared/references/context-schema.md](../../../project-bootstrapper/shared/references/context-schema.md)

## Product Builder reads the following fields

- `repository.local_path` — working directory for all operations
- `project.name` — project name for documentation and feature planning
- `project.idea` — one-sentence product description (seed for PRD writing)
- `project.deployment_target` — `cloudflare` or `docker-postgres` (context for feature planning)
- `capabilities.*` — which capabilities are `ready` (set by project-bootstrapper foundation skills)

Product Builder skills read these fields but do not write `project.*` or `capabilities.*` — those are owned by project-bootstrapper.

## Product Builder writes the following fields

- Nothing to `project.*` or `capabilities.*`.
- Feature progress is tracked in `docs/features/manifest.json` (separate from context.json).
