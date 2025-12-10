# CI/CD Documentation

## Overview

This document describes the continuous integration and continuous deployment (CI/CD) pipelines for Escriturashoy 2.0.

## GitHub Actions Workflows

### Terraform Workflow (`.github/workflows/terraform.yml`)

**Purpose**: Manage Cloudflare infrastructure via Terraform

**Triggers**:
- Pull requests affecting `infra/cloudflare/**`
- Pushes to `main` branch affecting `infra/cloudflare/**`

**Jobs**:
1. **terraform-plan** (on PR):
   - Format check
   - Validation
   - Plan generation
   - PR comment with plan

2. **terraform-apply** (on main):
   - Validation
   - Plan
   - Apply (auto-approve)

**Secrets Required**:
- `CLOUDFLARE_API_TOKEN`
- `CLOUDFLARE_ACCOUNT_ID`
- `CLOUDFLARE_ZONE_ID`

### Application CI/CD (TBD)

Workflows for:
- Frontend applications (`apps/*`)
- API Workers (`apps-api/workers`)
- Tests and linting
- Deployment to staging/production

## Branch Protection

### Main Branch

- Protected branch
- Requires PR reviews
- Requires CI checks to pass
- No direct pushes (except via PR)

## Deployment Environments

### Staging

- Automatic deployment on merge to `main`
- Full staging environment on Cloudflare
- Accessible at staging subdomains

### Production

- Manual approval required
- Production environment on Cloudflare
- Accessible at production domains

## CI/CD Principles

- **GitOps**: All changes via PR
- **Automated Testing**: Tests run on every PR
- **Infrastructure as Code**: Terraform for all infra changes
- **Secrets Management**: Use GitHub Secrets, never commit secrets
- **Rollback**: Ability to rollback deployments

## Workflow Status

See GitHub Actions tab for current workflow status and history.

