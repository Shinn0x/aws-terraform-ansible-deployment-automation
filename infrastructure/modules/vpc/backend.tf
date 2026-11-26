# Terraform version and remote state settings
terraform {
  # S3 native state locking (use_lockfile) needs Terraform 1.10 or later
  required_version = ">= 1.10.0"

  # Store the state in the S3 bucket created by bootstrap/01-state-bucket.
  # Backend settings can't use variables, so the values are written here.
  backend "s3" {
    bucket  = "shinn-terraform-state-foundation"
    key     = "vpc/terraform.tfstate"
    region  = "ap-southeast-1"
    encrypt = true

    # Lock the state with a .tflock file in the bucket, no DynamoDB table needed
    use_lockfile = true
  }
}
