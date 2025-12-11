# Cloudflare Pages project for apps/public staging
resource "cloudflare_pages_project" "public_staging" {
  account_id        = var.cloudflare_account_id
  name              = "${var.project_name}-public-${var.environment}"
  production_branch = "main"

  build_config {
    build_command   = "npm install && npm run build"
    destination_dir = "dist"
    root_dir        = "apps/public"
  }

  deployment_configs {
    preview {
      environment_variables = {
        NODE_VERSION = "20"
        ENVIRONMENT  = var.environment
      }
    }
    production {
      environment_variables = {
        NODE_VERSION = "20"
        ENVIRONMENT  = var.environment
      }
    }
  }
}

# Custom domain for staging Pages
resource "cloudflare_pages_domain" "public_staging_domain" {
  account_id   = var.cloudflare_account_id
  project_name = cloudflare_pages_project.public_staging.name
  domain       = "staging.${data.cloudflare_zone.main.zone}"
}

