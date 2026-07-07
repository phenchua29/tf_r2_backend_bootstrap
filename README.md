# Backend Bootstrapping Terraform Module

This Terraform module bootstraps a Cloudflare R2 bucket and generates a read-write token for it.

The module was made for fast bootstrapping of S3 backends.

## Table of Contents

- [Usage Guide](#usage-guide)
  - [Prerequisites](#prerequisites)
    - [Tools](#tools)
    - [Environment Variables](#environment-variables)
  - [Example](#example)
  - [Using the Newly Created S3 Backends](#using-the-newly-created-s3-backends)
- [Reference](#reference)
  - [Variables](#variables)
  - [Outputs](#outputs)
- [License](#license)

## Usage Guide

### Prerequisites

Before running the module, make sure the following requirements are met:

#### Tools

- **[Terraform CLI](https://developer.hashicorp.com/terraform/install)**: version `~> 1.15.2`.

#### Environment Variables

- `CLOUDFLARE_API_TOKEN`: A [Cloudflare API token](https://developers.cloudflare.com/fundamentals/api/get-started/account-owned-tokens/#create-an-account-owned-token) with the following permissions:
  - Account API Tokens Write
  - Account API Tokens Read
  - Workers R2 Storage Write
  - Workers R2 Storage Read

### Example

```hcl
module "example" {
  source                = "git::https://github.com/phenchua29/tf_r2_backend_bootstrap.git?ref=v1.0.0"
  bucket_name           = "<example-bucket>"
  cloudflare_account_id = "<account-id>"
}

output "bucket" {
  value     = module.example.bucket
  sensitive = true
}

output "endpoint" {
  value = module.example.endpoint
}
```

With everything set up, we can now run:

```bash
terraform init
terraform plan -out tfplan
terraform apply tfplan
```

### Using the Newly Created S3 Backend

After successfully running the above commands, check the S3 backend info. Since the bucket credentials are sensitive outputs, you can retrieve them in JSON format:

```bash
terraform output -json bucket
```

This will return a JSON object of the created bucket and its credentials:

```json
{
  "name": "<example-bucket>",
  "token_key_id": "<token-key-id>",
  "token_key_secret": "<hashed-token-key-secret>"
}
```

Get the backend endpoint:

- `endpoints.s3`: `terraform output endpoint`

To use the created S3 bucket as a backend:

1. Retrieve the credentials for the bucket from the JSON output and keep them exported for your backend configuration.

```.envrc
# Dummy region value to satisfy the AWS S3 SDK (since connections are routed via S3 endpoints)
export AWS_DEFAULT_REGION='auto'
export AWS_ACCESS_KEY_ID='<token_key_id>'
export AWS_SECRET_ACCESS_KEY='<token_key_secret>'
```

2. Set up this block in the `terraform` block (see [S3 backend documentation](https://developer.hashicorp.com/terraform/language/backend/s3) for more details):

```hcl
  backend "s3" {
    bucket       = "<example-bucket>"
    key          = "<path/to/state>"
    use_lockfile = true
    endpoints = {
      s3 = "<endpoint>"
    }

    skip_credentials_validation = true
    skip_requesting_account_id  = true
  }
```

3. Run `terraform init -migrate-state`

## Reference

### Variables

| Variable                | Type          | Required | Description                                                                                                                                                                                               |
| ----------------------- | ------------- | -------- | --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `cloudflare_account_id` | `string`      | Yes      | Your Cloudflare account ID.                                                                                                                                                                               |
| `bucket_name`           | `string`      | Yes      | The R2 bucket name to create.                                                                                                                                                                             |
| `bucket_location`       | `string`      | No       | The location of the R2 bucket to create. Available values: `"apac"`, `"eeur"`, `"enam"`, `"weur"`, `"wnam"`, `"oc"`. See [Location hints](https://developers.cloudflare.com/r2/reference/data-location/#location-hints). |

### Outputs

| Name       | Description                                                                                                                   |
| ---------- | ----------------------------------------------------------------------------------------------------------------------------- |
| `bucket`   | An object containing details and credentials for the created R2 bucket (`name`, `token_key_id`, `token_key_secret`).          |
| `endpoint` | The S3 API endpoint URL for the Cloudflare R2 account.                                                                        |

## License

This project is licensed under the [MIT License](LICENSE).
