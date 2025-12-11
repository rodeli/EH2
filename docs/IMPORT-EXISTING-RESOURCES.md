# Import Existing Resources into Terraform

## Issue

Some Cloudflare resources were created manually (e.g., D1 database via `scripts/create-database.sh`) and now Terraform is trying to create them again, causing conflicts.

## Solution: Import Existing Resources

### D1 Database

The database `escriturashoy-staging-db` already exists. Import it into Terraform state:

```bash
cd infra/cloudflare

# Get the database ID from Cloudflare dashboard or wrangler
# Database ID format: xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx

# Import the existing database
terraform import cloudflare_d1_database.staging <account_id>/<database_id>
```

**To find the database ID:**
1. Go to: https://dash.cloudflare.com
2. Navigate to: Workers & Pages → D1
3. Find: `escriturashoy-staging-db`
4. Copy the Database ID

**Or from command line:**
```bash
cd apps-api/workers
wrangler d1 list
# Look for escriturashoy-staging-db and copy the ID
```

**Then import:**
```bash
cd infra/cloudflare
terraform import cloudflare_d1_database.staging <account_id>/<database_id>
```

### KV Namespace (if exists)

If KV namespace already exists:
```bash
terraform import cloudflare_workers_kv_namespace.config <account_id>/<namespace_id>
```

### R2 Bucket (if exists)

If R2 bucket already exists:
```bash
terraform import cloudflare_r2_bucket.docs <account_id>/<bucket_name>
```

## After Import

1. Run `terraform plan` to verify no conflicts
2. Run `terraform apply` to create remaining resources
3. Terraform will now manage the imported resources

## Alternative: Remove and Recreate

If you prefer to start fresh:

1. **Delete existing resources manually:**
   - Go to Cloudflare dashboard
   - Delete the D1 database, KV namespace, etc.

2. **Run Terraform apply:**
   ```bash
   cd infra/cloudflare
   terraform apply
   ```

   Terraform will create everything fresh.

---

*Last updated: 2025-12-11*

