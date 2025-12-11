# Cloudflare Pages project for apps/public staging
resource "cloudflare_pages_project" "public_staging" {
  account_id        = var.cloudflare_account_id
  name              = "${var.project_name}-public-${var.environment}"
  production_branch = "main"
}

# Custom domain for staging Pages
resource "cloudflare_pages_domain" "public_staging_domain" {
  account_id   = var.cloudflare_account_id
  project_name = cloudflare_pages_project.public_staging.name
  name         = "staging.${var.zone_name}"
}

