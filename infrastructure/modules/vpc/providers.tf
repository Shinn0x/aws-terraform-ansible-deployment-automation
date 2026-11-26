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

  # Fail before any change if the credentials belong to a different account
  allowed_account_ids = [var.aws_account_id]

  # Add the common tags to every resource this provider creates
  default_tags {
    tags = local.common_tags
  }
}
