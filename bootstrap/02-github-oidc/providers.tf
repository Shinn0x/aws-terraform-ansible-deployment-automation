terraform {
  required_version = ">= 1.5.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

locals {
  project_name = "aws-terraform-ansible-deployment-automation"
  environment  = var.environment

  common_tags = {
    Project     = local.project_name
    Environment = local.environment
    ManagedBy   = "Terraform"
  }
}

provider "aws" {
  region = var.aws_region

  # Fail before any change if the credentials belong to a different account
  allowed_account_ids = [var.aws_account_id]

  default_tags {
    tags = local.common_tags
  }
}
