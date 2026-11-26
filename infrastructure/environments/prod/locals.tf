locals {
  environment = "prod"

  # Tags for all resources
  common_tags = {
    Project     = var.project_name
    Environment = local.environment
    ManagedBy   = "Terraform"
  }

  # Prefix for resource names
  name_prefix = "${var.project_name}-${local.environment}"
}
