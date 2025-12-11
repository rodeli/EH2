# Data source for existing escriturashoy.com zone
# The zone must already exist in Cloudflare
data "cloudflare_zone" "main" {
  zone_id = var.zone_id
}

# Note: DNS record for staging.escriturashoy.com is automatically created
# by cloudflare_pages_domain resource in pages.tf
# No manual DNS record needed - Pages handles it automatically

