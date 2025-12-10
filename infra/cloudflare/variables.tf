variable "cloudflare_api_token" {
  description = "Cloudflare API token with DNS, D1, KV, R2 and Workers permissions for this account."
  type        = string
  sensitive   = true
}

variable "account_id" {
  description = "Cloudflare account ID"
  type        = string
}

variable "zone_name" {
  description = "DNS zone name for Escriturashoy"
  type        = string
  default     = "escriturashoy.com"
}

