# Data Model

Canonical reference for all database entities, columns, types, relationships, and constraints. This file always represents what is built, not what is planned.

## Entity Name

- `id` (text, PK) — UUID
- `name` (text, not null) — display name
- `createdAt` / `updatedAt` (integer, not null) — timestamps

**Relations**: belongs to OtherEntity; has many Items.
