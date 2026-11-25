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
│       ├── check-github-oidc.sh
│       └── terraform.tfvars.example
├── infrastructure/
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
├── .gitignore
└── README.md
```

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
- An IAM permissions policy for Terraform state access

GitHub Actions will use temporary AWS credentials through OIDC instead of long-lived AWS access keys.

The GitHub OIDC provider may already exist in the AWS account. If it exists outside Terraform state, it should be imported into Terraform rather than recreated.

The initial OIDC bootstrap uses local Terraform state. The state can later be migrated to the S3 backend. `terraform.tfstate` is git-ignored, so keep a backup of it.

### Usage

```bash
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

The permissions policy (`github-actions-policy.json`) is a template. Terraform fills in the state bucket name from the `state_bucket_name` variable.

All resources get `Project`, `Environment` and `ManagedBy` tags from the provider's `default_tags`.

`terraform.tfvars.example` lists every variable with its default value.

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

`.github/workflows/terraform.yaml` runs when files under `infrastructure/`, `bootstrap/02-github-oidc/` or `.github/workflows/` change.

| Event | Terraform checks | OIDC role test |
|---|---|---|
| Pull request to `main` | Run | Skipped |
| Push to `main`, including a merged PR | Run | Run |
| Manual run on `main` | Run | Run |
| Manual run on another branch | Run | Skipped |

- **Terraform checks:** `terraform fmt -check` across the repository, plus `init` and `validate` for `bootstrap/02-github-oidc` and `infrastructure/environments/dev`.
- **OIDC role test:** assumes the IAM role through OIDC, checks that the identity is `github-actions-terraform-role`, and checks that the role can list the state bucket.

The OIDC steps are skipped on pull requests because a PR run sends a `pull_request` subject, which the trust policy does not allow.

The workflow reads the role ARN from the `AWS_ROLE_ARN` repository variable. Set it from the Terraform output:

```bash
cd bootstrap/02-github-oidc
gh variable set AWS_ROLE_ARN --body "$(terraform output -raw github_actions_role_arn)"
```

Detailed documentation:

[GitHub Actions OIDC Setup](docs/02-github-actions-oidc.md)

## Section 03 — Infrastructure Provisioning

Terraform will provision the AWS infrastructure required for the website deployment.

Planned resources include:

- VPC and networking
- EC2 instance
- IAM roles and instance permissions
- Security groups

## Section 04 — Configuration and Deployment

Ansible will configure the EC2 instance and deploy the website.

The deployment will be automated through GitHub Actions and use AWS Systems Manager where appropriate to avoid managing SSH keys.

## Section 05 — Deployment Verification

The final stage will run automated health checks to confirm that the website is reachable and responding correctly.

## Security Considerations

- Use IAM roles and temporary credentials where possible.
- Restrict GitHub OIDC trust to the intended repository and branch, using immutable owner and repository IDs.
- Only assume the AWS role from `main` in CI. Pull request runs check and validate Terraform without AWS access.
- Block public access to the Terraform state bucket.
- Enable S3 versioning to support state recovery.
- Do not commit AWS credentials, Terraform state files, or sensitive variables.
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
- [ ] Terraform CI workflow verified on `main`
- [ ] Configure Terraform remote state
- [ ] Provision AWS infrastructure
- [ ] Automate deployment with Ansible
- [ ] Add deployment health checks

## Learning Objectives

This project demonstrates practical experience with AWS infrastructure automation, Terraform state management, IAM OIDC authentication, CI/CD pipelines, configuration management, and automated deployment verification.
