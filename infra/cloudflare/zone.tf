# Data source for existing escriturashoy.com zone
# The zone must already exist in Cloudflare
data "cloudflare_zone" "main" {
  zone_id = var.zone_id
}

# Note: DNS record for staging.escriturashoy.com is automatically created
# by cloudflare_pages_domain resource in pages.tf
# No manual DNS record needed - Pages handles it automatically

# API subdomain DNS record
# This is needed for the Worker route to work
# The Worker route in wrangler.toml will handle routing, but DNS must exist first
resource "cloudflare_dns_record" "api_staging" {
  zone_id = data.cloudflare_zone.main.zone_id
  name    = "api-staging"
  type    = "CNAME"
  content = "@"  # Points to root domain (proxied through Cloudflare)
  proxied = true
  ttl     = 1
  comment = "API Worker route for api-staging.escriturashoy.com"
}

