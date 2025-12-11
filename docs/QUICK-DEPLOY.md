# Quick Deployment Guide

Fastest path to get Escriturashoy 2.0 deployed to staging.

## Prerequisites Check

- [ ] GitHub repository: `rodeli/EH2`
- [ ] Cloudflare account with `escriturashoy.com` zone
- [ ] Access to GitHub repository settings

## Step 1: Configure GitHub Secrets (5 minutes)

1. **Get Cloudflare API Token:**
   - Go to: https://dash.cloudflare.com/profile/api-tokens
   - Create token with: DNS, Pages, Workers, D1, KV, R2 permissions
   - Copy token

2. **Get Account ID:**
   - Go to: https://dash.cloudflare.com/
   - Account ID is in right sidebar or URL

3. **Get Zone ID:**
   - Go to: https://dash.cloudflare.com/
   - Select `escriturashoy.com` zone
   - Zone ID is in Overview page API section

4. **Add to GitHub:**
   - Go to: `https://github.com/rodeli/EH2/settings/secrets/actions`
   - Add three secrets:
     - `CLOUDFLARE_API_TOKEN`
     - `CLOUDFLARE_ACCOUNT_ID`
     - `CLOUDFLARE_ZONE_ID`

See `docs/GITHUB-SECRETS-SETUP.md` for detailed instructions.

## Step 2: Push Code (if not already done)

```bash
cd /Users/ro/Code/mines/eh2
git push origin main
```

## Step 3: Apply Terraform (Automatic via CI)

When you push to `main`, the Terraform workflow will:
1. Run `terraform plan` on PR (if created)
2. Run `terraform apply` on merge to main

**Or manually:**
```bash
cd infra/cloudflare
terraform init
terraform plan  # Review changes
terraform apply  # Create resources
```

## Step 4: Deploy Worker

```bash
cd apps-api/workers

# Get database ID from Terraform output
cd ../../infra/cloudflare
terraform output d1_database_id

# Update wrangler.toml if database_id changed
# Then deploy
cd ../../apps-api/workers
npm run deploy:staging
```

## Step 5: Verify Deployment

1. **Check Public Site:**
   - Visit: `https://staging.escriturashoy.com`
   - Should show landing page

2. **Test API:**
   ```bash
   curl https://api-staging.escriturashoy.com/health
   ```

3. **Test Lead Form:**
   - Fill out form on public site
   - Submit and verify success
   - Check database:
     ```bash
     wrangler d1 execute escriturashoy-staging-db \
       --command="SELECT * FROM leads ORDER BY created_at DESC LIMIT 1;" \
       --remote
     ```

## Expected URLs

After deployment:
- **Public Site**: `https://staging.escriturashoy.com`
- **API**: `https://api-staging.escriturashoy.com`
- **Client Portal**: (To be configured)
- **Admin Portal**: (To be configured)

## Troubleshooting

### Terraform fails
- Check GitHub Secrets are set correctly
- Verify API token has all permissions
- Check account/zone IDs are correct

### Worker deployment fails
- Verify database_id in wrangler.toml
- Check database exists: `wrangler d1 list`
- Verify API token in Wrangler config

### Pages not deploying
- Check Terraform created Pages project
- Verify build command in Terraform
- Check Pages dashboard for errors

## Next Steps After Deployment

1. Test end-to-end lead flow
2. Create `/privacidad` page
3. Create `/terminos` page
4. Add missing API endpoints
5. Set up monitoring

---

*Quick reference guide - See `docs/DEPLOYMENT-GUIDE.md` for details*

