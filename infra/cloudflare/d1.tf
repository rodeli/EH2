# D1 database for staging
resource "cloudflare_d1_database" "staging" {
  account_id = var.cloudflare_account_id
  name       = "${var.project_name}-${var.environment}-db"

  # Prevent Terraform from trying to update read_replication when imported
  lifecycle {
    ignore_changes = [read_replication]
  }
}

