# Database Migrations

This directory contains D1 database migration files for Escriturashoy 2.0.

## Migration Files

- `001_initial_schema.sql` - Initial core schema (users, clients, leads, expedientes)

## Running Migrations

### Local Development

Using Wrangler:

```bash
cd apps-api/workers
wrangler d1 execute escriturashoy-staging-db --file=../../db/migrations/001_initial_schema.sql --remote
```

Or for local:

```bash
wrangler d1 execute escriturashoy-staging-db --file=../../db/migrations/001_initial_schema.sql --local
```

### CI/CD

Migrations should be run as part of the deployment process. See `.github/workflows/` for migration automation.

## Migration Naming Convention

- Format: `NNN_description.sql`
- Example: `001_initial_schema.sql`, `002_add_documents_table.sql`
- Use sequential numbers (001, 002, 003, ...)
- Use descriptive names with underscores

## Migration Guidelines

1. **Always use IF NOT EXISTS** for tables and indexes to make migrations idempotent
2. **Include rollback instructions** in migration comments when possible
3. **Test migrations** on staging before production
4. **Never modify existing migrations** - create new ones instead
5. **Document breaking changes** in migration comments

## Schema Documentation

See `db/schema/core.md` for detailed schema documentation and ERD.

