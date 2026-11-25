
variable "aws_region" {
  description = "AWS region for the OIDC bootstrap"
  type        = string
  default     = "ap-southeast-1"
}

variable "environment" {
  description = "Deployment environment"
  type        = string
  default     = "dev"
}

variable "github_owner" {
  description = "GitHub repository owner"
  type        = string
  default     = "Shinn0x"
}

variable "github_owner_id" {
  description = "Immutable GitHub owner ID"
  type        = string
  default     = "148429347"

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
  description = "Immutable GitHub repository ID"
  type        = string
  default     = "1471521259"

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

variable "state_bucket_name" {
  description = "S3 bucket that stores Terraform state (created by 01-state-bucket)"
  type        = string
  default     = "shinn-terraform-state-foundation"
}
