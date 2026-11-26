# Name of the security group, e.g. aws-terraform-ansible-deployment-automation-dev-web
variable "name" {
  description = "Name of the security group"
  type        = string
}

# VPC the security group belongs to
variable "vpc_id" {
  description = "VPC ID where the security group will be created"
  type        = string
}
