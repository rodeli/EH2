# Deployment Action Plan

## ✅ Step 1: Code Committed & Pushed

**Status:** ✅ Complete
- Commit: `b0065e5` - "feat: Complete Milestone 3"
- 65 files changed, 11,255 insertions
- Pushed to `main` branch

## 📋 Step 2: Configure GitHub Secrets

**Action Required:** You need to add 3 secrets to GitHub

### Quick Steps:

1. **Go to GitHub Secrets:**
   ```
   https://github.com/rodeli/EH2/settings/secrets/actions
   ```

2. **Add these 3 secrets:**

   **Secret 1: CLOUDFLARE_API_TOKEN**
   - Get from: https://dash.cloudflare.com/profile/api-tokens
   - Create token with permissions: DNS, Pages, Workers, D1, KV, R2
   - Copy and paste into GitHub

   **Secret 2: CLOUDFLARE_ACCOUNT_ID**
   - Get from: https://dash.cloudflare.com/ (right sidebar)
   - Copy Account ID

   **Secret 3: CLOUDFLARE_ZONE_ID**
   - Get from: Cloudflare dashboard → escriturashoy.com zone → Overview
   - Copy Zone ID from API section

See `docs/GITHUB-SECRETS-SETUP.md` for detailed instructions.

## 🚀 Step 3: Trigger Terraform Deployment

Once secrets are configured, Terraform will run automatically on the next push, OR:

### Option A: Create a PR (Recommended)
```bash
git checkout -b deploy/staging
# Make a small change (like updating a comment)
git commit -m "chore: trigger Terraform deployment"
git push origin deploy/staging
# Create PR on GitHub
```

### Option B: Push to main (if branch protection allows)
The Terraform workflow will run automatically when you push to main.

### Option C: Manual Terraform Apply
```bash
cd infra/cloudflare
terraform init
terraform plan
terraform apply
```

## 📊 Step 4: Monitor Deployment

1. **Check GitHub Actions:**
   - Go to: `https://github.com/rodeli/EH2/actions`
   - Watch the "Terraform" workflow
   - Review the Terraform plan output

2. **Verify Resources Created:**
   After Terraform applies, verify:
   - D1 Database exists
   - KV Namespace exists
   - R2 Bucket exists
   - Pages Project created
   - DNS records created

## 🔧 Step 5: Deploy API Worker

After Terraform creates resources:

```bash
cd apps-api/workers

# Get database ID from Terraform
cd ../../infra/cloudflare
terraform output d1_database_id

# Update wrangler.toml if database_id is different
# (It should already be set from earlier)

# Deploy Worker
cd ../../apps-api/workers
npm run deploy:staging
```

## 🌐 Step 6: Verify Pages Deployment

Pages should deploy automatically after Terraform creates the project.

1. **Check Cloudflare Dashboard:**
   - Go to: https://dash.cloudflare.com/
   - Navigate to Pages
   - Find `escriturashoy-public-staging` project
   - Check deployment status

2. **Or trigger manually:**
   - Connect GitHub repo to Pages project
   - Or deploy via Wrangler/CLI

## ✅ Step 7: Test Everything

### Test Public Site
```bash
# Visit in browser
open https://staging.escriturashoy.com
```

### Test API
```bash
# Health check
curl https://api-staging.escriturashoy.com/health

# Create a test lead
curl -X POST https://api-staging.escriturashoy.com/leads \
  -H "Content-Type: application/json" \
  -d '{
    "name": "Test User",
    "email": "test@example.com",
    "property_location": "Ciudad de México",
    "property_type": "casa"
  }'
```

### Verify Database
```bash
wrangler d1 execute escriturashoy-staging-db \
  --command="SELECT COUNT(*) as total FROM leads;" \
  --remote
```

## 🎯 Current Status

- ✅ Code committed and pushed
- ⏳ GitHub Secrets (action required)
- ⏳ Terraform apply (will run after secrets)
- ⏳ Worker deployment (after Terraform)
- ⏳ Pages deployment (automatic or manual)
- ⏳ End-to-end testing

## Next Actions

**IMMEDIATE:**
1. Configure GitHub Secrets (see Step 2 above)
2. Trigger Terraform (create PR or push)
3. Monitor deployment

**AFTER DEPLOYMENT:**
1. Test lead form end-to-end
2. Verify all endpoints work
3. Check compliance elements
4. Create privacy/terms pages

---

*Ready to deploy! Configure secrets and proceed.*

