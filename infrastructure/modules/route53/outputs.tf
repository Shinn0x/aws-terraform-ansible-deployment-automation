output "fqdn" {
  description = "Full DNS name of the record"
  value       = aws_route53_record.this.fqdn
}

output "zone_id" {
  description = "ID of the hosted zone"
  value       = data.aws_route53_zone.this.zone_id
}
