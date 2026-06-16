# Foundation Capabilities

## Capability-to-Skill Mapping

Add foundation capabilities in dependency order based on the approved classification:

- `simple`: no foundation skills.
- `standard`: run `adding-database`, then `adding-authentication`.
- `advanced`: run `adding-database`, then `adding-authentication`, then `adding-file-storage`.

If `ai=yes`, run `adding-ai` after the classification-based skills above.

If `landing_page=yes`, run `adding-landing-page` after `ai` (or after classification-based skills if `ai=no`).

If `legal_pages=yes`, run `adding-legal-pages` after `adding-landing-page` (or after classification-based skills if `landing_page=no`).

## Documentation Updates

Each foundation skill updates the following files with its additions:

- `docs/architecture.md`
- `docs/data-model.md`
- `docs/conventions/`
- `AGENTS.md`

Verify each skill's doc updates before running the next skill.
