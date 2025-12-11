# Import All Existing Resources

## Issue

Terraform is trying to create resources that already exist, causing these errors:
- D1 database already exists
- KV namespace already exists  
- R2 bucket already exists
- DNS record already exists

## Solution: Import All Resources

### Quick Method: Use the Script

```bash
# Set your account ID (or it will prompt you)
export CLOUDFLARE_ACCOUNT_ID="your-account-id"

# Run the import script
./scripts/import-all-resources.sh
```

### Manual Method: Import Each Resource

#### 1. D1 Database

```bash
cd infra/cloudflare
terraform import cloudflare_d1_database.staging <account_id>/c4d93a6a-1245-4a9f-9543-fa546f25d5c0
```

#### 2. KV Namespace

**Get the namespace ID:**
- Go to: https://dash.cloudflare.com → Workers & Pages → KV
- Find: `escriturashoy-staging-config`
- Copy the Namespace ID

**Import:**
```bash
terraform import cloudflare_workers_kv_namespace.config <account_id>/<namespace_id>
```

**Or from command line:**
```bash
# Get namespace ID
wrangler kv:namespace list | grep "escriturashoy-staging-config"
# Then import with the ID
```

#### 3. R2 Bucket

```bash
terraform import cloudflare_r2_bucket.docs <account_id>/escriturashoy-staging-docs
```

#### 4. DNS Record

**Get the record ID:**
- Go to: https://dash.cloudflare.com → escriturashoy.com → DNS
- Find the `staging` CNAME record
- Click on it to see the Record ID in the URL or details

**Import:**
```bash
terraform import cloudflare_dns_record.staging_pages <zone_id>/<record_id>
```

**Or try by name/type:**
```bash
terraform import cloudflare_dns_record.staging_pages <zone_id>/staging/CNAME
```

## After Import

1. **Verify imports:**
   ```bash
   terraform plan
   ```
   
   You should see:
   - ✅ Imported resources: No changes
   - ⚠️  Remaining resources: Will be created (Pages project, etc.)

2. **Apply remaining resources:**
   ```bash
   terraform apply
   ```

## Troubleshooting

### "Resource already managed by Terraform"
- The resource is already in Terraform state
- Run `terraform plan` to see current state

### "Resource not found"
- The resource doesn't exist in Cloudflare
- Remove it from Terraform config or create it first

### "Invalid import ID"
- Check the import format matches the resource type
- D1: `account_id/database_id`
- KV: `account_id/namespace_id`
- R2: `account_id/bucket_name`
- DNS: `zone_id/record_id` or `zone_id/name/type`

---

*Last updated: 2025-12-11*

