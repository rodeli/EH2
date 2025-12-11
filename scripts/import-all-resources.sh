#!/bin/bash
# Import all existing Cloudflare resources into Terraform state

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
TERRAFORM_DIR="$REPO_ROOT/infra/cloudflare"

echo "🔍 Importing all existing Cloudflare resources into Terraform..."
echo ""

cd "$TERRAFORM_DIR"

# Check if Terraform is initialized
if [ ! -d ".terraform" ]; then
  echo "⚠️  Terraform not initialized. Running terraform init..."
  terraform init > /dev/null 2>&1
fi

# Get account ID
if [ -n "$CLOUDFLARE_ACCOUNT_ID" ]; then
  ACCOUNT_ID="$CLOUDFLARE_ACCOUNT_ID"
  echo "✅ Using Account ID from environment: $ACCOUNT_ID"
elif [ -f "terraform.tfvars" ]; then
  ACCOUNT_ID=$(grep "cloudflare_account_id" terraform.tfvars | cut -d'"' -f2 || echo "")
fi

if [ -z "$ACCOUNT_ID" ]; then
  echo "Please enter your Cloudflare Account ID:"
  read -r ACCOUNT_ID
fi

if [ -z "$ACCOUNT_ID" ]; then
  echo "❌ Account ID is required"
  exit 1
fi

# Get zone ID
if [ -f "terraform.tfvars" ]; then
  ZONE_ID=$(grep "zone_id" terraform.tfvars | cut -d'"' -f2 || echo "")
fi

if [ -z "$ZONE_ID" ]; then
  echo "Please enter your Cloudflare Zone ID:"
  read -r ZONE_ID
fi

if [ -z "$ZONE_ID" ]; then
  echo "❌ Zone ID is required"
  exit 1
fi

echo ""
echo "📋 Importing resources..."
echo ""

# 1. Import D1 Database
echo "1️⃣  Importing D1 database..."
DB_ID="c4d93a6a-1245-4a9f-9543-fa546f25d5c0"
if terraform import cloudflare_d1_database.staging "$ACCOUNT_ID/$DB_ID" 2>&1 | grep -q "Error"; then
  echo "   ⚠️  D1 database may already be imported or error occurred"
else
  echo "   ✅ D1 database imported"
fi
echo ""

# 2. Import KV Namespace
echo "2️⃣  Importing KV namespace..."
echo "   Getting KV namespace ID..."
KV_NAMESPACE_ID=$(wrangler kv:namespace list 2>/dev/null | grep "escriturashoy-staging-config" | awk '{print $1}' || echo "")

if [ -z "$KV_NAMESPACE_ID" ]; then
  echo "   ⚠️  Could not find KV namespace ID automatically"
  echo "   Please get it from: https://dash.cloudflare.com → Workers & Pages → KV"
  echo "   Then run: terraform import cloudflare_workers_kv_namespace.config $ACCOUNT_ID/<namespace_id>"
else
  if terraform import cloudflare_workers_kv_namespace.config "$ACCOUNT_ID/$KV_NAMESPACE_ID" 2>&1 | grep -q "Error"; then
    echo "   ⚠️  KV namespace may already be imported or error occurred"
  else
    echo "   ✅ KV namespace imported"
  fi
fi
echo ""

# 3. Import R2 Bucket
echo "3️⃣  Importing R2 bucket..."
R2_BUCKET_NAME="escriturashoy-staging-docs"
if terraform import cloudflare_r2_bucket.docs "$ACCOUNT_ID/$R2_BUCKET_NAME" 2>&1 | grep -q "Error"; then
  echo "   ⚠️  R2 bucket may already be imported or error occurred"
else
  echo "   ✅ R2 bucket imported"
fi
echo ""

# 4. Import DNS Record
echo "4️⃣  Importing DNS record..."
DNS_NAME="staging"
DNS_TYPE="CNAME"
# Format: zone_id/record_id or zone_id/name/type
# For DNS records, we need the record ID. Let's try importing by name/type
if terraform import cloudflare_dns_record.staging_pages "$ZONE_ID/$DNS_NAME/$DNS_TYPE" 2>&1 | grep -q "Error"; then
  echo "   ⚠️  DNS record import may need record ID"
  echo "   Get record ID from: https://dash.cloudflare.com → escriturashoy.com → DNS"
  echo "   Then run: terraform import cloudflare_dns_record.staging_pages $ZONE_ID/<record_id>"
else
  echo "   ✅ DNS record imported"
fi
echo ""

echo "✅ Import process complete!"
echo ""
echo "Next steps:"
echo "1. Run: terraform plan (to verify imports and see remaining resources)"
echo "2. Run: terraform apply (to create any remaining resources)"
echo ""

