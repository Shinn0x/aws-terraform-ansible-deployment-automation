# AWS region for the IAM resources
variable "aws_region" {
  description = "AWS region for the OIDC bootstrap"
  type        = string
  default     = "ap-southeast-1"
}

# AWS account ID, set in .env (no default)
variable "aws_account_id" {
  description = "AWS account this configuration may run against. Set TF_VAR_aws_account_id in .env."
  type        = string

  validation {
    condition     = can(regex("^[0-9]{12}$", var.aws_account_id))
    error_message = "aws_account_id must be a 12-digit AWS account ID (aws sts get-caller-identity --query Account --output text)."
  }
}

# Environment name, used for tags
variable "environment" {
  description = "Deployment environment"
  type        = string
  default     = "dev"
}

# GitHub repository and branch allowed to assume the role. The IDs are set in .env (no default)
variable "github_owner" {
  description = "GitHub repository owner"
  type        = string
  default     = "Shinn0x"
}

variable "github_owner_id" {
  description = "Immutable GitHub owner ID. Set TF_VAR_github_owner_id in .env."
  type        = string

  validation {
    condition     = can(regex("^[0-9]+$", var.github_owner_id))
    error_message = "github_owner_id must be the numeric GitHub owner ID (gh api users/OWNER --jq .id)."
  }
}

variable "github_repo" {
  description = "GitHub repository name"
  type        = string
  default     = "aws-terraform-ansible-deployment-automation"
}

variable "github_repo_id" {
  description = "Immutable GitHub repository ID. Set TF_VAR_github_repo_id in .env."
  type        = string

  validation {
    condition     = can(regex("^[0-9]+$", var.github_repo_id))
    error_message = "github_repo_id must be the numeric GitHub repository ID (gh api repos/OWNER/REPO --jq .id)."
  }
}

variable "github_branch" {
  description = "Branch allowed to assume the AWS role"
  type        = string
  default     = "main"
}

# State bucket the role may read and write
variable "state_bucket_name" {
  description = "S3 bucket that stores Terraform state (created by 01-state-bucket)"
  type        = string
  default     = "shinn-terraform-state-foundation"
}
