# Security Group Module

Creates the web server security group.

| Direction | Port | From / to |
|---|---|---|
| Inbound | 80 (HTTP) | `0.0.0.0/0` |
| Inbound | 443 (HTTPS) | `0.0.0.0/0` |
| Outbound | 80 (HTTP) | `0.0.0.0/0`, package repositories |
| Outbound | 443 (HTTPS) | `0.0.0.0/0`, package updates and AWS Systems Manager |

SSH is not open. Connect to the instance with AWS Systems Manager Session Manager instead.

The module has no provider or backend. The environment that calls it configures the provider, and its `default_tags` add `Project`, `Environment` and `ManagedBy`.

## Usage

```hcl
module "web_security_group" {
  source = "../../modules/security-group"

  name   = "${local.name_prefix}-web"
  vpc_id = module.vpc.vpc_id
}
```

Attach it to the instance:

```hcl
vpc_security_group_ids = [module.web_security_group.security_group_id]
```

## Inputs

| Name | Description |
|---|---|
| `name` | Name of the security group. AWS adds a unique suffix. |
| `vpc_id` | VPC ID, usually `module.vpc.vpc_id` |

## Outputs

| Name | Description |
|---|---|
| `security_group_id` | ID to attach to instances |
| `security_group_arn` | ARN of the security group |
| `security_group_name` | Full AWS name, including the unique suffix |
