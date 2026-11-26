# Terraform version and remote state
terraform {
  required_version = ">= 1.10.0"

  # Store the dev state in S3
  backend "s3" {
    bucket  = "shinn-terraform-state-foundation"
    key     = "environments/dev/terraform.tfstate"
    region  = "ap-southeast-1"
    encrypt = true

    # Lock the state with a lock file in S3
    use_lockfile = true
  }
}
