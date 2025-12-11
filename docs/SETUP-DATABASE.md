# Database Setup Guide

## Overview

The D1 database needs to be created before running migrations. You have two options:

1. **Create via Terraform** (Recommended) - Creates all infrastructure including database
2. **Create manually via Wrangler** - Quick setup for development

## Option 1: Create via Terraform (Recommended)

This creates the database along with all other Cloudflare resources.

### Prerequisites

1. Terraform >= 1.6.0 installed
2. Cloudflare API token with D1 permissions
3. Cloudflare account ID and zone ID

### Steps

1. **Navigate to Terraform directory:**
   ```bash
   cd infra/cloudflare
   ```

2. **Create terraform.tfvars** (do not commit):
   ```hcl
   cloudflare_api_token = "your-api-token"
   cloudflare_account_id = "your-account-id"
   zone_id = "your-zone-id"
   project_name = "escriturashoy"
   environment = "staging"
   ```

3. **Initialize Terraform:**
   ```bash
   terraform init
   ```

4. **Plan changes:**
   ```bash
   terraform plan
   ```

5. **Apply (creates database):**
   ```bash
   terraform apply
   ```

6. **Get database ID:**
   ```bash
   terraform output d1_database_id
   ```

7. **Update wrangler.toml** with the database ID:
   ```toml
   [env.staging]
   d1_databases = [
     { binding = "DB", database_name = "escriturashoy-staging-db", database_id = "YOUR_DATABASE_ID_HERE" }
   ]
   ```

## Option 2: Create Manually via Wrangler

For quick local development setup.

### Steps

1. **Create the database:**
   ```bash
   wrangler d1 create escriturashoy-staging-db
   ```

   This will output something like:
   ```
   ✅ Successfully created DB 'escriturashoy-staging-db' in region WEUR
   Created your database using D1's new storage backend. The new storage backend is not yet recommended for production workloads, but backs up your data via snapshots to R2.

   [[d1_databases]]
   binding = "DB"
   database_name = "escriturashoy-staging-db"
   database_id = "abc123def456..."
   ```

2. **Update wrangler.toml** with the database_id from the output:
   ```toml
   [env.staging]
   d1_databases = [
     { binding = "DB", database_name = "escriturashoy-staging-db", database_id = "abc123def456..." }
   ]
   ```

3. **Run the migration:**
   ```bash
   cd apps-api/workers
   wrangler d1 execute escriturashoy-staging-db --file=../../db/migrations/001_initial_schema.sql --remote
   ```

   For local development:
   ```bash
   wrangler d1 execute escriturashoy-staging-db --file=../../db/migrations/001_initial_schema.sql --local
   ```

## Verify Database Creation

Check that the database exists:

```bash
wrangler d1 list
```

You should see `escriturashoy-staging-db` in the list.

## Running Migrations

After the database is created, run migrations:

### Remote (staging/production):
```bash
cd apps-api/workers
wrangler d1 execute escriturashoy-staging-db --file=../../db/migrations/001_initial_schema.sql --remote
```

### Local (development):
```bash
cd apps-api/workers
wrangler d1 execute escriturashoy-staging-db --file=../../db/migrations/001_initial_schema.sql --local
```

## Troubleshooting

### Error: "Couldn't find DB with name 'escriturashoy-staging-db'"

This means the database hasn't been created yet. Use one of the options above to create it.

### Error: "Database already exists"

If you're using Terraform and the database already exists, Terraform will manage it. Don't create it manually.

### Getting the Database ID

If you need to find the database ID:

```bash
# Via Terraform
cd infra/cloudflare
terraform output d1_database_id

# Via Wrangler
wrangler d1 list
```

## Next Steps

After the database is created and migrations are run:

1. Update `wrangler.toml` with the database binding
2. Test the API endpoints
3. Proceed with M3-T2: API endpoints for leads and expedientes

