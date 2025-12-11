#!/bin/bash
# Update wrangler.toml with D1 database ID from Terraform

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
TERRAFORM_DIR="$REPO_ROOT/infra/cloudflare"
WRANGLER_TOML="$REPO_ROOT/apps-api/workers/wrangler.toml"

echo "🔍 Getting D1 database ID from Terraform..."

cd "$TERRAFORM_DIR"

# Check if Terraform is initialized
if [ ! -d ".terraform" ]; then
  echo "⚠️  Terraform not initialized. Running terraform init..."
  terraform init > /dev/null 2>&1
fi

# Get database ID from Terraform output
DB_ID=$(terraform output -raw d1_database_id 2>/dev/null || echo "")

if [ -z "$DB_ID" ]; then
  echo "❌ Could not get database ID from Terraform."
  echo "   Make sure Terraform has been applied successfully."
  echo "   You can also get the ID from Cloudflare dashboard:"
  echo "   https://dash.cloudflare.com → Workers & Pages → D1 → escriturashoy-staging-db"
  exit 1
fi

echo "✅ Found database ID: $DB_ID"
echo ""
echo "📝 Updating wrangler.toml..."

# Check if database binding is already uncommented
if grep -q "^d1_databases = \[" "$WRANGLER_TOML"; then
  echo "⚠️  Database binding already exists. Updating database_id..."
  # Update existing database_id
  sed -i.bak "s/database_id = \".*\"/database_id = \"$DB_ID\"/" "$WRANGLER_TOML"
  rm -f "$WRANGLER_TOML.bak"
else
  echo "📝 Uncommenting and updating database binding..."
  # Uncomment and update the d1_databases block
  sed -i.bak "s/# d1_databases = \[/d1_databases = [/" "$WRANGLER_TOML"
  sed -i.bak "s/#   { binding = \"DB\"/  { binding = \"DB\"/" "$WRANGLER_TOML"
  sed -i.bak "s/#     database_name = \"escriturashoy-staging-db\"/    database_name = \"escriturashoy-staging-db\"/" "$WRANGLER_TOML"
  sed -i.bak "s/#     database_id = \"YOUR_D1_DATABASE_ID\"/    database_id = \"$DB_ID\"/" "$WRANGLER_TOML"
  sed -i.bak "s/#   }/  }/" "$WRANGLER_TOML"
  sed -i.bak "s/# ]/]/" "$WRANGLER_TOML"
  rm -f "$WRANGLER_TOML.bak"
fi

echo "✅ wrangler.toml updated successfully!"
echo ""
echo "Next steps:"
echo "1. Review the changes: git diff apps-api/workers/wrangler.toml"
echo "2. Commit the changes: git add apps-api/workers/wrangler.toml && git commit -m 'chore: Update wrangler.toml with D1 database ID'"
echo "3. Deploy the Worker: cd apps-api/workers && npm run deploy:staging"

