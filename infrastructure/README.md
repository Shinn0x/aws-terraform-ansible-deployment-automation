# Infrastructure

Terraform code for the AWS resources of each environment.

```text
infrastructure/
├── modules/          reusable modules: resources, variables and outputs only
│   ├── vpc/
│   ├── security-group/
│   ├── iam/
│   ├── ec2/
│   ├── s3/
│   └── route53/
└── environments/     Terraform runs here only
    ├── dev/
    └── prod/
```

## Modules

| Module | Creates |
|---|---|
| [`vpc`](modules/vpc/README.md) | VPC, public subnet, internet gateway, route table |
| [`security-group`](modules/security-group/README.md) | Web server security group: HTTP and HTTPS in, HTTP and HTTPS out |
| [`iam`](modules/iam/README.md) | EC2 role with `AmazonSSMManagedInstanceCore`, and its instance profile |
| [`ec2`](modules/ec2/README.md) | Amazon Linux 2023 web server with an Elastic IP: IMDSv2, encrypted disk, no SSH key |
| [`s3`](modules/s3/README.md) | Private bucket Ansible uses to copy files to the instance over SSM |
| [`route53`](modules/route53/README.md) | `A` record that points the website name to the Elastic IP |

Modules have no `terraform` block, provider, backend or locals. The environment sets those.

## Environments

Each environment has the same files:

| File | Contents |
|---|---|
| `backend.tf` | `terraform` block and S3 backend |
| `providers.tf` | AWS provider, `allowed_account_ids` and `default_tags` |
| `locals.tf` | Environment name, tags, name prefix |
| `variables.tf` | Settings for this environment |
| `main.tf` | Calls the six modules |
| `outputs.tf` | `vpc_id`, `public_subnet_id`, `security_group_id`, `instance_id`, `public_ip`, `website_url`, `ansible_bucket_name` |

| Setting | dev | prod |
|---|---|---|
| State | `environments/dev/terraform.tfstate` | `environments/prod/terraform.tfstate` |
| VPC CIDR | `10.20.0.0/16` | `10.30.0.0/16` |
| Public subnet | `10.20.1.0/24` | `10.30.1.0/24` |
| Instance type | `t3.micro` | `t3.micro` |
| Website | `https://agex-dev.localhostshinn.xyz` | `https://agex.localhostshinn.xyz` |
| Deployed by | A push to `main` that changes deployed files | A manual workflow run |

- State is in `s3://shinn-terraform-state-foundation`, locked with the S3 lock file (`use_lockfile`). The bucket is created once, outside this repository. See [AWS setup](../ci-policies/README.md#set-up).
- Resource names start with `<project_name>-<environment>`, for example `aws-terraform-ansible-deployment-automation-dev-vpc`.
- The environment name is fixed in `locals.tf`, so the dev folder can't create prod resources.

## Run Locally

```bash
set -a && source .env && set +a

cd infrastructure/environments/dev    # or prod
terraform init
terraform plan
terraform apply
```

## Destroy

Use the workflow: run **Deploy** manually with `action` set to `destroy` and the environment name in `confirm`. See [the workflows README](../.github/workflows/README.md#destroy).

Or run it from your machine:

```bash
set -a && source .env && set +a

cd infrastructure/environments/dev    # or prod
terraform init
terraform plan -destroy -out=destroy.tfplan    # check it lists only this environment
terraform apply destroy.tfplan
rm destroy.tfplan
```

dev comes back on the next push to `main` that changes deployed files. To keep it down, disable the workflow first:

```bash
gh workflow disable deploy.yaml
gh workflow enable deploy.yaml    # when you want dev back
```
