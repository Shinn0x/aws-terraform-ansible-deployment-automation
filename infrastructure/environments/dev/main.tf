# Create the network
module "vpc" {
  source = "../../modules/vpc"

  name               = local.name_prefix
  vpc_cidr           = var.vpc_cidr
  public_subnet_cidr = var.public_subnet_cidr
}

# Create the web server security group
module "web_security_group" {
  source = "../../modules/security-group"

  name   = "${local.name_prefix}-web"
  vpc_id = module.vpc.vpc_id
}

# Create the IAM role and instance profile for the web server
module "web_iam" {
  source = "../../modules/iam"

  name = "${local.name_prefix}-web"
}

# Create the web server
module "web_server" {
  source = "../../modules/ec2"

  name                  = "${local.name_prefix}-web"
  instance_type         = var.instance_type
  subnet_id             = module.vpc.public_subnet_id
  security_group_id     = module.web_security_group.security_group_id
  instance_profile_name = module.web_iam.instance_profile_name
}

# Find the public hosted zone
data "aws_route53_zone" "main" {
  name         = var.domain_name
  private_zone = false
}

# Point the website name to the web server
resource "aws_route53_record" "agex" {
  zone_id = data.aws_route53_zone.main.zone_id
  name    = var.website_hostname
  type    = "A"
  ttl     = 300

  records = [module.web_server.public_ip]
}
