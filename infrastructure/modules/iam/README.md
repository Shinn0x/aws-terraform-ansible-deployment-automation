# IAM Module

Creates the IAM role and instance profile for the EC2 web server.

| Resource | Name | Purpose |
|---|---|---|
| `aws_iam_role` | `<name>-role` | Role that EC2 is trusted to assume (`ec2.amazonaws.com`) |
| `aws_iam_role_policy_attachment` | | Attaches `AmazonSSMManagedInstanceCore`, so the instance can use AWS Systems Manager |
| `aws_iam_instance_profile` | `<name>-profile` | Makes the role usable by EC2 |

With Systems Manager, Ansible and Session Manager reach the instance without SSH keys or an open SSH port.

The module has no provider or backend. The environment that calls it configures the provider, and its `default_tags` add `Project`, `Environment` and `ManagedBy`.

## Usage

```hcl
module "web_iam" {
  source = "../../modules/iam"

  name = "${local.name_prefix}-web"
}
```

Attach it to the instance:

```hcl
iam_instance_profile = module.web_iam.instance_profile_name
```

IAM names must be unique in the AWS account, so dev and prod need different names. `local.name_prefix` already includes the environment. The role name must be 64 characters or fewer: `<name>-role`.

## Inputs

| Name | Description |
|---|---|
| `name` | Base name for the role and instance profile |

## Outputs

| Name | Description |
|---|---|
| `role_name` | Name of the IAM role |
| `role_arn` | ARN of the IAM role |
| `instance_profile_name` | Name of the instance profile, for `iam_instance_profile` |
| `instance_profile_arn` | ARN of the instance profile |
