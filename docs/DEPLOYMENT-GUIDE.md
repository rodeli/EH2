# Staging Deployment Guide

## Step 1: Configure GitHub Secrets ⚠️ REQUIRED

Before Terraform can run, you must configure these 3 secrets in GitHub:

### Quick Links
- **GitHub Secrets:** https://github.com/rodeli/EH2/settings/secrets/actions
- **Cloudflare API Tokens:** https://dash.cloudflare.com/profile/api-tokens
- **Cloudflare Dashboard:** https://dash.cloudflare.com/

### Secret 1: CLOUDFLARE_API_TOKEN

1. Go to: https://dash.cloudflare.com/profile/api-tokens
2. Click **"Create Token"**
3. Use **"Edit zone DNS"** template OR create custom token with:
   - **Zone:** DNS:Edit, Zone:Read
   - **Account:** Cloudflare Pages:Edit, Workers Scripts:Edit, D1:Edit, Workers KV Storage:Edit, R2:Edit
4. **Copy the token** (you won't see it again!)
5. Add to GitHub: Name = `CLOUDFLARE_API_TOKEN`, Value = your token

### Secret 2: CLOUDFLARE_ACCOUNT_ID

1. Go to: https://dash.cloudflare.com/
2. Select your account
3. **Account ID** is in the right sidebar
4. Add to GitHub: Name = `CLOUDFLARE_ACCOUNT_ID`, Value = your account ID

### Secret 3: CLOUDFLARE_ZONE_ID

1. Go to: https://dash.cloudflare.com/
2. Select the **`escriturashoy.com`** zone
3. Scroll down on Overview page
4. **Zone ID** is in the API section
5. Add to GitHub: Name = `CLOUDFLARE_ZONE_ID`, Value = your zone ID

---

## Step 2: Trigger Terraform Deployment

Once secrets are configured, Terraform will run automatically when:
- Code is pushed to `main` branch
- OR you can create a PR to see the plan first

### Option A: Automatic (Recommended)
1. Make a small change to trigger workflow:
   ```bash
   # Create a trigger commit
   git commit --allow-empty -m "chore: Trigger Terraform deployment"
   git push origin main
   ```
2. Go to: https://github.com/rodeli/EH2/actions
3. Watch the "Terraform Apply" workflow run
4. Verify resources are created

### Option B: Manual Terraform (Alternative)
If you prefer to run Terraform locally:
```bash
cd infra/cloudflare
terraform init
terraform plan
terraform apply
```

---

## Step 3: Deploy API Worker

After Terraform creates the D1 database:

1. **Get the database ID** from Terraform output or Cloudflare dashboard
2. **Update wrangler.toml** with the database ID:
   ```toml
   [env.staging]
   d1_databases = [
     { binding = "DB", database_name = "escriturashoy-staging-db", database_id = "YOUR_DATABASE_ID" }
   ]
   ```
3. **Deploy the Worker:**
   ```bash
   cd apps-api/workers
   npm run deploy:staging
   ```
   Or if the script doesn't exist:
   ```bash
   wrangler deploy --env staging
   ```

---

## Step 4: Deploy Pages

Pages should deploy automatically via Cloudflare Pages integration, OR:

1. Go to: https://dash.cloudflare.com/
2. Navigate to **Pages** → **Create a project**
3. Connect your GitHub repository
4. Configure build settings:
   - **Framework preset:** Vite
   - **Build command:** `npm run build`
   - **Build output directory:** `dist`
   - **Root directory:** `apps/public` (for public site)

Repeat for `apps/client` and `apps/admin` if needed.

---

## Step 5: Verify Deployment

### Test Public Site
- Visit: `https://staging.escriturashoy.com`
- Verify lead form loads
- Submit a test lead
- Check database for the lead

### Test API
```bash
# Health check
curl https://api-staging.escriturashoy.com/health

# Version
curl https://api-staging.escriturashoy.com/version

# Create lead
curl -X POST https://api-staging.escriturashoy.com/leads \
  -H "Content-Type: application/json" \
  -d '{"name":"Test User","email":"test@example.com","phone":"1234567890","property_location":"Test City","property_type":"casa","urgency":"normal","privacy_consent":true,"legal_disclaimer":true}'
```

### Check Database
```bash
cd apps-api/workers
wrangler d1 execute escriturashoy-staging-db \
  --command="SELECT * FROM leads LIMIT 5;" \
  --remote
```

---

## Troubleshooting

### Terraform fails with "secret not found"
- Verify all 3 secrets are set in GitHub
- Check secret names match exactly (case-sensitive)

### Worker deployment fails
- Verify database exists in Cloudflare dashboard
- Check database_id in wrangler.toml matches
- Ensure API token has Workers Scripts:Edit permission

### Pages not deploying
- Check Cloudflare Pages project is created
- Verify build settings are correct
- Check build logs in Cloudflare dashboard

---

*Last updated: 2025-12-11*
