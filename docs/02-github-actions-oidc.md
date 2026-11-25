# Section 02 — GitHub Actions OIDC Setup

This document explains how to configure AWS IAM OIDC authentication for GitHub Actions using Terraform.

The objective is to allow GitHub Actions to authenticate with AWS using temporary credentials without storing long-lived AWS access keys in GitHub Secrets.

## 1. Overview

The authentication flow:

1. A GitHub Actions workflow requests an OIDC token from GitHub.
2. GitHub Actions presents the token to AWS STS.
3. AWS validates the token against the GitHub OIDC identity provider.
4. AWS checks the IAM role's trust policy.
5. If the token matches the trust policy, AWS returns temporary credentials.
6. Terraform uses those credentials to access AWS resources.

## 2. Prerequisites

- AWS CLI installed and configured
- Terraform installed
- Access to the target AWS account
- GitHub repository created
- Permission to manage IAM OIDC providers, roles, and policies
- GitHub CLI (`gh`), optional, to look up the owner and repository IDs

Repository:

```text
Shinn0x/aws-terraform-ansible-deployment-automation
```

AWS Region:

```text
ap-southeast-1
```

## 3. Directory Structure

```text
bootstrap/
└── 02-github-oidc/
    ├── providers.tf
    ├── variables.tf
    ├── main.tf
    ├── outputs.tf
    ├── github-actions-policy.json
    ├── check-github-oidc.sh
    └── terraform.tfvars.example
```

## 4. Check Whether the OIDC Provider Exists

GitHub's OIDC provider URL is:

```text
https://token.actions.githubusercontent.com
```

An AWS account may already have this provider registered. Check before creating it.

Get the AWS account ID:

```bash
aws sts get-caller-identity \
  --query Account \
  --output text
```

Build the provider ARN:

```bash
ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)

OIDC_ARN="arn:aws:iam::${ACCOUNT_ID}:oidc-provider/token.actions.githubusercontent.com"
```

Check the provider:

```bash
aws iam get-open-id-connect-provider \
  --open-id-connect-provider-arn "$OIDC_ARN"
```

If the provider exists, AWS returns its configuration.

If it does not exist, AWS returns an error indicating that the provider cannot be found.

### Using the check script

`check-github-oidc.sh` runs the steps above for you:

```bash
cd bootstrap/02-github-oidc
./check-github-oidc.sh
```

| Output | Meaning |
|---|---|
| `GitHub OIDC provider already exists.` and the ARN | The provider is registered. If it is not in Terraform state yet, import it (section 5). |
| `GitHub OIDC provider does not exist.` | Terraform will create it on `terraform apply`. |
| `Error: could not check the GitHub OIDC provider:` (exit code 1) | The check itself failed, for example because `iam:GetOpenIDConnectProvider` is not allowed. Fix the error and re-run. |

## 5. Import an Existing Provider into Terraform

If the provider already exists in AWS but is not managed by Terraform, import it.

Initialize Terraform:

```bash
terraform init
```

Import the provider:

```bash
terraform import \
  aws_iam_openid_connect_provider.github \
  "$OIDC_ARN"
```

Importing does not create or delete the AWS resource. It records the existing resource in Terraform state.

Check the Terraform state:

```bash
terraform state list
```

Expected resource:

```text
aws_iam_openid_connect_provider.github
```

Review the Terraform plan:

```bash
terraform plan
```

Inspect any proposed changes before applying. Do not blindly apply a plan that proposes replacing or deleting the existing OIDC provider.

## 6. Terraform Provider Configuration

`providers.tf`

```hcl
terraform {
  required_version = ">= 1.5.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

locals {
  project_name = "aws-terraform-ansible-deployment-automation"
  environment  = var.environment

  common_tags = {
    Project     = local.project_name
    Environment = local.environment
    ManagedBy   = "Terraform"
  }
}

provider "aws" {
  region = var.aws_region

  default_tags {
    tags = local.common_tags
  }
}
```

`default_tags` adds `common_tags` to every resource this provider creates, so the resources in `main.tf` do not need their own `tags` blocks.

## 7. Terraform Variables

`variables.tf`

```hcl
variable "aws_region" {
  description = "AWS region for the OIDC bootstrap"
  type        = string
  default     = "ap-southeast-1"
}

variable "environment" {
  description = "Deployment environment"
  type        = string
  default     = "dev"
}

variable "github_owner" {
  description = "GitHub repository owner"
  type        = string
  default     = "Shinn0x"
}

variable "github_owner_id" {
  description = "Immutable GitHub owner ID"
  type        = string
  default     = "REDACTED_GITHUB_OWNER_ID"

  validation {
    condition     = can(regex("^[0-9]+$", var.github_owner_id))
    error_message = "github_owner_id must be the numeric GitHub owner ID (gh api users/OWNER --jq .id)."
  }
}

variable "github_repo" {
  description = "GitHub repository name"
  type        = string
  default     = "aws-terraform-ansible-deployment-automation"
}

variable "github_repo_id" {
  description = "Immutable GitHub repository ID"
  type        = string
  default     = "REDACTED_GITHUB_REPO_ID"

  validation {
    condition     = can(regex("^[0-9]+$", var.github_repo_id))
    error_message = "github_repo_id must be the numeric GitHub repository ID (gh api repos/OWNER/REPO --jq .id)."
  }
}

variable "github_branch" {
  description = "Branch allowed to assume the AWS role"
  type        = string
  default     = "main"
}

variable "state_bucket_name" {
  description = "S3 bucket that stores Terraform state (created by 01-state-bucket)"
  type        = string
  default     = "shinn-terraform-state-foundation"
}
```

The owner and repository IDs are numeric and are stored as strings. Look them up with:

```bash
gh api repos/OWNER/REPO --jq '{repo_id: .id, owner_id: .owner.id}'
```

The `validation` blocks stop `terraform plan` early if a name is put in an ID field by mistake. A wrong ID would otherwise only show up as `AccessDenied` in the workflow.

`terraform.tfvars.example` lists every variable with its default value.

## 8. Create the OIDC Provider and IAM Role

`main.tf`

```hcl
data "aws_caller_identity" "current" {}

resource "aws_iam_openid_connect_provider" "github" {
  url = "https://token.actions.githubusercontent.com"

  client_id_list = [
    "sts.amazonaws.com"
  ]
}

# GitHub's immutable subject format (default for repos created after 2026-07-15):
# repo:OWNER@OWNER_ID/REPO@REPO_ID:ref:refs/heads/BRANCH
locals {
  github_oidc_subject = "repo:${var.github_owner}@${var.github_owner_id}/${var.github_repo}@${var.github_repo_id}:ref:refs/heads/${var.github_branch}"
}

data "aws_iam_policy_document" "github_assume_role" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRoleWithWebIdentity"]

    principals {
      type = "Federated"

      identifiers = [
        aws_iam_openid_connect_provider.github.arn
      ]
    }

    condition {
      test     = "StringEquals"
      variable = "token.actions.githubusercontent.com:aud"

      values = [
        "sts.amazonaws.com"
      ]
    }

    condition {
      test     = "StringEquals"
      variable = "token.actions.githubusercontent.com:sub"

      values = [
        local.github_oidc_subject
      ]
    }
  }
}

resource "aws_iam_role" "github_actions" {
  name               = "github-actions-terraform-role"
  assume_role_policy = data.aws_iam_policy_document.github_assume_role.json
}
```

Tags come from the provider's `default_tags`, so no resource sets `tags` itself.

## 9. Understanding the Subject (`sub`) Claim

The `sub` claim identifies the source of the GitHub Actions OIDC token.

The subject format used in this project is:

```text
repo:OWNER@OWNER_ID/REPOSITORY@REPOSITORY_ID:ref:refs/heads/BRANCH
```

For example, the format contains:

```text
repo:Shinn0x@OWNER_ID/aws-terraform-ansible-deployment-automation@REPOSITORY_ID:ref:refs/heads/main
```

The actual owner and repository IDs must be used in the Terraform variables.

To print the exact subject this configuration trusts:

```bash
terraform output github_oidc_subject
```

### Why include the IDs?

Previously, the default subject format used repository and owner names only.

GitHub's immutable subject claim format includes the owner ID and repository ID. These IDs remain stable when the owner or repository is renamed, helping prevent a different repository from matching a reused name.

The trust policy in this project matches both the names and IDs, as well as the branch. A rename will require updating the name in Terraform even though the numeric ID remains unchanged.

GitHub uses this format by default for repositories created after July 15, 2026, and for repositories renamed or transferred after that date. This repository was created after that date. Older repositories keep the name-only format (`repo:OWNER/REPO:ref:refs/heads/BRANCH`) unless they opt in. If you reuse this project with an older repository, check which format its tokens use, otherwise the trust policy will not match.

GitHub's immutable subject claim format is documented in the [GitHub OIDC reference](https://docs.github.com/en/actions/reference/security/oidc).

## 10. IAM Permissions Policy

The trust policy controls who can assume the role.

The permissions policy controls what the role can do after it is assumed.

For the initial setup, the GitHub Actions role is granted access to the Terraform state bucket.

`github-actions-policy.json`

The file is a Terraform template. Terraform fills in `${state_bucket_name}` from the `state_bucket_name` variable, so the bucket name is set in one place only.

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "AllowIdentityCheck",
      "Effect": "Allow",
      "Action": [
        "sts:GetCallerIdentity"
      ],
      "Resource": "*"
    },
    {
      "Sid": "TerraformStateBucketAccess",
      "Effect": "Allow",
      "Action": [
        "s3:ListBucket",
        "s3:GetBucketVersioning"
      ],
      "Resource": "arn:aws:s3:::${state_bucket_name}"
    },
    {
      "Sid": "TerraformStateObjectAccess",
      "Effect": "Allow",
      "Action": [
        "s3:GetObject",
        "s3:PutObject",
        "s3:DeleteObject"
      ],
      "Resource": "arn:aws:s3:::${state_bucket_name}/*"
    }
  ]
}
```

`AllowIdentityCheck` lets a workflow run `aws sts get-caller-identity` to confirm which role it is using.

Attach the policy in `main.tf`:

```hcl
resource "aws_iam_policy" "github_actions" {
  name        = "github-actions-terraform-policy"
  description = "Permissions for GitHub Actions Terraform state access"

  policy = templatefile("${path.module}/github-actions-policy.json", {
    state_bucket_name = var.state_bucket_name
  })
}

resource "aws_iam_role_policy_attachment" "github_actions" {
  role       = aws_iam_role.github_actions.name
  policy_arn = aws_iam_policy.github_actions.arn
}
```

This policy currently grants state bucket access only. Additional permissions for provisioning AWS infrastructure will be added in a later stage.

## 11. Terraform Outputs

`outputs.tf`

```hcl
output "aws_account_id" {
  description = "AWS account ID"
  value       = data.aws_caller_identity.current.account_id
}

output "github_oidc_provider_arn" {
  description = "GitHub OIDC provider ARN"
  value       = aws_iam_openid_connect_provider.github.arn
}

output "github_actions_role_arn" {
  description = "IAM role ARN for GitHub Actions"
  value       = aws_iam_role.github_actions.arn
}

output "github_oidc_subject" {
  description = "OIDC sub claim the role trusts. Compare it with the sub of a workflow that gets AccessDenied."
  value       = local.github_oidc_subject
}
```

## 12. Initialize and Apply

From the OIDC bootstrap directory:

```bash
terraform init
terraform validate
terraform plan
```

Review the plan carefully.

If the existing OIDC provider has been imported and the plan is correct:

```bash
terraform apply
```

Retrieve the role ARN:

```bash
terraform output github_actions_role_arn
```

The role ARN is used by the GitHub Actions workflow.

## 13. Verify the IAM Role

Check the role:

```bash
aws iam get-role \
  --role-name github-actions-terraform-role
```

Check the attached policy:

```bash
aws iam list-attached-role-policies \
  --role-name github-actions-terraform-role
```

## 14. GitHub Actions OIDC Test

The IAM role was tested from a GitHub Actions workflow on a temporary test branch, `test-oidc-allowed`.

For the test, the trust policy temporarily allowed that branch in addition to `main`.

The workflow successfully assumed the AWS IAM role using OIDC and obtained temporary AWS credentials.

After successful verification, the test branch was removed from the trust policy and the branch was deleted.

The role's trust policy now allows only the `main` branch of this repository.

## 15. Security Notes

- Do not store long-lived AWS access keys in GitHub Secrets.
- Restrict the OIDC trust policy to the intended repository and branch.
- Include GitHub owner and repository IDs in the subject condition.
- Do not use a wildcard subject unless there is a specific security reason.
- Grant only the permissions required by Terraform.
- Keep Terraform state private and protected.
- Review Terraform plans before applying changes to IAM resources.
- The trust policy only matches workflows running on `main`. Jobs that use a GitHub `environment:`, or that are triggered by `pull_request`, send a different `sub` claim and will be denied. Add those subjects to the trust policy if a workflow needs them.
- This bootstrap uses local Terraform state (`terraform.tfstate`), which is git-ignored. Back it up. If it is lost, the resources must be imported again.

## Completion Checklist

- [x] Existing GitHub OIDC provider checked
- [x] Existing provider imported if necessary
- [x] GitHub Actions IAM role configured
- [x] Trust policy restricted to repository, IDs, and branch
- [x] State access policy attached
- [x] IAM role verified
- [x] GitHub Actions OIDC role tested successfully
- [x] Temporary test branch deleted
- [ ] Configure Terraform remote state
- [ ] Add infrastructure provisioning permissions

## Next Stage

Configure Terraform remote state using the S3 bucket created in Section 01.

After the backend is configured, migrate the OIDC bootstrap state from local storage to S3 and continue with infrastructure provisioning.
