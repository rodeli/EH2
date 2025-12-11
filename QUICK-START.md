# Quick Start: Database Setup

The D1 database `escriturashoy-staging-db` doesn't exist yet. Here's the fastest way to create it:

## Option 1: Automated Script (Easiest)

```bash
cd /Users/ro/Code/mines/eh2
./scripts/create-database.sh
```

This script will:
1. Create the database
2. Extract the database ID
3. Update `wrangler.toml` automatically
4. Show you the next steps

## Option 2: Manual Wrangler (If script doesn't work)

```bash
# Make sure you're in the repo root
cd /Users/ro/Code/mines/eh2

# Create the database
wrangler d1 create escriturashoy-staging-db

# The output will show the database_id - copy it!
# Example output:
#   [[d1_databases]]
#   binding = "DB"
#   database_name = "escriturashoy-staging-db"
#   database_id = "abc123def456..."

# Update apps-api/workers/wrangler.toml
# Uncomment and update the d1_databases section:
#   [env.staging]
#   d1_databases = [
#     { binding = "DB", database_name = "escriturashoy-staging-db", database_id = "YOUR_DATABASE_ID" }
#   ]

# Run the migration
cd apps-api/workers
wrangler d1 execute escriturashoy-staging-db --file=../../db/migrations/001_initial_schema.sql --remote
```

## Option 3: Via Terraform (Full Infrastructure)

If you want to create all infrastructure (database, KV, R2, Pages, etc.):

**Note:** This requires Terraform to be installed locally.

```bash
cd /Users/ro/Code/mines/eh2/infra/cloudflare

# Create terraform.tfvars (don't commit this!)
cat > terraform.tfvars <<EOF
cloudflare_api_token = "your-api-token"
cloudflare_account_id = "your-account-id"
zone_id = "your-zone-id"
project_name = "escriturashoy"
environment = "staging"
EOF

# Initialize and apply
terraform init
terraform plan
terraform apply

# Get the database ID
terraform output d1_database_id
```

Then update `apps-api/workers/wrangler.toml` with the database_id.

## Troubleshooting

### "wrangler: command not found"

Install wrangler:
```bash
npm install -g wrangler
# Or use npx
npx wrangler d1 create escriturashoy-staging-db
```

### "terraform: command not found"

Terraform is not required for the quick setup. Use Option 1 or 2 instead.

### Wrong directory

Make sure you're in the repo root:
```bash
cd /Users/ro/Code/mines/eh2
pwd  # Should show: /Users/ro/Code/mines/eh2
```

## After Database is Created

1. **Verify database exists:**
   ```bash
   wrangler d1 list
   ```

2. **Run migration:**
   ```bash
   cd apps-api/workers
   wrangler d1 execute escriturashoy-staging-db --file=../../db/migrations/001_initial_schema.sql --remote
   ```

3. **For local development:**
   ```bash
   wrangler d1 execute escriturashoy-staging-db --file=../../db/migrations/001_initial_schema.sql --local
   ```

See `docs/SETUP-DATABASE.md` for detailed instructions.
