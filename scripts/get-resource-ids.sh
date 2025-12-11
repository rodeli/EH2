#!/bin/bash
# Get Cloudflare resource IDs for Terraform import

set -e

if [ -z "$CLOUDFLARE_API_TOKEN" ]; then
  echo "❌ CLOUDFLARE_API_TOKEN environment variable required"
  exit 1
fi

if [ -z "$CLOUDFLARE_ACCOUNT_ID" ]; then
  echo "❌ CLOUDFLARE_ACCOUNT_ID environment variable required"
  exit 1
fi

if [ -z "$CLOUDFLARE_ZONE_ID" ]; then
  echo "❌ CLOUDFLARE_ZONE_ID environment variable required"
  exit 1
fi

ACCOUNT_ID="$CLOUDFLARE_ACCOUNT_ID"
ZONE_ID="$CLOUDFLARE_ZONE_ID"
API_TOKEN="$CLOUDFLARE_API_TOKEN"

echo "🔍 Fetching Cloudflare resource IDs..."
echo ""

# Get KV Namespace ID
echo "📋 KV Namespace ID:"
KV_NAMESPACE_ID=$(curl -s -X GET \
  "https://api.cloudflare.com/client/v4/accounts/$ACCOUNT_ID/storage/kv/namespaces" \
  -H "Authorization: Bearer $API_TOKEN" \
  -H "Content-Type: application/json" | \
  jq -r '.result[] | select(.title == "escriturashoy-staging-config") | .id' || echo "")

if [ -n "$KV_NAMESPACE_ID" ] && [ "$KV_NAMESPACE_ID" != "null" ]; then
  echo "   ✅ $KV_NAMESPACE_ID"
  echo "   Import: terraform import cloudflare_workers_kv_namespace.config $ACCOUNT_ID/$KV_NAMESPACE_ID"
else
  echo "   ⚠️  Not found"
fi
echo ""

# Get Pages Project (check if exists)
echo "📋 Pages Project:"
PAGES_PROJECT=$(curl -s -X GET \
  "https://api.cloudflare.com/client/v4/accounts/$ACCOUNT_ID/pages/projects/escriturashoy-public-staging" \
  -H "Authorization: Bearer $API_TOKEN" \
  -H "Content-Type: application/json" 2>/dev/null || echo "")

if echo "$PAGES_PROJECT" | jq -e '.success == true' > /dev/null 2>&1; then
  echo "   ✅ Project exists: escriturashoy-public-staging"
  echo "   Import: terraform import cloudflare_pages_project.public_staging $ACCOUNT_ID/escriturashoy-public-staging"
else
  echo "   ⚠️  Project not found"
fi
echo ""

# Get DNS Record ID
echo "📋 DNS Record ID:"
DNS_RECORD_ID=$(curl -s -X GET \
  "https://api.cloudflare.com/client/v4/zones/$ZONE_ID/dns_records?name=staging.escriturashoy.com&type=CNAME" \
  -H "Authorization: Bearer $API_TOKEN" \
  -H "Content-Type: application/json" | \
  jq -r '.result[0].id' || echo "")

if [ -n "$DNS_RECORD_ID" ] && [ "$DNS_RECORD_ID" != "null" ]; then
  echo "   ✅ $DNS_RECORD_ID"
  echo "   Import: terraform import cloudflare_dns_record.staging_pages $ZONE_ID/$DNS_RECORD_ID"
else
  echo "   ⚠️  Not found"
fi
echo ""

echo "✅ Resource ID lookup complete!"

