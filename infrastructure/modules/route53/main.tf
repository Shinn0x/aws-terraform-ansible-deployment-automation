# Find the public hosted zone
data "aws_route53_zone" "this" {
  name         = var.domain_name
  private_zone = false
}

# Point the hostname to the IP address
resource "aws_route53_record" "this" {
  zone_id = data.aws_route53_zone.this.zone_id
  name    = var.hostname
  type    = "A"
  ttl     = 300

  records = [var.ip_address]
}
