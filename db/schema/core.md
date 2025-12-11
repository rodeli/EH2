# Core Data Model

This document describes the core database schema for Escriturashoy 2.0.

## Overview

The core entities represent the fundamental business objects in the Escriturashoy platform:
- **Users**: System users (admin, staff)
- **Clients**: Customers using the platform
- **Leads**: Potential clients from marketing intake
- **Expedientes**: Real estate transaction cases

## Entity Relationship Diagram

```
┌─────────────┐
│    Users    │
│─────────────│
│ id (PK)     │
│ email       │
│ name        │
│ role        │
│ created_at  │
│ updated_at  │
└─────────────┘
       │
       │ (1:N)
       ▼
┌─────────────┐
│   Clients   │
│─────────────│
│ id (PK)     │
│ user_id (FK)│
│ name        │
│ email       │
│ phone       │
│ created_at  │
│ updated_at  │
└─────────────┘
       │
       │ (1:N)
       ▼
┌─────────────┐      ┌─────────────┐
│   Leads     │─────▶│ Expedientes│
│─────────────│      │─────────────│
│ id (PK)     │      │ id (PK)     │
│ name        │      │ client_id   │
│ email       │      │ lead_id (FK)│
│ phone       │      │ property_   │
│ property_   │      │   location │
│   location  │      │ type        │
│ property_   │      │ status      │
│   type      │      │ created_at │
│ urgency     │      │ updated_at│
│ created_at   │      └─────────────┘
│ updated_at   │
└─────────────┘
```

## Tables

### users

System users (admin, staff, internal users).

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| id | TEXT | PRIMARY KEY | UUID v4 |
| email | TEXT | UNIQUE, NOT NULL | User email address |
| name | TEXT | NOT NULL | Full name |
| role | TEXT | NOT NULL | Role: 'admin', 'staff', 'viewer' |
| created_at | INTEGER | NOT NULL | Unix timestamp |
| updated_at | INTEGER | NOT NULL | Unix timestamp |

**Indexes:**
- `idx_users_email` on `email`

### clients

Client records representing customers using the platform.

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| id | TEXT | PRIMARY KEY | UUID v4 |
| user_id | TEXT | FOREIGN KEY → users.id | Associated user account (nullable) |
| name | TEXT | NOT NULL | Client full name |
| email | TEXT | NOT NULL | Client email |
| phone | TEXT | | Client phone number |
| created_at | INTEGER | NOT NULL | Unix timestamp |
| updated_at | INTEGER | NOT NULL | Unix timestamp |

**Indexes:**
- `idx_clients_email` on `email`
- `idx_clients_user_id` on `user_id`

### leads

Lead records from marketing intake forms.

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| id | TEXT | PRIMARY KEY | UUID v4 |
| name | TEXT | NOT NULL | Lead name |
| email | TEXT | NOT NULL | Lead email |
| phone | TEXT | | Lead phone number |
| property_location | TEXT | NOT NULL | Property address/location |
| property_type | TEXT | NOT NULL | Type: 'casa', 'departamento', 'terreno', 'comercial' |
| urgency | TEXT | | Urgency level: 'alta', 'media', 'baja' |
| status | TEXT | NOT NULL | Status: 'nuevo', 'contactado', 'convertido', 'perdido' |
| notes | TEXT | | Internal notes |
| created_at | INTEGER | NOT NULL | Unix timestamp |
| updated_at | INTEGER | NOT NULL | Unix timestamp |

**Indexes:**
- `idx_leads_email` on `email`
- `idx_leads_status` on `status`
- `idx_leads_created_at` on `created_at`

### expedientes

Case records representing real estate transactions.

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| id | TEXT | PRIMARY KEY | UUID v4 |
| client_id | TEXT | FOREIGN KEY → clients.id | Associated client |
| lead_id | TEXT | FOREIGN KEY → leads.id | Original lead (nullable) |
| property_location | TEXT | NOT NULL | Property address/location |
| type | TEXT | NOT NULL | Transaction type: 'compraventa', 'donacion', 'sucesion', etc. |
| status | TEXT | NOT NULL | Status: 'inicial', 'documentacion', 'revision', 'firma', 'cerrado', 'cancelado' |
| metadata | TEXT | | JSON metadata (additional fields) |
| created_at | INTEGER | NOT NULL | Unix timestamp |
| updated_at | INTEGER | NOT NULL | Unix timestamp |

**Indexes:**
- `idx_expedientes_client_id` on `client_id`
- `idx_expedientes_status` on `status`
- `idx_expedientes_created_at` on `created_at`

## Status Enums

### Lead Status
- `nuevo` - New lead, not yet contacted
- `contactado` - Lead has been contacted
- `convertido` - Lead converted to client
- `perdido` - Lead lost/not interested

### Expediente Status
- `inicial` - Initial stage, gathering information
- `documentacion` - Collecting required documents
- `revision` - Documents under review
- `firma` - Ready for signing
- `cerrado` - Transaction completed
- `cancelado` - Transaction cancelled

### Property Types
- `casa` - House
- `departamento` - Apartment
- `terreno` - Land
- `comercial` - Commercial property

## Data Types

- **TEXT**: SQLite TEXT type (used for all strings, UUIDs, JSON)
- **INTEGER**: SQLite INTEGER type (used for timestamps)

## Timestamps

All tables use Unix timestamps (seconds since epoch) stored as INTEGER:
- `created_at`: Set on record creation
- `updated_at`: Updated on every record modification

## UUIDs

All primary keys use UUID v4 format (36 characters including hyphens):
- Example: `550e8400-e29b-41d4-a716-446655440000`

## Notes

- D1 (Cloudflare's SQLite-compatible database) is used
- Foreign key constraints are enforced at application level (D1 doesn't support FK constraints)
- JSON metadata fields allow flexibility for future schema evolution
- All timestamps are in UTC

