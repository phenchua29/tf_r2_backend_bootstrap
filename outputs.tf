output "bucket" {
  value = {
    name             = cloudflare_r2_bucket.backend.name
    token_key_id     = cloudflare_account_token.backend_bucket.id
    token_key_secret = sha256(cloudflare_account_token.backend_bucket.value)
  }
  sensitive = true
}

output "endpoint" {
  value       = "https://${var.cloudflare_account_id}.r2.cloudflarestorage.com"
  description = "Endpoint for s3 backend"
}
