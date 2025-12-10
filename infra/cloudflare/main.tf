terraform {
  # Backend configuration - use R2 or Terraform Cloud in production
  # For now, using local backend. To use R2:
  # backend "s3" {
  #   bucket   = "terraform-state-escriturashoy"
  #   key      = "cloudflare/terraform.tfstate"
  #   region   = "auto"
  #   endpoint = "https://<account-id>.r2.cloudflarestorage.com"
  #   access_key_id = var.r2_access_key_id
  #   secret_access_key = var.r2_secret_access_key
  # }
}


