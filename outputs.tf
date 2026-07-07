locals {
  token            = one(cloudflare_account_token.backend_bucket)
  token_key_id     = local.token != null ? local.token.id : null
  token_key_secret = local.token != null ? sha256(local.token.value) : null
}

output "bucket" {
  value = {
    name             = cloudflare_r2_bucket.backend.name
    token_key_id     = local.token_key_id
    token_key_secret = local.token_key_secret
  }
  sensitive = true
}

output "endpoint" {
  value       = "https://${var.cloudflare_account_id}.r2.cloudflarestorage.com"
  description = "Endpoint for s3 backend"
}
