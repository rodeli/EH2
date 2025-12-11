# Data Model Documentation

## Overview

This document describes the data model for Escriturashoy 2.0, including database schemas, relationships, and data flow.

## Database: Cloudflare D1

The primary transactional database is Cloudflare D1, a SQLite-compatible database.

## Core Entities

### Users

User accounts for system access (admin, staff, etc.).

**Schema**: See `db/schema/core.md` for detailed schema definitions.

### Clients

Client records representing customers using the platform.

**Schema**: See `db/schema/core.md` for detailed schema definitions.

### Leads

Lead records from marketing intake forms.

**Schema**: See `db/schema/core.md` for detailed schema definitions.

**Status Flow**: `nuevo` → `contactado` → `convertido` or `perdido`

### Expedientes

Case records representing real estate transactions.

**Schema**: See `db/schema/core.md` for detailed schema definitions.

**Status Flow**: `inicial` → `documentacion` → `revision` → `firma` → `cerrado` (or `cancelado` at any stage)

### Documents

Document metadata and references.

**Schema**: TBD - To be added in future migration.

**Storage**: Files stored in Cloudflare R2, metadata in D1.

## Relationships

See `db/schema/core.md` for the complete Entity Relationship Diagram (ERD).

**Key Relationships:**
- Users → Clients (1:N) - A user can have multiple client records
- Clients → Expedientes (1:N) - A client can have multiple expedientes
- Leads → Expedientes (1:1) - A lead can be converted to an expediente

## Data Retention

TBD - Retention policies to be defined per compliance requirements (NOM-151, LFPDPPP).

## Migrations

All schema changes are managed via migrations in `db/migrations/`.

**Current Migrations:**
- `001_initial_schema.sql` - Initial core schema (users, clients, leads, expedientes)

See `db/migrations/README.md` for migration guidelines and how to run migrations.

## Schema Documentation

For complete schema documentation including:
- Entity Relationship Diagrams
- Table definitions with all columns
- Indexes
- Status enums
- Data types

See: `db/schema/core.md`

