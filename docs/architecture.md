# Architecture

This document describes how the parts of the project fit together. Parts marked **planned** are not built yet.

## Overview

```mermaid
flowchart LR
    dev[Developer] -->|push to main| repo[GitHub repository]
    repo --> gha[GitHub Actions]
    gha -->|OIDC token| sts[AWS STS]
    sts -->|temporary credentials| gha
    gha -->|terraform plan / apply| tf[Terraform]
    tf <-->|state| s3[(S3 state bucket)]
    tf -->|provisions| infra[VPC, security groups, EC2, IAM]
    gha -->|ansible-playbook| ans[Ansible]
    ans -->|configure and deploy| ec2[EC2 web server]
    gha -->|health check| ec2
```

The authentication path (GitHub Actions → STS), the state bucket and the VPC configuration exist today. The rest of the diagram shows the target design.

## Stages

| Stage | Directory | Tool | Status |
|---|---|---|---|
| 01 State bucket | `bootstrap/01-state-bucket/` | AWS CLI (Bash) | Done |
| 02 GitHub OIDC | `bootstrap/02-github-oidc/` | Terraform, local state | Done |
| 03 Infrastructure | `infrastructure/` | Terraform, S3 backend | In progress: VPC done, EC2, security groups and IAM planned |
| 04 Configuration and deployment | `configuration/`, `application/` | Ansible | Planned |
| 05 Verification | `scripts/` | Bash | Planned |

## Bootstrap Layer

The bootstrap stages solve two chicken-and-egg problems:

- **State bucket:** Terraform cannot store state in a bucket that does not exist yet, so the bucket is created with the AWS CLI instead of Terraform.
- **OIDC role:** GitHub Actions cannot authenticate to AWS until the OIDC provider and role exist, so this stage is applied from a local machine with local Terraform state.

Both stages run once per AWS account and rarely change after that.

## Authentication

GitHub Actions never stores long-lived AWS access keys.

1. The workflow requests an OIDC token from GitHub.
2. It calls `sts:AssumeRoleWithWebIdentity` for `github-actions-terraform-role`.
3. AWS checks the trust policy: the audience must be `sts.amazonaws.com` and the subject must be the `main` branch of this repository.
4. STS returns temporary credentials for the workflow run.

The role can read and write the Terraform state bucket and manage the VPC, subnet, internet gateway and route table in this account and region. Permissions for the rest of stage 03 will be added when that code exists.

## Account-Specific Values

The AWS account ID and the GitHub owner and repository IDs are not committed:

| Where | How |
|---|---|
| Local machine | `TF_VAR_*` variables in the git-ignored `.env` file (template: `.env.example`) |
| GitHub Actions | Repository secrets `AWS_ROLE_ARN` and `AWS_ACCOUNT_ID`, masked in logs |

Both Terraform configurations set `allowed_account_ids`, so they stop with an error if the credentials belong to a different account.

Details: [GitHub Actions OIDC Setup](02-github-actions-oidc.md)

## Terraform State

| Configuration | Backend | Location |
|---|---|---|
| `bootstrap/02-github-oidc/` | Local | `terraform.tfstate` on the machine that ran `apply` (git-ignored) |
| `infrastructure/modules/vpc/` | S3, native lock file | `s3://shinn-terraform-state-foundation/vpc/terraform.tfstate` |

The state bucket has versioning, SSE-S3 encryption, blocked public access and lifecycle cleanup.

Details: [S3 Terraform State Bucket Bootstrap](01-s3-state-bucket-bootstrap.md)

## Infrastructure

`infrastructure/modules/` holds one directory per part of the infrastructure:

- `vpc`: networking, built. A VPC (`10.20.0.0/16`), one public subnet (`10.20.1.0/24`), an internet gateway and a public route table. It is a root configuration with its own S3 backend, and GitHub Actions plans and applies it on `main`.
- `security-group`: network access rules (planned)
- `ec2`: the web server instance (planned)
- `iam`: instance role and permissions (planned)

## Configuration and Deployment (Planned)

- `configuration/inventories/aws_ec2.yml`: an Ansible dynamic inventory that discovers EC2 instances from AWS.
- `configuration/playbooks/deploy-website.yml`: applies the `webserver` role.
- `configuration/roles/webserver/`: installs the web server and deploys the static site in `application/website/`.

AWS Systems Manager will be used where possible, so no SSH keys need to be managed.

## Verification (Planned)

`scripts/health-check.sh` will confirm that the website is reachable and responding correctly after each deployment.
