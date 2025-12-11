variable "cloudflare_api_token" {
  description = "Cloudflare API token with DNS, D1, KV, R2 and Workers permissions for this account."
  type        = string
  sensitive   = true
}

variable "cloudflare_account_id" {
  description = "Cloudflare account ID"
  type        = string
}

variable "zone_id" {
  description = "Cloudflare zone ID for escriturashoy.com"
  type        = string
}

variable "project_name" {
  description = "Project name used for resource naming"
  type        = string
  default     = "escriturashoy"
}

variable "environment" {
  description = "Environment name (staging, production)"
  type        = string
  default     = "staging"
}

variable "zone_name" {
  description = "DNS zone name for Escriturashoy"
  type        = string
  default     = "escriturashoy.com"
}

