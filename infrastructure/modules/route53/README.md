# Route 53 Module

Creates the DNS record that points the website name to the web server.

| Resource | Purpose |
|---|---|
| `data.aws_route53_zone` | Finds the public hosted zone. The zone already exists, so Terraform doesn't create it. |
| `aws_route53_record` | `A` record, TTL 300, pointing to the Elastic IP |

It points to the Elastic IP, which keeps the same address when the instance stops and starts.

## Usage

```hcl
module "website_dns" {
  source = "../../modules/route53"

  domain_name = var.domain_name
  hostname    = var.website_hostname
  ip_address  = module.web_server.public_ip
}
```

## Inputs

| Name | Description |
|---|---|
| `domain_name` | Route 53 hosted zone name, for example `localhostshinn.xyz` |
| `hostname` | DNS name for the record, for example `agex-dev.localhostshinn.xyz` |
| `ip_address` | IPv4 address the record points to |

## Outputs

| Name | Description |
|---|---|
| `fqdn` | Full DNS name of the record, for `website_url` |
| `zone_id` | ID of the hosted zone |
