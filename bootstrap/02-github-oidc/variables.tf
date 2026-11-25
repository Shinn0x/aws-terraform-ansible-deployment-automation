
variable "aws_region" {
  description = "AWS region for the OIDC bootstrap"
  type        = string
  default     = "ap-southeast-1"
}

variable "github_owner" {
  description = "GitHub repository owner"
  type        = string
  default     = "Shinn0x"
}

variable "github_owner_id" {
  description = "Immutable GitHub owner ID"
  type        = string
  default     = "REDACTED_GITHUB_OWNER_ID"
}

variable "github_repo" {
  description = "GitHub repository name"
  type        = string
  default     = "aws-terraform-ansible-deployment-automation"
}

variable "github_repo_id" {
  description = "Immutable GitHub repository ID"
  type        = string
  default     = "REDACTED_GITHUB_REPO_ID"
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
