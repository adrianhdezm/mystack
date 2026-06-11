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
└── features/          # Feature specs
```

## Data Model

### Entity Name

- `id` (text, PK) — UUID
- `name` (text, not null) — display name
- `createdAt` / `updatedAt` (integer, not null) — timestamps

**Relations**: belongs to OtherEntity; has many Items.

## Conventions

### Data Access

### UI Components

### Form Validation

### Routes

## Anti-patterns

### Data Access

### UI Components

### Form Validation

### Routes

## Implementation Log

### NN — Feature Title

#### Design Decisions

- **Short title** — explanation of the choice made

#### Deviations

- **Short title** — where implementation departs from the spec, and why

#### Open Questions

- **Short title** — anything the user should confirm or revise
