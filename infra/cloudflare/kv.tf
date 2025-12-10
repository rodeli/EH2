# Workers KV namespace for configs and feature flags
resource "cloudflare_workers_kv_namespace" "config" {
  account_id = var.cloudflare_account_id
  title      = "${var.project_name}-${var.environment}-config"
}

