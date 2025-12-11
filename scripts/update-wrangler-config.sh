#!/bin/bash
# Automatically update wrangler.toml with resource IDs from Cloudflare
# This script queries Cloudflare via Wrangler and updates the config file

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
WRANGLER_TOML="$REPO_ROOT/apps-api/workers/wrangler.toml"
ENV="staging"

echo "🔍 Querying Cloudflare for resource IDs..."
echo ""

# Check if Wrangler is authenticated
if ! wrangler whoami > /dev/null 2>&1; then
  echo "❌ Wrangler not authenticated. Please run: wrangler login"
  exit 1
fi

# Get D1 Database ID
echo "📊 Getting D1 database ID..."
DB_NAME="escriturashoy-staging-db"
DB_ID=$(wrangler d1 list --json 2>/dev/null | jq -r ".[] | select(.name == \"$DB_NAME\") | .uuid" || echo "")

if [ -z "$DB_ID" ]; then
  echo "⚠️  D1 database '$DB_NAME' not found"
  echo "   Make sure Terraform has created the database"
  DB_ID=""
else
  echo "✅ Found D1 database ID: $DB_ID"
fi

# Get KV Namespace ID
echo "📊 Getting KV namespace ID..."
KV_TITLE="escriturashoy-staging-config"
KV_ID=$(wrangler kv:namespace list --json 2>/dev/null | jq -r ".[] | select(.title == \"$KV_TITLE\") | .id" || echo "")

if [ -z "$KV_ID" ]; then
  echo "⚠️  KV namespace '$KV_TITLE' not found"
  echo "   Make sure Terraform has created the KV namespace"
  KV_ID=""
else
  echo "✅ Found KV namespace ID: $KV_ID"
fi

# Get R2 Bucket name (we already know it, but verify it exists)
echo "📊 Verifying R2 bucket..."
R2_BUCKET="escriturashoy-staging-docs"
R2_EXISTS=$(wrangler r2 bucket list --json 2>/dev/null | jq -r ".[] | select(.name == \"$R2_BUCKET\") | .name" || echo "")

if [ -z "$R2_EXISTS" ]; then
  echo "⚠️  R2 bucket '$R2_BUCKET' not found"
  echo "   Make sure Terraform has created the R2 bucket"
else
  echo "✅ Found R2 bucket: $R2_BUCKET"
fi

echo ""
echo "📝 Updating wrangler.toml..."

# Create backup
cp "$WRANGLER_TOML" "$WRANGLER_TOML.bak"

# Update D1 database binding
if [ -n "$DB_ID" ]; then
  echo "  → Updating D1 database binding..."
  
  # Check if d1_databases section exists and is commented
  if grep -q "^# d1_databases = \[" "$WRANGLER_TOML"; then
    # Uncomment and update
    sed -i.tmp "s/# d1_databases = \[/d1_databases = [/" "$WRANGLER_TOML"
    sed -i.tmp "s/#   { binding = \"DB\"/  { binding = \"DB\"/" "$WRANGLER_TOML"
    sed -i.tmp "s/#     database_name = \"escriturashoy-staging-db\"/    database_name = \"escriturashoy-staging-db\"/" "$WRANGLER_TOML"
    sed -i.tmp "s/#     database_id = \"YOUR_D1_DATABASE_ID\"/    database_id = \"$DB_ID\"/" "$WRANGLER_TOML"
    sed -i.tmp "s/#   }/  }/" "$WRANGLER_TOML"
    sed -i.tmp "s/# ]/]/" "$WRANGLER_TOML"
    rm -f "$WRANGLER_TOML.tmp"
  elif grep -q "^d1_databases = \[" "$WRANGLER_TOML"; then
    # Already uncommented, just update the ID
    sed -i.tmp "s/database_id = \".*\"/database_id = \"$DB_ID\"/" "$WRANGLER_TOML"
    rm -f "$WRANGLER_TOML.tmp"
  else
    # Add new section
    # Find the [env.staging] section and add after it
    awk -v db_id="$DB_ID" '
      /\[env\.staging\]/ {
        print
        getline
        print
        print ""
        print "# D1 Database binding"
        print "d1_databases = ["
        print "  { binding = \"DB\", database_name = \"escriturashoy-staging-db\", database_id = \"" db_id "\" }"
        print "]"
        next
      }
      { print }
    ' "$WRANGLER_TOML" > "$WRANGLER_TOML.tmp" && mv "$WRANGLER_TOML.tmp" "$WRANGLER_TOML"
  fi
else
  echo "  ⚠️  Skipping D1 database binding (database not found)"
fi

# Update KV namespace binding
if [ -n "$KV_ID" ]; then
  echo "  → Updating KV namespace binding..."
  
  # Check if kv_namespaces section exists and is commented
  if grep -q "^# kv_namespaces = \[" "$WRANGLER_TOML"; then
    # Uncomment and update
    sed -i.tmp "s/# kv_namespaces = \[/kv_namespaces = [/" "$WRANGLER_TOML"
    sed -i.tmp "s/#   { binding = \"CONFIG\"/  { binding = \"CONFIG\"/" "$WRANGLER_TOML"
    sed -i.tmp "s/#     id = \"YOUR_KV_NAMESPACE_ID\"/    id = \"$KV_ID\"/" "$WRANGLER_TOML"
    sed -i.tmp "s/#   }/  }/" "$WRANGLER_TOML"
    sed -i.tmp "s/# ]/]/" "$WRANGLER_TOML"
    rm -f "$WRANGLER_TOML.tmp"
  elif grep -q "^kv_namespaces = \[" "$WRANGLER_TOML"; then
    # Already uncommented, just update the ID
    sed -i.tmp "s/id = \"YOUR_KV_NAMESPACE_ID\"/id = \"$KV_ID\"/" "$WRANGLER_TOML"
    sed -i.tmp "/kv_namespaces = \[/,/\]/ s/id = \".*\"/id = \"$KV_ID\"/" "$WRANGLER_TOML"
    rm -f "$WRANGLER_TOML.tmp"
  else
    # Add new section after D1 databases
    awk -v kv_id="$KV_ID" '
      /d1_databases = \[/ {
        print
        while (getline && !/^\]/) print
        print "]"
        print ""
        print "# KV Namespace binding"
        print "kv_namespaces = ["
        print "  { binding = \"CONFIG\", id = \"" kv_id "\" }"
        print "]"
        next
      }
      { print }
    ' "$WRANGLER_TOML" > "$WRANGLER_TOML.tmp" && mv "$WRANGLER_TOML.tmp" "$WRANGLER_TOML"
  fi
else
  echo "  ⚠️  Skipping KV namespace binding (namespace not found)"
fi

# Update R2 bucket binding
if [ -n "$R2_EXISTS" ]; then
  echo "  → Updating R2 bucket binding..."
  
  # Check if r2_buckets section exists and is commented
  if grep -q "^# r2_buckets = \[" "$WRANGLER_TOML"; then
    # Uncomment and update
    sed -i.tmp "s/# r2_buckets = \[/r2_buckets = [/" "$WRANGLER_TOML"
    sed -i.tmp "s/#   { binding = \"DOCS\"/  { binding = \"DOCS\"/" "$WRANGLER_TOML"
    sed -i.tmp "s/#     bucket_name = \"esh-docs-staging\"/    bucket_name = \"escriturashoy-staging-docs\"/" "$WRANGLER_TOML"
    sed -i.tmp "s/#   }/  }/" "$WRANGLER_TOML"
    sed -i.tmp "s/# ]/]/" "$WRANGLER_TOML"
    rm -f "$WRANGLER_TOML.tmp"
  elif grep -q "^r2_buckets = \[" "$WRANGLER_TOML"; then
    # Already uncommented, verify bucket name is correct
    if ! grep -q "bucket_name = \"escriturashoy-staging-docs\"" "$WRANGLER_TOML"; then
      sed -i.tmp "s/bucket_name = \".*\"/bucket_name = \"escriturashoy-staging-docs\"/" "$WRANGLER_TOML"
      rm -f "$WRANGLER_TOML.tmp"
    fi
  else
    # Add new section after KV namespaces
    awk -v bucket="$R2_BUCKET" '
      /kv_namespaces = \[/ {
        print
        while (getline && !/^\]/) print
        print "]"
        print ""
        print "# R2 Bucket binding"
        print "r2_buckets = ["
        print "  { binding = \"DOCS\", bucket_name = \"" bucket "\" }"
        print "]"
        next
      }
      { print }
    ' "$WRANGLER_TOML" > "$WRANGLER_TOML.tmp" && mv "$WRANGLER_TOML.tmp" "$WRANGLER_TOML"
  fi
else
  echo "  ⚠️  Skipping R2 bucket binding (bucket not found)"
fi

# Clean up temp files
rm -f "$WRANGLER_TOML.tmp"

echo ""
echo "✅ wrangler.toml updated successfully!"
echo ""
echo "📋 Summary:"
if [ -n "$DB_ID" ]; then
  echo "  ✅ D1 Database: $DB_ID"
else
  echo "  ⚠️  D1 Database: Not found"
fi
if [ -n "$KV_ID" ]; then
  echo "  ✅ KV Namespace: $KV_ID"
else
  echo "  ⚠️  KV Namespace: Not found"
fi
if [ -n "$R2_EXISTS" ]; then
  echo "  ✅ R2 Bucket: $R2_BUCKET"
else
  echo "  ⚠️  R2 Bucket: Not found"
fi
echo ""
echo "💡 Next steps:"
echo "  1. Review the updated wrangler.toml"
echo "  2. Deploy the Worker: cd apps-api/workers && npm run deploy:staging"
echo ""
echo "💾 Backup saved to: $WRANGLER_TOML.bak"

