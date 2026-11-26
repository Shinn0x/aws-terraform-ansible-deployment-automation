output "vpc_id" {
  description = "ID of the VPC"
  value       = module.vpc.vpc_id
}

output "public_subnet_id" {
  description = "ID of the public subnet"
  value       = module.vpc.public_subnet_id
}

output "security_group_id" {
  description = "ID of the web server security group"
  value       = module.web_security_group.security_group_id
}

output "instance_id" {
  description = "ID of the web server instance"
  value       = module.web_server.instance_id
}

output "public_ip" {
  description = "Public IP address of the web server"
  value       = module.web_server.public_ip
}

output "website_url" {
  description = "URL of the website"
  value       = "https://${module.website_dns.fqdn}"
}

output "ansible_bucket_name" {
  description = "S3 bucket for Ansible file transfers over SSM"
  value       = module.ansible_bucket.bucket_name
}
