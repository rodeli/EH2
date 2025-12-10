# R2 bucket for document storage
resource "cloudflare_r2_bucket" "docs" {
  account_id = var.cloudflare_account_id
  name       = "${var.project_name}-${var.environment}-docs"
  location   = "weur" # Western Europe - adjust as needed
}

