# Cloudflare Infrastructure as Code

This directory contains Terraform configurations for managing all Cloudflare resources for Escriturashoy.

> **Note:** This file was updated to trigger Terraform deployment workflow.

## Prerequisites

1. Cloudflare account with API token
2. Terraform >= 1.6.0
3. Cloudflare zone `escriturashoy.com` must already exist

## Required Variables

The following variables must be provided (via environment variables, `.tfvars` files, or CI secrets):

- `cloudflare_api_token` - Cloudflare API token with appropriate permissions
- `cloudflare_account_id` - Your Cloudflare account ID
- `zone_id` - Zone ID for escriturashoy.com (can be found in Cloudflare dashboard)

## Setup

1. Initialize Terraform:
```bash
cd infra/cloudflare
terraform init
```

2. Create a `terraform.tfvars` file (do not commit this):
```hcl
cloudflare_api_token = "your-api-token"
cloudflare_account_id = "your-account-id"
zone_id = "your-zone-id"
environment = "staging"
```

3. Plan changes:
```bash
terraform plan
```

4. Apply changes:
```bash
terraform apply
```

## Resources Managed

- **DNS Zone**: Data source for existing escriturashoy.com zone
- **DNS Records**: Staging subdomain CNAME for Pages
- **Pages Project**: Staging Pages project for `apps/public`
- **D1 Database**: Staging database instance
- **KV Namespace**: Workers KV namespace for configs/feature flags
- **R2 Bucket**: R2 bucket for document storage

## State Management

Currently using local backend. For production, configure remote state using:
- Cloudflare R2 (S3-compatible)
- Terraform Cloud
- Other remote backends

See `main.tf` for commented backend configuration example.

## CI/CD

Terraform is managed via GitHub Actions:
- `terraform plan` runs on pull requests
- `terraform apply` runs on merge to main branch

See `.github/workflows/terraform.yml` for workflow configuration.

# Terraform validation fix
# Deployment trigger
