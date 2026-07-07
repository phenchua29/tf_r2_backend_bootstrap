resource "cloudflare_r2_bucket" "backend" {
  account_id = var.cloudflare_account_id
  name       = var.bucket_name
  location   = var.bucket_location
}

data "cloudflare_account_api_token_permission_groups_list" "r2_bucket_item_read" {
  account_id = var.cloudflare_account_id
  name       = "Workers%20R2%20Storage%20Bucket%20Item%20Read"
}

data "cloudflare_account_api_token_permission_groups_list" "r2_bucket_item_write" {
  account_id = var.cloudflare_account_id
  name       = "Workers%20R2%20Storage%20Bucket%20Item%20Write"
}

resource "cloudflare_account_token" "backend_bucket" {
  account_id = var.cloudflare_account_id
  name       = cloudflare_r2_bucket.backend.name
  policies = [{
    effect = "allow"
    permission_groups = [
      { id = data.cloudflare_account_api_token_permission_groups_list.r2_bucket_item_read.result[0].id },
      { id = data.cloudflare_account_api_token_permission_groups_list.r2_bucket_item_write.result[0].id },
    ]
    resources = jsonencode({
      "com.cloudflare.edge.r2.bucket.${var.cloudflare_account_id}_default_${cloudflare_r2_bucket.backend.name}" = "*"
    })
  }]
}
