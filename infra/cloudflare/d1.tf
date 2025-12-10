# D1 database for staging
resource "cloudflare_d1_database" "staging" {
  account_id = var.cloudflare_account_id
  name       = "${var.project_name}-${var.environment}-db"
}

