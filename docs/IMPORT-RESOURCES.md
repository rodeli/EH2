# Import Existing Cloudflare Resources

## Overview

When Terraform tries to create resources that already exist in Cloudflare, you'll see errors like:
- `Database with name: 'escriturashoy-staging-db' already exists`
- `A namespace with this account ID and title already exists`
- `The bucket you tried to create already exists`

This guide covers how to import existing resources into Terraform state.

## Quick Start

### Automated Import (Recommended)

Use the provided script:

```bash
# Set environment variables (or script will prompt)
export CLOUDFLARE_ACCOUNT_ID="your-account-id"
export CLOUDFLARE_ZONE_ID="your-zone-id"

# Run the import script
./scripts/import-all-resources.sh
```

### CI/CD Automatic Import

The Terraform CI workflow automatically imports existing resources before applying. No manual action needed - imports happen automatically on each run.

## Import Formats

### D1 Database

**Format:** `account_id/database_id`

```bash
terraform import cloudflare_d1_database.staging <account_id>/c4d93a6a-1245-4a9f-9543-fa546f25d5c0
```

**Find Database ID:**
- Cloudflare Dashboard: https://dash.cloudflare.com → Workers & Pages → D1
- Command line: `wrangler d1 list | grep "escriturashoy-staging-db"`

### R2 Bucket

**Format:** `account_id/bucket_name/jurisdiction`

```bash
terraform import cloudflare_r2_bucket.docs <account_id>/escriturashoy-staging-docs/default
```

**Note:** Jurisdiction is usually `default`. If you get an error, check your bucket's jurisdiction in the Cloudflare dashboard.

### KV Namespace

**Format:** `account_id/namespace_id`

```bash
terraform import cloudflare_workers_kv_namespace.config <account_id>/<namespace_id>
```

**Find Namespace ID:**
- Cloudflare Dashboard: https://dash.cloudflare.com → Workers & Pages → KV
- Command line: `wrangler kv:namespace list | grep "escriturashoy-staging-config"`
- Or use: `./scripts/get-resource-ids.sh`

### Pages Project

**Format:** `account_id/project_name`

```bash
terraform import cloudflare_pages_project.public_staging <account_id>/escriturashoy-public-staging
```

### Pages Domain

**Format:** `account_id/project_name/domain_name`

```bash
terraform import cloudflare_pages_domain.public_staging_domain <account_id>/escriturashoy-public-staging/staging.escriturashoy.com
```

### DNS Record

**Note:** DNS records for Pages custom domains are automatically managed by `cloudflare_pages_domain`. No manual DNS record import needed.

If you have a manual DNS record that conflicts, delete it from the Cloudflare dashboard and let the Pages domain resource manage it.

## Manual Import Steps

1. **Get your IDs:**
   ```bash
   # Use the helper script
   export CLOUDFLARE_API_TOKEN="your-token"
   export CLOUDFLARE_ACCOUNT_ID="your-account-id"
   export CLOUDFLARE_ZONE_ID="your-zone-id"
   ./scripts/get-resource-ids.sh
   ```

2. **Navigate to Terraform directory:**
   ```bash
   cd infra/cloudflare
   ```

3. **Import each resource:**
   ```bash
   # D1 Database
   terraform import cloudflare_d1_database.staging $ACCOUNT_ID/c4d93a6a-1245-4a9f-9543-fa546f25d5c0

   # R2 Bucket
   terraform import cloudflare_r2_bucket.docs $ACCOUNT_ID/escriturashoy-staging-docs/default

   # Pages Project
   terraform import cloudflare_pages_project.public_staging $ACCOUNT_ID/escriturashoy-public-staging

   # Pages Domain
   terraform import cloudflare_pages_domain.public_staging_domain $ACCOUNT_ID/escriturashoy-public-staging/staging.escriturashoy.com

   # KV Namespace (get ID first)
   terraform import cloudflare_workers_kv_namespace.config $ACCOUNT_ID/<namespace_id>

   # DNS Record (get ID first)
   terraform import cloudflare_dns_record.staging_pages $ZONE_ID/<record_id>
   ```

4. **Verify imports:**
   ```bash
   terraform plan
   ```

   You should see:
   - ✅ Imported resources: No changes
   - ⚠️  Remaining resources: Will be created

5. **Apply remaining resources:**
   ```bash
   terraform apply
   ```

## CI/CD Import

The Terraform workflow (`.github/workflows/terraform.yml`) automatically:
1. Fetches KV namespace and DNS record IDs via Cloudflare API
2. Imports all existing resources before applying
3. Handles import errors gracefully (continues if already imported)

No manual action needed - imports happen automatically on each CI run.

## Troubleshooting

### "Resource already managed by Terraform"
- The resource is already in Terraform state
- Run `terraform state list` to see all managed resources
- Run `terraform plan` to see current state

### "Resource not found"
- The resource doesn't exist in Cloudflare
- Remove it from Terraform config or create it first

### "Invalid import ID"
- Check the import format matches the resource type:
  - D1: `account_id/database_id`
  - KV: `account_id/namespace_id`
  - R2: `account_id/bucket_name/jurisdiction` ⚠️ **Note: includes jurisdiction**
  - Pages Project: `account_id/project_name`
  - Pages Domain: `account_id/project_name/domain_name`
  - DNS: `zone_id/record_id`

### Import succeeds but resource still tries to create
- Check Terraform state: `terraform state list`
- Verify the resource name in state matches your config
- Try `terraform refresh` to sync state

## Alternative: Delete and Recreate

If you don't need to preserve existing resources:

1. **Delete resources in Cloudflare Dashboard:**
   - D1: https://dash.cloudflare.com → Workers & Pages → D1
   - KV: https://dash.cloudflare.com → Workers & Pages → KV
   - R2: https://dash.cloudflare.com → R2
   - Pages: https://dash.cloudflare.com → Pages
   - DNS: https://dash.cloudflare.com → escriturashoy.com → DNS

2. **Run Terraform apply:**
   ```bash
   cd infra/cloudflare
   terraform apply
   ```

   Resources will be created fresh - no import needed.

## Remote State (Production)

For production, consider using remote state to share state between CI runs:

1. **Create R2 bucket for state:**
   ```bash
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
     }
   }
   ```

3. **Add R2 credentials to GitHub Secrets:**
   - `R2_ACCESS_KEY_ID`
   - `R2_SECRET_ACCESS_KEY`

With remote state, imports only need to happen once, and state is shared across all runs.

---

*Last updated: 2025-12-11*

