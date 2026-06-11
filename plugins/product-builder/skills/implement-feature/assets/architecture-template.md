# Architecture

## Overview

One-line description of the product and its primary user.

## Stack

- Cloudflare Workers, TypeScript
- React Router v7 (framework mode, SSR)
- Drizzle ORM, Cloudflare D1
- Tailwind CSS, shadcn/ui
- Better Auth (if enabled)
- Cloudflare R2 (if enabled)

## Structure

```text
app/
├── components/        # Shared UI components
├── db/
│   ├── schema.ts      # Drizzle table definitions
│   ├── dao.ts         # Shared DAO interface
│   └── daos/          # One DAO per table
├── services/          # Business logic, transactions
├── routes/            # React Router route modules
└── lib/               # Utilities and helpers
db/
└── migrations/        # Drizzle migration files
docs/
├── architecture.md    # This file
├── data-model.md      # Entities, columns, relations
├── conventions/       # Project conventions (patterns + anti-patterns)
└── features/          # Feature specs
```

## Data Model

See [data-model.md](data-model.md) for the canonical entity, column, and relationship reference.

## Conventions

- **[Data Access](conventions/data-access.md)** — DAO interface, service layer, transactions
- **[UI Components](conventions/ui-components.md)** — shadcn/ui usage, component composition
- **[Form Validation](conventions/form-validation.md)** — Conform + Zod patterns
- **[Routes](conventions/routes.md)** — loader/action structure, protected routes, navigation

## Implementation Log

### NN — Feature Title

#### Design Decisions

- **Short title** — explanation of the choice made

#### Deviations

- **Short title** — where implementation departs from the spec, and why

#### Open Questions

- **Short title** — anything the user should confirm or revise
