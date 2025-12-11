# Quick Import D1 Database

## Issue
Terraform is trying to create a D1 database that already exists, causing this error:
```
Database with name: 'escriturashoy-staging-db' already exists
```

## Solution: Import Existing Database

The database was created manually earlier. Import it into Terraform state.

### Step 1: Get Your Account ID

Find your Cloudflare Account ID:
- **Option A:** GitHub Secrets
  - Go to: https://github.com/rodeli/EH2/settings/secrets/actions
  - Look for `CLOUDFLARE_ACCOUNT_ID`
  
- **Option B:** Cloudflare Dashboard
  - Go to: https://dash.cloudflare.com/
  - Account ID is shown in the right sidebar
  - Or check the URL when viewing any resource

### Step 2: Import the Database

```bash
cd infra/cloudflare

# Replace <account_id> with your actual account ID
terraform import cloudflare_d1_database.staging <account_id>/c4d93a6a-1245-4a9f-9543-fa546f25d5c0
```

**Example:**
```bash
terraform import cloudflare_d1_database.staging abc123def456/c4d93a6a-1245-4a9f-9543-fa546f25d5c0
```

### Step 3: Verify Import

```bash
terraform plan
```

You should see:
- ✅ D1 database: No changes (already imported)
- ⚠️  Other resources: Will be created

### Step 4: Apply Remaining Resources

```bash
terraform apply
```

This will create:
- Pages project (once token has Pages permission)
- DNS records
- Any other missing resources

---

*Last updated: 2025-12-11*

