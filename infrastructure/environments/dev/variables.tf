# AWS region
variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "ap-southeast-1"
}

# AWS account ID, set in .env (no default)
variable "aws_account_id" {
  description = "AWS account ID allowed for this environment"
  type        = string

  validation {
    condition     = can(regex("^[0-9]{12}$", var.aws_account_id))
    error_message = "aws_account_id must be a 12-digit AWS account ID."
  }
}

# Project name for tags and resource names
variable "project_name" {
  description = "Project name"
  type        = string
  default     = "aws-terraform-ansible-deployment-automation"
}

# VPC IP range
variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
  default     = "10.20.0.0/16"
}

# Public subnet IP range
variable "public_subnet_cidr" {
  description = "CIDR block for the public subnet"
  type        = string
  default     = "10.20.1.0/24"
}

# Web server size
variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t3.micro"
}

# Route 53 hosted zone
variable "domain_name" {
  description = "Route 53 hosted zone name"
  type        = string
  default     = "localhostshinn.xyz"
}

# Website DNS name
variable "website_hostname" {
  description = "DNS name for the website"
  type        = string
  default     = "agex-dev.localhostshinn.xyz"
}
