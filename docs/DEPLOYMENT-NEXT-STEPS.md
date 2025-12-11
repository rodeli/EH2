# Deployment Next Steps

## Current Status

✅ **Step 1 Complete:** GitHub Secrets configured
✅ **Step 2 In Progress:** Terraform deployment triggered

## Monitor Terraform Deployment

1. **Check GitHub Actions:**
   - Go to: https://github.com/rodeli/EH2/actions
   - Look for the "Terraform Apply" workflow
   - Wait for it to complete (usually 2-5 minutes)

2. **Verify Resources Created:**
   Once Terraform completes, verify these resources exist in Cloudflare:
   - D1 Database: `escriturashoy-staging-db`
   - KV Namespace: `escriturashoy-staging-config`
   - R2 Bucket: `esh-docs-staging`
   - Pages Project: `escriturashoy-public-staging`

## Step 3: Update Worker Configuration

After Terraform completes, update `wrangler.toml` with the D1 database ID:

### Option A: Automatic (Recommended)

```bash
# Run the helper script
./scripts/update-wrangler-db.sh
```

This script will:
1. Get the database ID from Terraform output
2. Update `wrangler.toml` automatically
3. Show you the next steps

### Option B: Manual

1. **Get database ID from Terraform:**
   ```bash
   cd infra/cloudflare
   terraform output d1_database_id
   ```

2. **Or get from Cloudflare Dashboard:**
   - Go to: https://dash.cloudflare.com
   - Navigate to: Workers & Pages → D1
   - Find: `escriturashoy-staging-db`
   - Copy the Database ID

3. **Update wrangler.toml:**
   - Open: `apps-api/workers/wrangler.toml`
   - Uncomment the `d1_databases` section
   - Replace `YOUR_D1_DATABASE_ID` with the actual ID

## Step 4: Deploy API Worker

Once `wrangler.toml` is updated:

```bash
cd apps-api/workers
npm run deploy:staging
```

Expected output:
```
✨ Compiled Worker successfully
✨ Uploaded escriturashoy-api-staging
✨ Deployed to https://api-staging.escriturashoy.com/*
```

## Step 5: Verify Worker Deployment

Test the API endpoints:

```bash
# Health check
curl https://api-staging.escriturashoy.com/health

# Should return: {"status":"ok"}

# Version
curl https://api-staging.escriturashoy.com/version

# Should return: {"version":"0.1.0","environment":"staging"}
```

## Step 6: Deploy Pages

Pages should deploy automatically, but you can verify:

1. **Check Cloudflare Dashboard:**
   - Go to: Workers & Pages → Pages
   - Find: `escriturashoy-public-staging`
   - Check deployment status

2. **If not deployed automatically:**
   - Connect GitHub repository in Pages settings
   - Set build configuration:
     - Root directory: `apps/public`
     - Build command: `npm run build`
     - Output directory: `dist`

3. **Verify site is live:**
   - Visit: `https://staging.escriturashoy.com`
   - Test the lead form

## Troubleshooting

### Terraform Failed

- Check GitHub Actions logs for errors
- Verify all 3 secrets are set correctly
- Check API token has required permissions
- Review Terraform plan output

### Worker Deployment Fails

- Verify database ID is correct in `wrangler.toml`
- Check database exists in Cloudflare dashboard
- Ensure API token has Workers Scripts:Edit permission
- Check wrangler authentication: `wrangler whoami`

### Pages Not Deploying

- Verify Pages project was created by Terraform
- Check build settings in Cloudflare dashboard
- Review build logs for errors
- Ensure `package.json` exists in `apps/public`

---

*Last updated: 2025-12-11*

