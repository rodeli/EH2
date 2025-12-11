output "zone_id" {
  description = "Cloudflare zone ID"
  value       = data.cloudflare_zone.main.zone_id
}

output "zone_name" {
  description = "Cloudflare zone name"
  value       = var.zone_name
}

output "pages_project_name" {
  description = "Pages project name"
  value       = cloudflare_pages_project.public_staging.name
}

output "pages_url" {
  description = "Pages project URL"
  value       = "https://${cloudflare_pages_project.public_staging.name}.pages.dev"
}

output "pages_staging_domain" {
  description = "Staging Pages custom domain"
  value       = cloudflare_pages_domain.public_staging_domain.name
}

output "d1_database_name" {
  description = "D1 database name"
  value       = cloudflare_d1_database.staging.name
}

output "d1_database_id" {
  description = "D1 database ID"
  value       = cloudflare_d1_database.staging.id
}

output "kv_namespace_id" {
  description = "KV namespace ID"
  value       = cloudflare_workers_kv_namespace.config.id
}

output "r2_bucket_name" {
  description = "R2 bucket name for docs"
  value       = cloudflare_r2_bucket.docs.name
}

