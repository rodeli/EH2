# Data Model Documentation

## Overview

This document describes the data model for Escriturashoy 2.0, including database schemas, relationships, and data flow.

## Database: Cloudflare D1

The primary transactional database is Cloudflare D1, a SQLite-compatible database.

## Core Entities

### Users

User accounts for system access (admin, staff, etc.).

**Schema**: TBD - See `db/schema/` for detailed schema definitions.

### Clients

Client records representing customers using the platform.

**Schema**: TBD - See `db/schema/` for detailed schema definitions.

### Leads

Lead records from marketing intake forms.

**Schema**: TBD - See `db/schema/` for detailed schema definitions.

### Expedientes

Case records representing real estate transactions.

**Schema**: TBD - See `db/schema/` for detailed schema definitions.

**Status Flow**: TBD

### Documents

Document metadata and references.

**Schema**: TBD - See `db/schema/` for detailed schema definitions.

**Storage**: Files stored in Cloudflare R2, metadata in D1.

## Relationships

TBD - ERD to be added when schemas are defined.

## Data Retention

TBD - Retention policies to be defined per compliance requirements.

## Migrations

All schema changes are managed via migrations in `db/migrations/`.

See migration files for detailed change history.

