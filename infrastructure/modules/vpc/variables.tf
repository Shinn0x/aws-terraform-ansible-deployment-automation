# AWS region where the VPC is created
variable "aws_region" {
  description = "AWS region for the VPC"
  type        = string
  default     = "ap-southeast-1"
}

# Account ID has no default so it is never committed.
# Locally it comes from .env, in GitHub Actions from the AWS_ACCOUNT_ID secret.
variable "aws_account_id" {
  description = "AWS account this configuration may run against. Set TF_VAR_aws_account_id in .env, or the AWS_ACCOUNT_ID secret in CI."
  type        = string

  validation {
    condition     = can(regex("^[0-9]{12}$", var.aws_account_id))
    error_message = "aws_account_id must be a 12-digit AWS account ID (aws sts get-caller-identity --query Account --output text)."
  }
}

# Project name and environment, used for tags and resource names
variable "project_name" {
  description = "Project name used for resource tags"
  type        = string
  default     = "aws-terraform-ansible-deployment-automation"
}

variable "environment" {
  description = "Deployment environment"
  type        = string
  default     = "dev"
}

# IP address ranges for the VPC and its public subnet
variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
  default     = "10.20.0.0/16"
}

variable "public_subnet_cidr" {
  description = "CIDR block for the public subnet. Must be inside vpc_cidr."
  type        = string
  default     = "10.20.1.0/24"
}
