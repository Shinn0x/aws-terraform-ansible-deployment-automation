# EC2 Module

Creates the EC2 web server instance and its Elastic IP.

| Setting | Value |
|---|---|
| AMI | Latest Amazon Linux 2023 (x86_64), from the AWS public SSM parameter `/aws/service/ami-amazon-linux-latest/al2023-ami-kernel-default-x86_64` |
| Instance type | `t3.micro` by default (Free Tier eligible) |
| Public IP | Elastic IP, so the address stays the same when the instance stops and starts |
| Instance metadata | IMDSv2 required |
| Root disk | gp3, encrypted |
| SSH key | None. Connect with AWS Systems Manager Session Manager. |

Amazon Linux 2023 comes with the SSM Agent installed. The instance registers with Systems Manager through the instance profile from the `iam` module.

When AWS releases a newer AMI, Terraform keeps the existing instance (`ignore_changes = [ami]`). To move to the new AMI, replace the instance on purpose:

```bash
terraform apply -replace="module.web_server.aws_instance.web"
```

The module has no provider or backend. The environment that calls it configures the provider, and its `default_tags` add `Project`, `Environment` and `ManagedBy`.

## Usage

```hcl
module "web_server" {
  source = "../../modules/ec2"

  name                  = "${local.name_prefix}-web"
  instance_type         = "t3.micro"
  subnet_id             = module.vpc.public_subnet_id
  security_group_id     = module.web_security_group.security_group_id
  instance_profile_name = module.web_iam.instance_profile_name
}
```

## Inputs

| Name | Default | Description |
|---|---|---|
| `name` | | Name tag of the instance |
| `instance_type` | `t3.micro` | Must be an x86_64 type (t3, t3a, ...) |
| `subnet_id` | | Public subnet, from the `vpc` module |
| `security_group_id` | | From the `security-group` module |
| `instance_profile_name` | | From the `iam` module |

## Outputs

| Name | Description |
|---|---|
| `instance_id` | ID of the instance |
| `public_ip` | Elastic IP address |
| `public_dns` | Public DNS name of the Elastic IP |
| `private_ip` | Private IP address |
| `ami_id` | AMI the instance was created from |
