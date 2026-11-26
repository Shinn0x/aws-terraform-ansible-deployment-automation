# Terraform version and remote state
terraform {
  required_version = ">= 1.10.0"

  # Store the prod state in S3
  backend "s3" {
    bucket  = "shinn-terraform-state-foundation"
    key     = "environments/prod/terraform.tfstate"
    region  = "ap-southeast-1"
    encrypt = true

    # Lock the state with a lock file in S3
    use_lockfile = true
  }
}
