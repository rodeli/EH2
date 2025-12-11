# Deployment Architecture - Wrangler vs Terraform

## Overview

This document explains the division of responsibilities between **Terraform** (infrastructure) and **Wrangler** (application deployment).

## Terraform (GitHub Actions) - Infrastructure Resources

Terraform creates and manages **infrastructure resources** in Cloudflare:

### Resources Created by Terraform

1. **D1 Database** (`escriturashoy-staging-db`)
   - Database instance
   - Managed in: `infra/cloudflare/d1.tf`

2. **KV Namespace** (`escriturashoy-staging-config`)
   - Key-value storage namespace
   - Managed in: `infra/cloudflare/kv.tf`

3. **R2 Bucket** (`escriturashoy-staging-docs`)
   - Object storage bucket
   - Managed in: `infra/cloudflare/r2.tf`

4. **Pages Project** (`escriturashoy-public-staging`)
   - Pages project for static site hosting
   - Managed in: `infra/cloudflare/pages.tf`

5. **Pages Custom Domain** (`staging.escriturashoy.com`)
   - Custom domain for Pages project
   - Automatically creates DNS record
   - Managed in: `infra/cloudflare/pages.tf`

6. **DNS Records**
   - `api-staging.escriturashoy.com` CNAME record
   - Managed in: `infra/cloudflare/zone.tf`

### When Terraform Runs

- **Automatically:** On push to `main` branch (via GitHub Actions)
- **Manually:** Can be triggered from GitHub Actions UI
- **Location:** Runs in GitHub Actions runners (remote)

## Wrangler (Local) - Application Code

Wrangler deploys the **Worker application code** to Cloudflare:

### What Wrangler Deploys

1. **Worker Script** (`src/index.ts`)
   - The actual JavaScript/TypeScript code
   - Compiled and uploaded to Cloudflare
   - Contains all API endpoint logic

2. **Worker Route** (`api-staging.escriturashoy.com/*`)
   - Routes traffic from the domain to the Worker
   - Uses the DNS record created by Terraform
   - Configured in: `wrangler.toml` → `routes`

3. **Bindings** (references to Terraform resources)
   - **D1 Database binding** (`DB`)
     - References the database created by Terraform
     - Uses `database_id` from Terraform output
   - **KV Namespace binding** (`CONFIG`)
     - References the KV namespace created by Terraform
     - Uses `namespace_id` from Terraform output
   - **R2 Bucket binding** (`DOCS`)
     - References the R2 bucket created by Terraform
     - Uses bucket name from Terraform

4. **Environment Variables**
   - `ENVIRONMENT = "staging"`
   - `VERSION = "0.1.0"`
   - Configured in: `wrangler.toml` → `[env.staging.vars]`

### What Wrangler Does NOT Create

❌ **Does NOT create:**
- D1 database (Terraform creates this)
- KV namespace (Terraform creates this)
- R2 bucket (Terraform creates this)
- DNS records (Terraform creates this)
- Pages projects (Terraform creates this)

✅ **Only deploys:**
- Worker code/script
- Worker route configuration
- Bindings to existing resources

### When Wrangler Runs

- **Manually:** Run locally with `npm run deploy:staging`
- **Location:** Runs on your local machine
- **Requires:** 
  - Wrangler CLI installed (`npm install -g wrangler` or via `npm install`)
  - Authenticated with Cloudflare (`wrangler login` or API token)

## Deployment Flow

### Step 1: Infrastructure (Terraform)
```bash
# Runs automatically in GitHub Actions
# OR manually trigger from GitHub Actions UI
```

**Creates:**
- D1 database
- KV namespace
- R2 bucket
- DNS records
- Pages project

### Step 2: Application (Wrangler)
```bash
cd apps-api/workers
npm run deploy:staging
```

**Deploys:**
- Worker code
- Worker route
- Binds to resources created in Step 1

## Configuration Files

### Terraform Configuration
- **Location:** `infra/cloudflare/*.tf`
- **Main files:**
  - `d1.tf` - D1 database
  - `kv.tf` - KV namespace
  - `r2.tf` - R2 bucket
  - `pages.tf` - Pages project
  - `zone.tf` - DNS records

### Wrangler Configuration
- **Location:** `apps-api/workers/wrangler.toml`
- **Contains:**
  - Worker name
  - Routes
  - Bindings (references to Terraform resources)
  - Environment variables

## Important Notes

### 1. Resource IDs Must Match

The bindings in `wrangler.toml` must reference the **exact same resources** created by Terraform:

```toml
# wrangler.toml
[env.staging]
d1_databases = [
  { 
    binding = "DB", 
    database_name = "escriturashoy-staging-db",  # Must match Terraform
    database_id = "..."  # Get from Terraform output
  }
]
```

### 2. DNS Record Must Exist First

The DNS record for `api-staging.escriturashoy.com` must be created by Terraform **before** deploying the Worker. Otherwise, the Worker route won't work.

### 3. Bindings Are References

Wrangler bindings don't create resources - they **reference** resources that already exist (created by Terraform).

### 4. Worker Route vs DNS Record

- **DNS Record** (Terraform): Points `api-staging.escriturashoy.com` to Cloudflare
- **Worker Route** (Wrangler): Routes traffic from that domain to your Worker code

Both are needed for the API to work.

## Troubleshooting

### "Could not resolve host: api-staging.escriturashoy.com"
- **Cause:** DNS record doesn't exist yet
- **Fix:** Wait for Terraform to create the DNS record

### "Database not found"
- **Cause:** Database doesn't exist or wrong `database_id` in `wrangler.toml`
- **Fix:** 
  1. Verify Terraform created the database
  2. Get `database_id` from Terraform output
  3. Update `wrangler.toml` with correct ID

### "Worker route failed"
- **Cause:** DNS record doesn't exist or Worker not deployed
- **Fix:**
  1. Ensure Terraform created DNS record
  2. Deploy Worker with `wrangler deploy --env staging`

## Summary

| Resource | Created By | Managed By |
|----------|-----------|------------|
| D1 Database | Terraform | Terraform |
| KV Namespace | Terraform | Terraform |
| R2 Bucket | Terraform | Terraform |
| DNS Records | Terraform | Terraform |
| Pages Project | Terraform | Terraform |
| Worker Code | Wrangler | Wrangler |
| Worker Route | Wrangler | Wrangler |
| Bindings | Wrangler (references) | Wrangler |

**Key Principle:** Terraform creates infrastructure, Wrangler deploys code that uses that infrastructure.

---

*Last updated: 2025-12-11*

