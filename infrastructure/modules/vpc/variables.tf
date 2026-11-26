# Prefix for resource names
variable "name" {
  description = "Prefix for the Name tags of the VPC resources"
  type        = string
}

# VPC IP range
variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
}

# Public subnet IP range
variable "public_subnet_cidr" {
  description = "CIDR block for the public subnet"
  type        = string
}
