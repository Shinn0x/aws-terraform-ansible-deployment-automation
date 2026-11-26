locals {
  # Tags added to every resource through the provider's default_tags
  common_tags = {
    Project     = var.project_name
    Environment = var.environment
    ManagedBy   = "Terraform"
  }

  # Prefix for resource names, e.g. aws-terraform-ansible-deployment-automation-dev
  name_prefix = "${var.project_name}-${var.environment}"
}
