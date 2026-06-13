# Architecture

## Overview

One-line description of the product and its primary user.

## Stack

- Cloudflare Workers, TypeScript
- React Router v7 (framework mode, SSR)
- Tailwind CSS, shadcn/ui

<!-- Foundation skills append to this list: Drizzle ORM / D1, Better Auth, Cloudflare R2. -->

## Structure

```text
app/
├── components/        # Shared UI components
├── routes/            # React Router route modules
└── lib/               # Utilities and helpers
docs/
├── vision.md          # Product vision and pitch
├── architecture.md    # This file
├── conventions/       # Project conventions (patterns + anti-patterns)
└── features/          # Feature specs
```

<!-- Foundation skills extend this tree with db/, services/, db/migrations/, etc. -->

## Data Model

See [data-model.md](data-model.md) for the canonical entity, column, and relationship reference.

<!-- Remove this section if no database is configured. -->

## Conventions

Project-specific patterns and anti-patterns. Each file covers one area and grows as implementation reveals patterns worth reusing or mistakes worth preventing.

<!-- List only conventions that exist. Foundation and implementation skills add entries here as they create convention files. -->

## Implementation Log

### NN — Feature Title

#### Design Decisions

- **Short title** — explanation of the choice made

#### Deviations

- **Short title** — where implementation departs from the spec, and why

#### Open Questions

- **Short title** — anything the user should confirm or revise
