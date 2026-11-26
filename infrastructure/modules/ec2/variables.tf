# Name tag of the instance
variable "name" {
  description = "Name of the EC2 instance"
  type        = string
}

# Instance size. Must be x86_64 to match the AMI
variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t3.micro"
}

# Public subnet from the vpc module
variable "subnet_id" {
  description = "Subnet ID where the instance is created"
  type        = string
}

# Security group from the security-group module
variable "security_group_id" {
  description = "Security group ID attached to the instance"
  type        = string
}

# Instance profile from the iam module
variable "instance_profile_name" {
  description = "IAM instance profile name attached to the instance"
  type        = string
}
