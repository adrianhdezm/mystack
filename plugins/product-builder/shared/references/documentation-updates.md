# Documentation Updates for Add-On Skills

After an add-on skill finishes its core work, update project documentation using this process. Each step says "if it does not exist, create it" — the file may already exist from a prior skill.

## docs/architecture.md

Add the new capability to the Stack section. If adding directories, extend the Structure tree. If adding a new convention file, add a linked entry in the Conventions section.

If `docs/architecture.md` does not exist, create it using [architecture-template.md](../templates/architecture-template.md) and fill in the additions.

## docs/data-model.md

Add new entities with their columns, types, and relationships to match `app/db/schema.ts`.

If `docs/data-model.md` does not exist, create it using [data-model-template.md](../templates/data-model-template.md).

## docs/conventions/

If the skill introduces patterns worth reusing, add or update the relevant convention file. Use [convention-template.md](../templates/convention-template.md) when creating a new file. Add a linked entry in the Conventions section of `docs/architecture.md` for any new convention file.

After `adding-database` sets up integration testing, create `docs/conventions/testing.md` using the convention template. Seed it with patterns from [testing-conventions.md](testing-conventions.md): directory structure, test type inference, `applyMigrations`/`getTestDb` import patterns, component test patterns, and layer-specific testing guidance.

## README.md

Add setup instructions, required environment variables, and relevant commands for the new capability.

## AGENTS.md

Add skill-specific agent instructions (environment variables, commands, behavior). Ensure the Project Documentation section exists and references `docs/`. Include `pnpm test` in the listed verification commands when testing is set up.
