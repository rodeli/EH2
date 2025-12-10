# Architecture Documentation

## Overview

Escriturashoy 2.0 is a modern, cloud-native platform for managing digital real estate transactions (escrituras digitales) in Mexico. The system is built on Cloudflare's edge computing platform with internal observability infrastructure on 1.00.ge.

> **Note:** This architecture follows an agent-based development model. See [`docs/AGENTS.md`](AGENTS.md) for agent role definitions and scopes.

## System Architecture

### High-Level Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                    Cloudflare Edge Network                   │
│                                                             │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐     │
│  │   Pages      │  │   Workers    │  │   Zero Trust │     │
│  │ (apps/public)│  │ (apps-api)   │  │   Access     │     │
│  └──────────────┘  └──────────────┘  └──────────────┘     │
│                                                             │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐     │
│  │   D1 DB      │  │   KV Store    │  │   R2 Storage │     │
│  │ (Transactional)│ │ (Config/Flags)│ │  (Documents) │     │
│  └──────────────┘  └──────────────┘  └──────────────┘     │
└─────────────────────────────────────────────────────────────┘
                            │
                            │ Logpush
                            ▼
┌─────────────────────────────────────────────────────────────┐
│              1.00.ge Internal Infrastructure                │
│                                                             │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐     │
│  │  Logging     │  │ Observability │  │  Cloudflare  │     │
│  │  Stack       │  │  Dashboards   │  │   Tunnel     │     │
│  └──────────────┘  └──────────────┘  └──────────────┘     │
└─────────────────────────────────────────────────────────────┘
```

### Application Architecture

#### Frontend Applications

- **`apps/public`**: Marketing site and public-facing content
  - Built with modern frontend framework (TBD)
  - Deployed via Cloudflare Pages
  - Static site generation with dynamic lead capture

- **`apps/client`**: Client portal
  - Authenticated client dashboard
  - Expediente status tracking
  - Document upload and review
  - Deployed via Cloudflare Pages

- **`apps/admin`**: Internal backoffice
  - Admin dashboard for managing expedientes
  - Lead management
  - User and role management
  - Deployed via Cloudflare Pages with Zero Trust access

#### Backend API

- **`apps-api/workers`**: Cloudflare Workers
  - RESTful API endpoints
  - Business logic for workflows (intake → KYC → docs → signing → closing)
  - Integration with D1, KV, and R2
  - Routes:
    - `/health` - Health check
    - `/version` - Version info
    - `/leads` - Lead management
    - `/expedientes` - Expediente management
    - `/auth` - Authentication (TBD)

### Data Architecture

#### D1 Database (Cloudflare)

Primary transactional database for:
- Users and authentication
- Clients
- Leads
- Expedientes (cases)
- Documents metadata
- Workflow state

See `db/schema/` for detailed schema documentation.

#### KV Store (Cloudflare)

Key-value storage for:
- Feature flags
- Configuration
- Session data (if needed)
- Cache

#### R2 Storage (Cloudflare)

Object storage for:
- Document files (PDFs, images)
- Signed documents
- Temporary uploads

### Infrastructure Components

#### Cloudflare Resources

- **DNS**: Managed via Terraform
- **Pages**: Frontend deployments
- **Workers**: API and edge logic
- **D1**: SQLite-compatible database
- **KV**: Key-value storage
- **R2**: S3-compatible object storage
- **Zero Trust**: Access control for admin/internal resources
- **Logpush**: Log aggregation to R2

#### 1.00.ge Infrastructure

- **VMs**: Internal servers for logging and observability
- **Cloudflare Tunnel**: Secure access to internal services
- **Logging Stack**: Centralized log aggregation and analysis
- **Monitoring**: Dashboards and alerting

### Security Architecture

- **Zero Trust**: All admin/internal access via Cloudflare Zero Trust
- **Secrets Management**: CI secrets, no hardcoded credentials
- **Compliance**: NOM-151, LFPDPPP compliance built-in
- **Data Encryption**: At rest and in transit
- **Access Control**: Role-based access control (RBAC)

### Deployment Architecture

#### Environments

- **Staging**: Full staging environment on Cloudflare
- **Production**: Production environment (TBD)

#### CI/CD Pipeline

- **GitHub Actions**: Automated CI/CD
- **Terraform**: Infrastructure provisioning
- **Wrangler**: Workers and Pages deployment
- **GitOps**: All changes via PR, no direct pushes to main

### Workflow Architecture

#### Core Business Workflows

1. **Lead Intake**
   - Lead capture form → API → D1
   - Initial qualification
   - Assignment to expediente

2. **Expediente Management**
   - Create expediente
   - KYC verification
   - Document collection
   - Signing process
   - Closing and completion

3. **Document Management**
   - Upload to R2
   - Metadata in D1
   - Version control
   - Access control

### Observability

- **Logging**: Cloudflare Logpush → R2 → 1.00.ge logging stack
- **Metrics**: Cloudflare Analytics + custom metrics
- **Tracing**: Request tracing across Workers
- **Alerting**: Automated alerts for errors, latency, availability

### Technology Stack

- **Frontend**: TBD (React/Next.js likely)
- **Backend**: Cloudflare Workers (JavaScript/TypeScript)
- **Database**: Cloudflare D1 (SQLite-compatible)
- **Storage**: Cloudflare R2 (S3-compatible)
- **Infrastructure**: Terraform
- **CI/CD**: GitHub Actions
- **Monitoring**: Cloudflare Analytics + 1.00.ge stack

## Design Decisions

See `docs/ADR/` for Architecture Decision Records documenting key technical decisions.

## Future Considerations

- Multi-region deployment
- Advanced caching strategies
- Real-time updates (WebSockets/SSE)
- Mobile applications
- Integration with external services (notaries, banks, etc.)
