# Data source for existing escriturashoy.com zone
# The zone must already exist in Cloudflare
data "cloudflare_zone" "main" {
  zone_id = var.zone_id
}

# Staging subdomain DNS record for Pages
resource "cloudflare_record" "staging_pages" {
  zone_id = data.cloudflare_zone.main.zone_id
  name    = "staging"
  type    = "CNAME"
  content = "staging.pages.dev"
  proxied = true
  comment = "Staging Pages site for apps/public"
}

