# Deployment Guide

Complete guide for deploying Escriturashoy 2.0 to Cloudflare staging.

## Prerequisites

- GitHub repository: `rodeli/EH2`
- Cloudflare account with `escriturashoy.com` zone
- Access to GitHub repository settings
- Terraform >= 1.6.0 (for local deployment)

## Step 1: Configure GitHub Secrets ⚠️ REQUIRED

Before Terraform can run, configure these 3 secrets in GitHub:

### Quick Links
- **GitHub Secrets:** https://github.com/rodeli/EH2/settings/secrets/actions
- **Cloudflare API Tokens:** https://dash.cloudflare.com/profile/api-tokens
- **Cloudflare Dashboard:** https://dash.cloudflare.com/

### Secret 1: CLOUDFLARE_API_TOKEN

1. Go to: https://dash.cloudflare.com/profile/api-tokens
2. Click **"Create Token"**
3. Click **"Create Custom Token"**
4. Configure permissions:

   **Account Level:**
   - ✅ **Account** → **Cloudflare Pages** → **Edit**
   - ✅ **Account** → **Workers Scripts** → **Edit**
   - ✅ **Account** → **D1** → **Edit**
   - ✅ **Account** → **Workers KV Storage** → **Edit**
   - ✅ **Account** → **Workers R2 Storage** → **Edit** (this is R2)

   **Zone Level:**
   - ✅ **Zone** → **DNS** → **Edit** (select `escriturashoy.com`)
   - ✅ **Zone** → **Zone** → **Read** (select `escriturashoy.com`)

5. **Account Resources:** Include → **All accounts** (or select your account)
6. **Zone Resources:** Include → **Specific zone** → `escriturashoy.com`
7. Click **"Continue to summary"** → **"Create Token"**
8. **Copy the token immediately** (you won't see it again!)
9. Add to GitHub: Name = `CLOUDFLARE_API_TOKEN`, Value = your token

**Note:** In the Cloudflare UI, R2 permissions are listed as **"Workers R2 Storage"** (not "R2" or "Object Storage").

### Secret 2: CLOUDFLARE_ACCOUNT_ID

1. Go to: https://dash.cloudflare.com/
2. Select your account
3. **Account ID** is shown in the right sidebar
4. Or check the URL when viewing any resource
5. Add to GitHub: Name = `CLOUDFLARE_ACCOUNT_ID`, Value = your account ID

### Secret 3: CLOUDFLARE_ZONE_ID

1. Go to: https://dash.cloudflare.com/
2. Select the **`escriturashoy.com`** zone
3. Scroll down on Overview page
4. **Zone ID** is in the API section
5. Or check the URL when viewing the zone
6. Add to GitHub: Name = `CLOUDFLARE_ZONE_ID`, Value = your zone ID

See `docs/GITHUB-SECRETS-SETUP.md` for detailed instructions.

## Step 2: Deploy Infrastructure (Terraform)

### Automatic (Recommended)

Terraform runs automatically via GitHub Actions when you push to `main`:

1. **Push code:**
   ```bash
   git push origin main
   ```

2. **Monitor deployment:**
   - Go to: https://github.com/rodeli/EH2/actions
   - Watch the "Terraform Apply" workflow
   - The workflow automatically imports existing resources before applying

3. **Verify resources created:**
   - D1 Database: https://dash.cloudflare.com → Workers & Pages → D1
   - KV Namespace: https://dash.cloudflare.com → Workers & Pages → KV
   - R2 Bucket: https://dash.cloudflare.com → R2
   - Pages Project: https://dash.cloudflare.com → Pages
   - DNS Records: https://dash.cloudflare.com → escriturashoy.com → DNS

### Manual (Alternative)

If you prefer to run Terraform locally:

```bash
cd infra/cloudflare

# Initialize Terraform
terraform init

# Review changes
terraform plan

# Apply changes
terraform apply
```

**Note:** If resources already exist, you'll need to import them first. See `docs/IMPORT-RESOURCES.md`.

## Step 3: Deploy API Worker

After Terraform creates the D1 database:

1. **Get the database ID:**
   ```bash
   cd infra/cloudflare
   terraform output d1_database_id
   ```

2. **Update wrangler.toml** (if database_id changed):
   ```bash
   cd ../../apps-api/workers
   # Edit wrangler.toml and update database_id if needed
   ```

3. **Wait for DNS propagation:**
   - After Terraform creates the DNS record, wait 1-2 minutes for DNS propagation
   - Verify DNS record exists: `dig api-staging.escriturashoy.com` or check Cloudflare dashboard

4. **Deploy the Worker:**
   ```bash
   cd apps-api/workers
   npm run deploy:staging
   ```

   Or manually:
   ```bash
   wrangler deploy --env staging
   ```

   **Note:** The Worker route in `wrangler.toml` will use the DNS record created by Terraform.

5. **Verify deployment:**
   ```bash
   # Health check
   curl https://api-staging.escriturashoy.com/health

   # Version
   curl https://api-staging.escriturashoy.com/version
   ```

   **If you get "Could not resolve host":**
   - Wait for Terraform to create the DNS record (check GitHub Actions)
   - Wait 1-2 minutes for DNS propagation
   - Verify DNS record in Cloudflare dashboard
   - Then deploy the Worker

## Step 4: Deploy Pages

Pages should deploy automatically after Terraform creates the project, OR:

1. **Check Cloudflare Dashboard:**
   - Go to: https://dash.cloudflare.com/
   - Navigate to **Pages**
   - Find `escriturashoy-public-staging` project
   - Check deployment status

2. **Connect GitHub repository** (if not connected):
   - Click on the project
   - Go to **Settings** → **Builds & deployments**
   - Connect your GitHub repository
   - Configure build settings:
     - **Framework preset:** Vite
     - **Build command:** `npm run build`
     - **Build output directory:** `dist`
     - **Root directory:** `apps/public`

3. **Trigger deployment:**
   - Push to `main` branch, or
   - Manually trigger from Pages dashboard

## Step 5: Verify Deployment

### Test Public Site

1. **Visit:** https://staging.escriturashoy.com
2. **Verify:**
   - Landing page loads
   - Lead form is visible
   - Privacy consent checkbox works
   - Legal disclaimer checkbox works

### Test API

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
    "phone": "1234567890",
    "property_location": "Ciudad de México",
    "property_type": "casa",
    "urgency": "normal",
    "privacy_consent": true,
    "legal_disclaimer": true
  }'
```

### Check Database

```bash
cd apps-api/workers

# List all leads
wrangler d1 execute escriturashoy-staging-db \
  --command="SELECT * FROM leads ORDER BY created_at DESC LIMIT 5;" \
  --remote

# Count leads
wrangler d1 execute escriturashoy-staging-db \
  --command="SELECT COUNT(*) as total FROM leads;" \
  --remote
```

## Expected URLs

After deployment:
- **Public Site**: `https://staging.escriturashoy.com`
- **API**: `https://api-staging.escriturashoy.com`
- **Client Portal**: (To be configured)
- **Admin Portal**: (To be configured)

## Troubleshooting

### Terraform fails with "secret not found"
- Verify all 3 secrets are set in GitHub
- Check secret names match exactly (case-sensitive)
- Ensure you have admin access to the repository

### Terraform fails with "401 Unauthorized" or "403 Forbidden"
- Check API token has all required permissions
- Verify token hasn't been revoked
- See `docs/TERRAFORM-AUTH-FIX.md` for detailed troubleshooting

### Terraform fails with "resource already exists"
- Resources need to be imported into Terraform state
- See `docs/IMPORT-RESOURCES.md` for import instructions
- CI workflow automatically imports resources, but manual import may be needed for local runs

### Worker deployment fails
- Verify database exists: `wrangler d1 list`
- Check `database_id` in `wrangler.toml` matches the actual database ID
- Ensure API token has Workers Scripts:Edit permission
- Check Wrangler is authenticated: `wrangler whoami`

### Pages not deploying
- Check Cloudflare Pages project is created
- Verify build settings are correct
- Check build logs in Cloudflare dashboard
- Ensure GitHub repository is connected

### API returns 404 or errors
- Verify Worker is deployed: `wrangler deployments list`
- Check Worker logs: `wrangler tail --env staging`
- Verify database bindings in `wrangler.toml`

## Next Steps After Deployment

1. ✅ Test end-to-end lead flow
2. ✅ Create `/privacidad` page (privacy policy)
3. ✅ Create `/terminos` page (terms of service)
4. ✅ Add missing API endpoints (expedientes, etc.)
5. ✅ Set up monitoring and alerts
6. ✅ Configure production environment

## Related Documentation

- `docs/GITHUB-SECRETS-SETUP.md` - Detailed secrets setup
- `docs/TERRAFORM-AUTH-FIX.md` - Troubleshooting authentication errors
- `docs/IMPORT-RESOURCES.md` - Importing existing resources
- `docs/ARCHITECTURE.md` - System architecture overview

---

*Last updated: 2025-12-11*

