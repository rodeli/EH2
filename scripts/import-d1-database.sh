#!/bin/bash
# Import existing D1 database into Terraform state

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
TERRAFORM_DIR="$REPO_ROOT/infra/cloudflare"

echo "🔍 Importing existing D1 database into Terraform..."

cd "$TERRAFORM_DIR"

# Check if Terraform is initialized
if [ ! -d ".terraform" ]; then
  echo "⚠️  Terraform not initialized. Running terraform init..."
  terraform init > /dev/null 2>&1
fi

# Get database ID
echo "📋 Getting database ID..."
DB_ID=$(wrangler d1 list 2>/dev/null | grep "escriturashoy-staging-db" | awk '{print $1}' || echo "")

if [ -z "$DB_ID" ]; then
  echo "❌ Could not find database ID."
  echo ""
  echo "Please get the database ID manually:"
  echo "1. Go to: https://dash.cloudflare.com → Workers & Pages → D1"
  echo "2. Find: escriturashoy-staging-db"
  echo "3. Copy the Database ID"
  echo ""
  echo "Then run:"
  echo "  cd infra/cloudflare"
  echo "  terraform import cloudflare_d1_database.staging <account_id>/<database_id>"
  exit 1
fi

echo "✅ Found database ID: $DB_ID"
echo ""

# Get account ID from environment variable, Terraform variables, or ask user
if [ -n "$CLOUDFLARE_ACCOUNT_ID" ]; then
  ACCOUNT_ID="$CLOUDFLARE_ACCOUNT_ID"
  echo "✅ Using Account ID from environment variable"
elif [ -f "terraform.tfvars" ]; then
  ACCOUNT_ID=$(grep "cloudflare_account_id" terraform.tfvars | cut -d'"' -f2 || echo "")
fi

if [ -z "$ACCOUNT_ID" ]; then
  echo "Please enter your Cloudflare Account ID:"
  echo "  (You can find it in GitHub Secrets or Cloudflare Dashboard)"
  read -r ACCOUNT_ID
fi

if [ -z "$ACCOUNT_ID" ]; then
  echo "❌ Account ID is required"
  exit 1
fi

echo "📥 Importing database into Terraform state..."
echo "   Account ID: $ACCOUNT_ID"
echo "   Database ID: $DB_ID"
echo ""

terraform import cloudflare_d1_database.staging "$ACCOUNT_ID/$DB_ID"

if [ $? -eq 0 ]; then
  echo ""
  echo "✅ Database imported successfully!"
  echo ""
  echo "Next steps:"
  echo "1. Run: terraform plan (to verify no conflicts)"
  echo "2. Run: terraform apply (to create remaining resources)"
else
  echo ""
  echo "❌ Import failed. Please check the error above."
  exit 1
fi


