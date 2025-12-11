# Import Resources in CI

## Problem

Terraform in CI (GitHub Actions) is trying to create resources that already exist because:
- CI uses **local state** (separate from your local machine)
- Resources were created manually or in a previous run
- State wasn't shared between runs

## Solution Options

### Option 1: Use Remote State (Recommended for Production)

Configure Terraform to use R2 as a remote backend so state is shared:

1. **Create R2 bucket for state:**
   ```bash
   # Create bucket manually or via Terraform
   wrangler r2 bucket create terraform-state-escriturashoy
   ```

2. **Update `infra/cloudflare/main.tf`:**
   ```hcl
   terraform {
     backend "s3" {
       bucket   = "terraform-state-escriturashoy"
       key      = "cloudflare/terraform.tfstate"
       region   = "auto"
       endpoint = "https://<account-id>.r2.cloudflarestorage.com"
       # Use GitHub Secrets for credentials
     }
   }
   ```

3. **Add R2 credentials to GitHub Secrets:**
   - `R2_ACCESS_KEY_ID`
   - `R2_SECRET_ACCESS_KEY`

### Option 2: Import in CI (Quick Fix)

Use the manual workflow to import existing resources:

1. **Go to Actions:**
   - https://github.com/rodeli/EH2/actions/workflows/terraform-import.yml

2. **Click "Run workflow"**

3. **Enter:**
   - Account ID: Your Cloudflare Account ID
   - Zone ID: Your Cloudflare Zone ID

4. **The workflow will import:**
   - ✅ D1 database (automatic)
   - ✅ R2 bucket (automatic)
   - ⚠️  KV namespace (needs manual namespace ID)
   - ⚠️  DNS record (needs manual record ID)

### Option 3: Delete and Recreate (Simplest for Staging)

If you don't need to preserve existing resources:

1. **Delete resources in Cloudflare Dashboard:**
   - D1 database: https://dash.cloudflare.com → Workers & Pages → D1
   - KV namespace: https://dash.cloudflare.com → Workers & Pages → KV
   - R2 bucket: https://dash.cloudflare.com → R2
   - DNS record: https://dash.cloudflare.com → escriturashoy.com → DNS

2. **Run Terraform apply:**
   - Resources will be created fresh
   - No import needed

### Option 4: Add Import Step to Main Workflow

Add import commands to `.github/workflows/terraform.yml` before apply:

```yaml
- name: Import Existing Resources
  run: |
    terraform import cloudflare_d1_database.staging ${{ secrets.CLOUDFLARE_ACCOUNT_ID }}/c4d93a6a-1245-4a9f-9543-fa546f25d5c0 || true
    terraform import cloudflare_r2_bucket.docs ${{ secrets.CLOUDFLARE_ACCOUNT_ID }}/escriturashoy-staging-docs || true
  continue-on-error: true
  env:
    TF_VAR_cloudflare_api_token: ${{ secrets.CLOUDFLARE_API_TOKEN }}
    TF_VAR_cloudflare_account_id: ${{ secrets.CLOUDFLARE_ACCOUNT_ID }}
    TF_VAR_zone_id: ${{ secrets.CLOUDFLARE_ZONE_ID }}
    TF_VAR_environment: staging
    TF_VAR_project_name: escriturashoy
```

## Recommended Approach

For **staging**: Use **Option 3** (delete and recreate) - simplest and cleanest.

For **production**: Use **Option 1** (remote state) - proper state management.

---

*Last updated: 2025-12-11*

