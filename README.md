# AWS Terraform Ansible Deployment Automation

A reusable AWS infrastructure provisioning and application deployment project using Terraform, Ansible, GitHub Actions, and AWS IAM OIDC.

## Project Overview

This project demonstrates how to automate the provisioning of AWS infrastructure and deployment of a website without relying on manual AWS Console setup.

The goal is to build a repeatable workflow that can provision infrastructure, configure servers, deploy an application, and verify that the deployment is healthy.

## Architecture

The project is developed in the following stages:

1. Bootstrap an S3 bucket for Terraform remote state.
2. Configure GitHub Actions authentication using AWS IAM OIDC.
3. Provision AWS infrastructure using Terraform.
4. Configure the EC2 instance and deploy a website using Ansible.
5. Run automated health checks to verify the deployment.

See [Architecture](docs/architecture.md) for how the components fit together.

## Technology Stack

- AWS
- Terraform
- Ansible
- GitHub Actions
- AWS CLI
- Bash
- Git and GitHub

## Project Structure

```text
.
├── bootstrap/
│   ├── 01-state-bucket/
│   │   ├── create-state-bucket.sh
│   │   ├── encryption.json
│   │   ├── lifecycle.json
│   │   ├── ownership-controls.json
│   │   └── public-access-block.json
│   └── 02-github-oidc/
│       ├── providers.tf
│       ├── variables.tf
│       ├── main.tf
│       ├── outputs.tf
│       ├── github-actions-policy.json
│       └── check-github-oidc.sh
├── infrastructure/
│   ├── modules/                  # reusable modules, no provider or backend
│   │   ├── vpc/
│   │   ├── security-group/
│   │   ├── iam/
│   │   └── ec2/
│   └── environments/             # Terraform runs here only
│       ├── dev/
│       │   ├── backend.tf        # terraform block and S3 backend
│       │   ├── providers.tf      # AWS provider and default tags
│       │   ├── locals.tf         # environment name, tags, name prefix
│       │   ├── variables.tf
│       │   ├── main.tf           # calls the four modules
│       │   └── outputs.tf
│       └── prod/                 # same files, prod values
├── configuration/
├── application/
├── scripts/
├── docs/
│   ├── architecture.md
│   ├── 01-s3-state-bucket-bootstrap.md
│   └── 02-github-actions-oidc.md
├── .github/
│   └── workflows/
│       └── terraform.yaml
├── .env.example
├── .gitignore
└── README.md
```

## Local Configuration (`.env`)

The AWS account ID and the GitHub owner and repository IDs are not stored in the repository. Terraform reads them from `TF_VAR_*` environment variables, which you keep in a local `.env` file. `.env` is git-ignored.

```bash
cp .env.example .env
# Fill in the values. The comments in the file show how to look each one up.

# Load .env into your shell before running Terraform
set -a && source .env && set +a
```

| Variable | Used by | Purpose |
|---|---|---|
| `TF_VAR_aws_account_id` | `bootstrap/02-github-oidc`, `infrastructure/environments/dev`, `infrastructure/environments/prod` | Terraform refuses to run against any other account (`allowed_account_ids`) |
| `TF_VAR_github_owner_id` | `bootstrap/02-github-oidc` | Immutable owner ID in the OIDC trust policy |
| `TF_VAR_github_repo_id` | `bootstrap/02-github-oidc` | Immutable repository ID in the OIDC trust policy |

GitHub Actions gets the values it needs from repository secrets instead. See [GitHub Actions Workflow](#github-actions-workflow).

## Section 01 — Terraform State Bucket Bootstrap

The first stage creates an S3 bucket to store Terraform state.

The bucket is created using AWS CLI and configured with security and lifecycle settings.

### Configuration

- AWS Region: `ap-southeast-1`
- Versioning: Enabled
- Default encryption: SSE-S3
- Public access: Blocked
- Object ownership: BucketOwnerEnforced
- Noncurrent object versions: Expire after 90 days (the 5 newest are always kept)
- Expired delete markers: Removed
- Incomplete multipart uploads: Abort after 7 days

The lifecycle policy preserves the current Terraform state while cleaning up older versions and incomplete uploads.

### Bootstrap Script

```text
bootstrap/01-state-bucket/create-state-bucket.sh
```

The script creates and configures the S3 bucket using AWS CLI.

### Prerequisites

- AWS CLI installed
- AWS CLI configured with appropriate permissions
- A globally unique S3 bucket name

### Usage

The bucket name and region are set at the top of the script:

```bash
BUCKET_NAME="shinn-terraform-state-foundation"
AWS_REGION="ap-southeast-1"
```

S3 bucket names are globally unique, so change `BUCKET_NAME` if you reuse this project in another AWS account. Update `state_bucket_name` in `bootstrap/02-github-oidc/variables.tf` to match.

Run the script:

```bash
chmod +x bootstrap/01-state-bucket/create-state-bucket.sh

./bootstrap/01-state-bucket/create-state-bucket.sh
```

The script is safe to re-run. If you already own the bucket, it skips creation and re-applies the settings.

The verification commands use shell variables, so set them in your terminal first:

```bash
BUCKET_NAME="shinn-terraform-state-foundation"
AWS_REGION="ap-southeast-1"
```

Verify bucket versioning:

```bash
aws s3api get-bucket-versioning \
  --bucket "$BUCKET_NAME" \
  --region "$AWS_REGION"
```

Verify the lifecycle configuration:

```bash
aws s3api get-bucket-lifecycle-configuration \
  --bucket "$BUCKET_NAME" \
  --region "$AWS_REGION"
```

Detailed documentation:

[S3 Terraform State Bucket Bootstrap](docs/01-s3-state-bucket-bootstrap.md)

## Section 02 — GitHub Actions OIDC

This stage configures AWS IAM OIDC authentication for GitHub Actions.

Terraform manages:

- GitHub's OIDC identity provider in AWS IAM
- An IAM role for GitHub Actions
- A trust policy restricted to this repository's `main` branch, matched by name and immutable GitHub ID
- An IAM permissions policy for Terraform state access and VPC management

GitHub Actions will use temporary AWS credentials through OIDC instead of long-lived AWS access keys.

The GitHub OIDC provider may already exist in the AWS account. If it exists outside Terraform state, it should be imported into Terraform rather than recreated.

The initial OIDC bootstrap uses local Terraform state. The state can later be migrated to the S3 backend. `terraform.tfstate` is git-ignored, so keep a backup of it.

### Usage

```bash
# Load the account and GitHub IDs (see Local Configuration)
set -a && source .env && set +a

cd bootstrap/02-github-oidc

# Check whether the GitHub OIDC provider already exists
./check-github-oidc.sh

terraform init
terraform plan
terraform apply

# Role ARN for the GitHub Actions workflow
terraform output github_actions_role_arn
```

If the provider already exists but is not in Terraform state, import it before applying. The detailed documentation covers this.

The permissions policy (`github-actions-policy.json`) is a template. Terraform fills in the state bucket name, the region and the account ID, so the account ID is never written into the repository.

The policy allows:

- reading and writing the Terraform state bucket
- managing the VPC, subnet, internet gateway and route table, in this account and region only (`Describe*` calls can't be scoped to a resource, so they are limited to the region)

All resources get `Project`, `Environment` and `ManagedBy` tags from the provider's `default_tags`.

`aws_account_id`, `github_owner_id` and `github_repo_id` have no defaults. They come from `.env`.

### Trust Policy Subject

The trust policy uses GitHub's immutable subject format, which includes the owner and repository IDs:

```text
repo:OWNER@OWNER_ID/REPO@REPO_ID:ref:refs/heads/main
```

The IDs stay the same if the owner or repository is renamed, so a different repository that reuses the name cannot assume the role. GitHub uses this format by default for repositories created after July 15, 2026.

Print the exact subject the role trusts:

```bash
terraform output github_oidc_subject
```

Only workflows running on `main` match this subject.

### GitHub Actions Workflow

`.github/workflows/terraform.yaml` runs when files under `infrastructure/`, `bootstrap/02-github-oidc/`, or the workflow file itself change.

| Event | `validate` job | `deploy` job |
|---|---|---|
| Pull request to `main` | Run | Skipped |
| Push to `main`, including a merged PR | Run | Run |
| Manual run on `main` | Run | Run |
| Manual run on another branch | Run | Skipped |

- **`validate`:** `terraform fmt -check` across the repository, plus `init -backend=false` and `validate` for `bootstrap/02-github-oidc`, `infrastructure/environments/dev` and `infrastructure/environments/prod`. Validating an environment also validates every module it uses. It needs no AWS access.
- **`deploy`:** runs after `validate` passes. It assumes the IAM role through OIDC, checks that the identity is `github-actions-terraform-role` in the account from the `AWS_ACCOUNT_ID` secret, and checks that the role can list the state bucket. Then it runs `terraform plan -out=tfplan` and `terraform apply tfplan` in `infrastructure/environments/dev`. Applies are queued, never run in parallel.

`deploy` is skipped on pull requests and other branches because those runs send a different OIDC subject, which the trust policy does not allow.

CI applies **dev only**. prod is validated but applied from your machine (see Section 03).

**Merging to `main` applies dev to AWS.** Review the plan in the PR description, or run `terraform plan` locally, before merging.

### Repository Secrets

The workflow reads the account-specific values from repository secrets. Secret values are masked in workflow logs, and `mask-aws-account-id` also masks the account ID returned by AWS.

| Secret | Used by | Value |
|---|---|---|
| `AWS_ROLE_ARN` | `deploy` | `terraform output -raw github_actions_role_arn` |
| `AWS_ACCOUNT_ID` | `deploy` | Same as `TF_VAR_aws_account_id` in `.env` |
| `GH_OWNER_ID` | Not used by CI | Same as `TF_VAR_github_owner_id`, kept with the other values for reference |
| `GH_REPO_ID` | Not used by CI | Same as `TF_VAR_github_repo_id`, kept with the other values for reference |

Set them from `.env` and the Terraform output:

```bash
set -a && source .env && set +a

gh secret set AWS_ACCOUNT_ID --body "$TF_VAR_aws_account_id"
gh secret set GH_OWNER_ID --body "$TF_VAR_github_owner_id"
gh secret set GH_REPO_ID --body "$TF_VAR_github_repo_id"
gh secret set AWS_ROLE_ARN --body "$(terraform -chdir=bootstrap/02-github-oidc output -raw github_actions_role_arn)"
```

GitHub does not allow secret names that start with `GITHUB_`, so the GitHub IDs use the `GH_` prefix.

Detailed documentation:

[GitHub Actions OIDC Setup](docs/02-github-actions-oidc.md)

## Section 03 — Infrastructure Provisioning

Terraform provisions the AWS infrastructure required for the website deployment.

### Modules and Environments

The code is split in two:

- **`infrastructure/modules/`** holds reusable modules. A module has only resources, variables and outputs: no `terraform` block, no provider, no backend and no locals.
- **`infrastructure/environments/dev/`** and **`prod/`** are the only places Terraform runs. Each one has the `terraform` block with the S3 backend, the AWS provider, the locals, and a `main.tf` that calls the modules.

| Module | Creates | Docs |
|---|---|---|
| `vpc` | VPC, public subnet, internet gateway, route table | [README](infrastructure/modules/vpc/README.md) |
| `security-group` | Web server security group: HTTP and HTTPS in, HTTP and HTTPS out | [README](infrastructure/modules/security-group/README.md) |
| `iam` | EC2 role with `AmazonSSMManagedInstanceCore`, and its instance profile | [README](infrastructure/modules/iam/README.md) |
| `ec2` | Amazon Linux 2023 web server: IMDSv2, encrypted disk, no SSH key | [README](infrastructure/modules/ec2/README.md) |

Each environment calls all four modules. The settings that differ:

| Setting | dev | prod |
|---|---|---|
| State | `s3://shinn-terraform-state-foundation/environments/dev/terraform.tfstate` | `.../environments/prod/terraform.tfstate` |
| VPC CIDR | `10.20.0.0/16` | `10.30.0.0/16` |
| Public subnet | `10.20.1.0/24` | `10.30.1.0/24` |
| Instance type | `t3.micro` | `t3.micro` |
| Applied by | GitHub Actions on `main`, or locally | Locally only |

Both states use the S3 native lock file (`use_lockfile = true`, Terraform 1.10 or later). Resource names start with `<project_name>-<environment>`, for example `aws-terraform-ansible-deployment-automation-dev-vpc`. The environment name is fixed in each folder's `locals.tf`, so the dev folder can't create prod resources by mistake.

### Run an Environment Locally

```bash
set -a && source .env && set +a

cd infrastructure/environments/dev    # or prod
terraform init
terraform plan
terraform apply
```

Outputs: `vpc_id`, `public_subnet_id`, `security_group_id`, `instance_id`, `public_ip` and `website_url`.

### Destroy an Environment

Destroy runs from your machine. The workflow has no destroy step.

```bash
set -a && source .env && set +a

cd infrastructure/environments/dev    # or prod
terraform init

# Save a destroy plan, check it lists only this environment's resources, then apply it
terraform plan -destroy -out=destroy.tfplan
terraform apply destroy.tfplan
rm destroy.tfplan
```

The state file stays in S3 with no resources, so the next apply starts fresh.

**dev comes back on the next deploy.** Any push to `main` that changes `infrastructure/`, `bootstrap/02-github-oidc/` or the workflow file runs the `deploy` job, and so does a manual run on `main`. Comment-only changes count too. To keep dev down, disable the workflow before merging, and enable it again when you want dev back:

```bash
gh workflow disable terraform.yaml
gh workflow enable terraform.yaml
```

### CI Permissions

The GitHub Actions role can only manage the VPC so far (`VpcRead` and `VpcManage` in `github-actions-policy.json`). Until it also gets permissions for security groups, IAM roles and instance profiles, EC2 instances, and reading the AMI parameter from SSM, the `deploy` job stops at `terraform plan` with `AccessDenied`. Nothing is created in that case.

## Section 04 — Configuration and Deployment

Ansible will configure the EC2 instance and deploy the website.

The deployment will be automated through GitHub Actions and use AWS Systems Manager where appropriate to avoid managing SSH keys.

## Section 05 — Deployment Verification

The final stage will run automated health checks to confirm that the website is reachable and responding correctly.

## Security Considerations

- Use IAM roles and temporary credentials where possible.
- Restrict GitHub OIDC trust to the intended repository and branch, using immutable owner and repository IDs.
- Only assume the AWS role from `main` in CI. Pull request runs check and validate Terraform without AWS access.
- Protect `main` with a repository ruleset: changes go through pull requests, and the branch can't be deleted.
- Block public access to the Terraform state bucket.
- Enable S3 versioning to support state recovery.
- Do not commit AWS credentials, Terraform state files, or sensitive variables.
- Keep the AWS account ID and GitHub IDs out of the repository: locally in `.env`, in CI as repository secrets.
- Pin Terraform to the expected AWS account with `allowed_account_ids`, so a wrong AWS profile fails before any change.
- Keep the current Terraform state object protected from lifecycle expiration.
- Grant GitHub Actions only the AWS permissions required for its tasks.

## Project Status

- [x] Repository initialized
- [x] S3 state bucket bootstrap script created
- [x] S3 state bucket created and verified
- [x] GitHub OIDC Terraform configuration created
- [x] GitHub OIDC provider managed in Terraform state
- [x] GitHub Actions IAM role and state access policy created and verified
- [x] Trust policy bound to immutable GitHub owner and repository IDs
- [x] OIDC role tested from a GitHub Actions workflow (temporary test branch)
- [x] Terraform CI workflow added (fmt, validate, OIDC role test on `main`)
- [x] Terraform CI workflow verified on `main`
- [x] Account ID and GitHub IDs moved out of the repository into `.env` and repository secrets
- [x] VPC configuration with S3 remote state
- [x] CI plans and applies the VPC on `main`
- [x] VPC applied by CI and verified (6 resources), then destroyed locally with `terraform destroy`
- [x] Security group, IAM and EC2 modules created
- [x] Modules split from environments: `infrastructure/environments/dev` and `prod` call all four modules
- [ ] CI role permissions for security groups, IAM and EC2
- [ ] dev environment applied and verified
- [ ] Automate deployment with Ansible
- [ ] Add deployment health checks

## Learning Objectives

This project demonstrates practical experience with AWS infrastructure automation, Terraform state management, IAM OIDC authentication, CI/CD pipelines, configuration management, and automated deployment verification.
