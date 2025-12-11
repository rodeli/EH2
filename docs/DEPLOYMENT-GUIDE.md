# Deployment Guide - Escriturashoy 2.0

## Overview

This guide walks through deploying Escriturashoy 2.0 to staging on Cloudflare.

## Prerequisites

1. **Cloudflare Account**
   - Account with API token
   - Zone `escriturashoy.com` already exists
   - Permissions: DNS, D1, KV, R2, Workers, Pages

2. **GitHub Repository**
   - Repository: `rodeli/EH2`
   - Secrets configured (see below)

3. **Local Tools** (optional)
   - Terraform >= 1.6.0
   - Wrangler CLI
   - Node.js 18+

## Step 1: Configure GitHub Secrets

Go to: `https://github.com/rodeli/EH2/settings/secrets/actions`

Add the following secrets:
- `CLOUDFLARE_API_TOKEN` - Your Cloudflare API token
- `CLOUDFLARE_ACCOUNT_ID` - Your Cloudflare account ID
- `CLOUDFLARE_ZONE_ID` - Zone ID for escriturashoy.com

## Step 2: Deploy Infrastructure (Terraform)

### Option A: Via GitHub Actions (Recommended)

1. **Create a PR** with any change to `infra/cloudflare/**`
2. **Review the Terraform plan** in the PR comments
3. **Merge to main** - Terraform will apply automatically

### Option B: Manual Deployment

```bash
cd infra/cloudflare

# Create terraform.tfvars (do not commit)
cat > terraform.tfvars <<EOF
cloudflare_api_token = "your-api-token"
cloudflare_account_id = "your-account-id"
zone_id = "your-zone-id"
project_name = "escriturashoy"
environment = "staging"
EOF

# Initialize and apply
terraform init
terraform plan
terraform apply
```

**Resources Created:**
- D1 Database: `escriturashoy-staging-db`
- KV Namespace: `escriturashoy-staging-config`
- R2 Bucket: `esh-docs-staging`
- Pages Project: `escriturashoy-public-staging`
- DNS Records: `staging.escriturashoy.com`

## Step 3: Deploy API Worker

### First Time (Manual)

```bash
cd apps-api/workers

# Get database ID from Terraform output
cd ../../infra/cloudflare
terraform output d1_database_id

# Update wrangler.toml with the database_id (if not already done)
# Then deploy
cd ../../apps-api/workers
npm run deploy:staging
```

### Subsequent Deployments

Deployments will be automated via CI/CD, or manually:
```bash
cd apps-api/workers
npm run deploy:staging
```

**Worker URL:** `https://api-staging.escriturashoy.com`

## Step 4: Deploy Pages Projects

### Public Site

Pages will deploy automatically when:
- Terraform creates the project
- Code is pushed to main
- Or manually via Cloudflare dashboard

**URL:** `https://staging.escriturashoy.com`

### Client Portal (Future)

When ready, create Pages project for `apps/client`:
- Name: `escriturashoy-client-staging`
- Build command: `cd apps/client && npm install && npm run build`
- Root directory: `apps/client`
- Output directory: `dist`

### Admin Portal (Future)

When ready, create Pages project for `apps/admin`:
- Name: `escriturashoy-admin-staging`
- Build command: `cd apps/admin && npm install && npm run build`
- Root directory: `apps/admin`
- Output directory: `dist`
- **Important:** Protect with Cloudflare Zero Trust

## Step 5: Verify Deployment

### 1. Check Infrastructure

```bash
# List D1 databases
wrangler d1 list

# List KV namespaces
wrangler kv:namespace list

# List R2 buckets
wrangler r2 bucket list
```

### 2. Test API

```bash
# Health check
curl https://api-staging.escriturashoy.com/health

# Version
curl https://api-staging.escriturashoy.com/version

# Create lead
curl -X POST https://api-staging.escriturashoy.com/leads \
  -H "Content-Type: application/json" \
  -d '{
    "name": "Test User",
    "email": "test@example.com",
    "property_location": "Ciudad de México",
    "property_type": "casa"
  }'
```

### 3. Test Public Site

1. Visit `https://staging.escriturashoy.com`
2. Fill out lead form
3. Submit and verify success message
4. Check database for new lead:
   ```bash
   wrangler d1 execute escriturashoy-staging-db \
     --command="SELECT * FROM leads ORDER BY created_at DESC LIMIT 1;" \
     --remote
   ```

### 4. Verify Compliance

- [ ] Legal disclaimer visible on public site
- [ ] Privacy consent checkbox required
- [ ] Privacy policy link present
- [ ] Terms of service link present

## Troubleshooting

### Worker Not Deploying

- Check wrangler.toml configuration
- Verify database_id is correct
- Check Cloudflare dashboard for errors

### Pages Not Building

- Check build command in Terraform
- Verify package.json exists
- Check Pages build logs in Cloudflare dashboard

### Database Connection Issues

- Verify database_id in wrangler.toml
- Check database exists: `wrangler d1 list`
- Verify bindings are correct

### API Not Responding

- Check Worker is deployed
- Verify routes are configured
- Check Worker logs in Cloudflare dashboard

## Rollback

### Rollback Worker

```bash
cd apps-api/workers
wrangler rollback --env staging
```

### Rollback Terraform

```bash
cd infra/cloudflare
terraform plan  # Review changes
terraform apply  # Apply previous state
```

## Production Deployment

For production deployment:

1. **Create production environment** in Terraform
2. **Set up production secrets** in GitHub
3. **Configure production domains**
4. **Enable Zero Trust** for admin portal
5. **Set up monitoring and alerts**
6. **Configure backup and disaster recovery**

See `docs/ROADMAP.md` for production readiness requirements.

---

*Last updated: 2025-12-11*

