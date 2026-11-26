# Hosted zone that already exists in Route 53
variable "domain_name" {
  description = "Route 53 hosted zone name"
  type        = string
}

# Full DNS name, inside the hosted zone
variable "hostname" {
  description = "DNS name for the record"
  type        = string
}

# Elastic IP from the ec2 module
variable "ip_address" {
  description = "IPv4 address the record points to"
  type        = string
}
