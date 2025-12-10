# Escriturashoy 2.0

A Cloudflare-first, GitOps-driven legal-tech platform for digital real estate transactions in Mexico.

## Overview

Escriturashoy 2.0 is a complete rebuild of the Escriturashoy platform, designed to streamline the process of digital real estate transactions (escrituras digitales) while ensuring compliance with Mexican regulations (NOM-151, LFPDPPP).

## Architecture

- **External Infrastructure**: Cloudflare (Pages, Workers, KV, D1, R2, Queues, Zero Trust)
- **Internal Infrastructure**: 1.00.ge VMs for logging, observability, and internal tools
- **Deployment Model**: GitOps via GitHub Actions, Infrastructure as Code (Terraform)
- **Agent-Based Development**: AI agents with defined scopes and responsibilities (see `docs/AGENTS.md`)

## Repository Structure

```
├── apps/              # Frontend applications
│   ├── public/       # Marketing & public-facing site
│   ├── client/       # Client portal/dashboard
│   └── admin/        # Internal backoffice
├── apps-api/         # Backend API (Cloudflare Workers)
│   └── workers/      # Worker implementations
├── db/               # Database schemas and migrations
│   ├── migrations/   # D1 migration files
│   └── schema/       # Schema documentation
├── docs/             # Documentation
│   ├── ADR/          # Architecture Decision Records
│   ├── RUNBOOKS/     # Operational runbooks
│   ├── AGENTS.md     # AI agent role definitions
│   ├── ARCHITECTURE.md # System architecture
│   └── ROADMAP.md    # Technical roadmap
└── infra/            # Infrastructure as Code
    ├── cloudflare/   # Cloudflare resources (Terraform)
    └── 100ge/        # 1.00.ge internal infrastructure
```

## Getting Started

### Prerequisites

- Node.js 18+ (for local development)
- Terraform >= 1.5.0 (for infrastructure)
- Cloudflare account with API token
- GitHub account with repository access

### Local Development

1. **Clone the repository**
   ```bash
   git clone <repository-url>
   cd eh2
   ```

2. **Set up Cloudflare infrastructure** (see `infra/cloudflare/README.md`)
   ```bash
   cd infra/cloudflare
   terraform init
   # Configure terraform.tfvars (not committed)
   terraform plan
   ```

3. **Set up local development environment**
   - Each app in `apps/` and `apps-api/` may have its own setup instructions
   - See individual app READMEs (when available)

### Documentation

- **[AGENTS.md](docs/AGENTS.md)**: AI agent roles and responsibilities
- **[ROADMAP.md](docs/ROADMAP.md)**: Technical roadmap and milestones
- **[ARCHITECTURE.md](docs/ARCHITECTURE.md)**: System architecture details
- **[Cloudflare Infrastructure](infra/cloudflare/README.md)**: Cloudflare setup guide

## Development Workflow

1. **All changes via Pull Requests** - Never push directly to `main`
2. **Follow agent scopes** - See `docs/AGENTS.md` for role definitions
3. **Infrastructure changes** - Managed via Terraform in `infra/cloudflare/`
4. **CI/CD** - Automated via GitHub Actions (see `.github/workflows/`)

## Key Principles

- **GitOps**: All infrastructure and code changes via PR
- **Infrastructure as Code**: Terraform for Cloudflare, Ansible/Terraform for 1.00.ge
- **Security First**: No secrets in code, use CI secrets and secure stores
- **Compliance**: Adhere to NOM-151, LFPDPPP, and other Mexican regulations
- **Agent-Driven**: Development follows agent role definitions in `docs/AGENTS.md`

## Contributing

1. Read `docs/AGENTS.md` to understand agent roles
2. Check `docs/ROADMAP.md` for current priorities
3. Create a feature branch
4. Make changes following the appropriate agent scope
5. Submit a PR with clear description
6. Ensure CI checks pass

## Status

See `docs/ROADMAP.md` for current milestone status and task tracking.

## License

[To be determined]

## Support

For questions or issues, please open a GitHub issue or contact the team.

