# AWS provider version
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

# Configure the AWS provider
provider "aws" {
  region = var.aws_region

  # Only allow this AWS account
  allowed_account_ids = [var.aws_account_id]

  # Add common tags to all resources
  default_tags {
    tags = local.common_tags
  }
}
