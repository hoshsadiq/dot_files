---
name: guideline-database-migrations
description: "Database migration guidelines using Flyway: immutability, naming, rollback, and testing."
---

# Database Migrations Guidelines

This project uses **Flyway** for database schema migrations.

## Core Principles

### 1. Migrations are Immutable

**NEVER delete or modify existing migration files.** Flyway tracks which migrations have been applied via a checksum. Changing or deleting a migration that has already run will cause failures.

```
# WRONG - Never do this
rm V1__CreateUserTable.sql

# WRONG - Never modify existing migrations
# Editing V1__CreateUserTable.sql after it's been applied
```

### 2. To Remove Schema Objects, Create New Migrations

When you need to drop tables, columns, or other schema objects, create a **new migration** with the next version number:

```sql
-- V6__DropExampleTable.sql
DROP TABLE IF EXISTS example;
```

### 3. Migration Naming Convention

```
V{version}__{Description}.sql
```

- `V` prefix is required
- Version is a number (can include dots: `V1.1__`)
- Double underscore `__` separates version from description
- Description uses PascalCase or snake_case
- Must end with `.sql`

Examples:
- `V1__CreateUserTable.sql`
- `V2__AddEmailColumnToUser.sql`
- `V3__DropLegacyTable.sql`

### 4. Migration Locations

| Location | Purpose |
|----------|---------|
| `src/main/resources/db/migration/{module}/` | Production migrations - immutable once deployed |
| `src/test/resources/db/migration/{module}/` | Test-only migrations - can be modified for ephemeral test DBs |

### 5. Test vs Production Migrations

**Production migrations** (`src/main/resources/`):
- Must never be deleted or modified
- Changes require new migration files
- Tracked in Flyway schema history

**Test migrations** (`src/test/resources/`):
- Used with Testcontainers (ephemeral databases)
- Can be deleted if the table/schema is no longer needed
- No persistent Flyway history to maintain

## Common Scenarios

### Adding a New Table

```sql
-- V5__CreateOrdersTable.sql
CREATE TABLE orders (
    id UUID PRIMARY KEY,
    customer_id UUID NOT NULL,
    total DECIMAL(10,2) NOT NULL,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);
```

### Dropping a Table (Cleanup)

```sql
-- V6__DropExampleTable.sql
-- Cleanup: Remove scaffolding table no longer in use
DROP TABLE IF EXISTS example;
```

### Adding a Column

```sql
-- V7__AddStatusToOrders.sql
ALTER TABLE orders ADD COLUMN status VARCHAR(50) DEFAULT 'PENDING';
```

### Removing a Column

```sql
-- V8__DropLegacyColumnFromOrders.sql
ALTER TABLE orders DROP COLUMN IF EXISTS legacy_field;
```

## Checklist Before Committing Migrations

- [ ] New migration has the correct next version number
- [ ] No existing migrations were modified or deleted
- [ ] Migration is idempotent where possible (`IF EXISTS`, `IF NOT EXISTS`)
- [ ] Migration tested locally with `./gradlew flywayMigrate` or via integration tests
- [ ] For drops/deletes: confirmed no code depends on the removed schema
