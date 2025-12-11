# Wrangler Setup Guide

## Overview

This guide explains how to configure Wrangler for local deployment after Terraform has created the infrastructure resources.

## Prerequisites

1. **Terraform has run successfully** (creates D1, KV, R2, DNS)
2. **Wrangler CLI installed:**
   ```bash
   npm install -g wrangler
   # OR use local version
   cd apps-api/workers
   npm install
   ```

3. **Authenticated with Cloudflare:**
   ```bash
   wrangler login
   # OR set API token
   export CLOUDFLARE_API_TOKEN="your-token"
   ```

## Step 1: Get Resource IDs

After Terraform applies successfully, get the resource IDs:

### Option A: Automated Script (Easiest) ⭐

Use the provided script to automatically query Cloudflare and update `wrangler.toml`:

```bash
./scripts/update-wrangler-config.sh
```

This script will:
1. Query Cloudflare via Wrangler for all resource IDs
2. Automatically update `wrangler.toml` with the correct IDs
3. Uncomment and configure all bindings

**Prerequisites:**
- Wrangler authenticated: `wrangler login`
- Terraform has created the resources
- `jq` installed (for JSON parsing): `brew install jq` (macOS) or `apt-get install jq` (Linux)

### Option B: From Terraform Output

```bash
cd infra/cloudflare
terraform output
```

This will show:
- `d1_database_id` - D1 database ID
- `kv_namespace_id` - KV namespace ID
- `r2_bucket_name` - R2 bucket name (already known)

### Option C: From Cloudflare Dashboard

1. **D1 Database ID:**
   - Go to: https://dash.cloudflare.com → Workers & Pages → D1
   - Click on `escriturashoy-staging-db`
   - Copy the Database ID from the URL or details page

2. **KV Namespace ID:**
   - Go to: https://dash.cloudflare.com → Workers & Pages → KV
   - Click on `escriturashoy-staging-config`
   - Copy the Namespace ID

3. **R2 Bucket Name:**
   - Already known: `escriturashoy-staging-docs`

### Option D: From GitHub Actions Output

After Terraform runs in CI, check the workflow output for resource IDs.

## Step 2: Update wrangler.toml

Edit `apps-api/workers/wrangler.toml` and uncomment/update the bindings:

```toml
[env.staging]
name = "escriturashoy-api-staging"
routes = [
  { pattern = "api-staging.escriturashoy.com/*", zone_name = "escriturashoy.com" }
]

# D1 Database binding
d1_databases = [
  {
    binding = "DB",
    database_name = "escriturashoy-staging-db",
    database_id = "YOUR_D1_DATABASE_ID_HERE"  # ← Replace this
  }
]

# KV Namespace binding
kv_namespaces = [
  {
    binding = "CONFIG",
    id = "YOUR_KV_NAMESPACE_ID_HERE"  # ← Replace this
  }
]

# R2 Bucket binding
r2_buckets = [
  {
    binding = "DOCS",
    bucket_name = "escriturashoy-staging-docs"  # ← Already correct
  }
]

# Environment variables
[env.staging.vars]
ENVIRONMENT = "staging"
VERSION = "0.1.0"
```

## Step 3: Verify Configuration

### Check Wrangler Authentication

```bash
wrangler whoami
```

Should show your Cloudflare account email.

### List Resources (Optional)

```bash
# List D1 databases
wrangler d1 list

# List KV namespaces
wrangler kv:namespace list

# List R2 buckets
wrangler r2 bucket list
```

## Step 4: Deploy Worker

```bash
cd apps-api/workers
npm run deploy:staging
```

Or manually:
```bash
wrangler deploy --env staging
```

## Step 5: Verify Deployment

### Check Worker Status

```bash
wrangler deployments list --env staging
```

### Test API Endpoints

```bash
# Health check
curl https://api-staging.escriturashoy.com/health

# Version
curl https://api-staging.escriturashoy.com/version

# Create test lead
curl -X POST https://api-staging.escriturashoy.com/leads \
  -H "Content-Type: application/json" \
  -d '{
    "name": "Test User",
    "email": "test@example.com",
    "property_location": "Ciudad de México",
    "property_type": "casa",
    "privacy_consent": true,
    "legal_disclaimer": true
  }'
```

### View Worker Logs

```bash
wrangler tail --env staging
```

## Troubleshooting

### "Database not found"

**Error:** `Error: D1 database 'escriturashoy-staging-db' not found`

**Fix:**
1. Verify Terraform created the database
2. Check `database_id` in `wrangler.toml` matches Terraform output
3. Verify you're using the correct Cloudflare account

### "KV namespace not found"

**Error:** `Error: KV namespace not found`

**Fix:**
1. Verify Terraform created the KV namespace
2. Check `id` in `wrangler.toml` matches Terraform output
3. Verify namespace ID is correct

### "Could not resolve host: api-staging.escriturashoy.com"

**Error:** `curl: (6) Could not resolve host`

**Fix:**
1. Wait for Terraform to create DNS record
2. Wait 1-2 minutes for DNS propagation
3. Verify DNS record in Cloudflare dashboard
4. Check DNS: `dig api-staging.escriturashoy.com`

### "Route already exists"

**Error:** `Route already exists for api-staging.escriturashoy.com`

**Fix:**
- This is normal if the Worker was previously deployed
- Wrangler will update the existing route

### "Unauthorized" or "Forbidden"

**Error:** `401 Unauthorized` or `403 Forbidden`

**Fix:**
1. Re-authenticate: `wrangler login`
2. Verify API token has required permissions:
   - Workers Scripts:Edit
   - D1:Edit
   - Workers KV Storage:Edit
   - Workers R2 Storage:Edit

## Automation (Future)

We could automate this by:
1. Creating a script that reads Terraform outputs
2. Automatically updating `wrangler.toml` with resource IDs
3. Running as part of CI/CD pipeline

See `scripts/update-wrangler-db.sh` for an example.

## Environment Variables

You can also set environment variables via Wrangler secrets:

```bash
# Set a secret
wrangler secret put MY_SECRET --env staging

# List secrets
wrangler secret list --env staging
```

**Note:** Secrets are not stored in `wrangler.toml` for security.

## Next Steps

After successful deployment:
1. ✅ Test all API endpoints
2. ✅ Verify database connectivity
3. ✅ Test lead form on public site
4. ✅ Check admin portal loads data
5. ✅ Monitor Worker logs for errors

---

*Last updated: 2025-12-11*

