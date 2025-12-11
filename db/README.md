# Database

This directory contains database schemas and migrations for Escriturashoy 2.0.

## Structure

- `schema/` - Schema documentation and ERDs
- `migrations/` - D1 migration SQL files

## Database: Cloudflare D1

Escriturashoy uses Cloudflare D1, a SQLite-compatible edge database.

### Resources

- **Staging**: `escriturashoy-staging-db` (managed via Terraform)
- **Production**: TBD

## Schema Documentation

See `schema/core.md` for:
- Entity relationship diagrams
- Table definitions
- Indexes
- Status enums
- Data types

## Migrations

See `migrations/README.md` for:
- How to run migrations
- Migration naming conventions
- Migration guidelines

## Quick Start

1. **View schema**: `cat schema/core.md`
2. **Run migration**: See `migrations/README.md`
3. **Query database**: Use D1 API or Wrangler CLI

