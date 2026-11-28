# AWS Terraform Ansible Deployment Automation

Provisions AWS infrastructure with Terraform, configures the server and deploys a website with Ansible, and checks it is healthy. GitHub Actions runs everything, logging in to AWS with OIDC instead of access keys.

| Environment | Website |
|---|---|
| dev | https://agex-dev.localhostshinn.xyz |
| prod | https://agex.localhostshinn.xyz |

## How It Works

```mermaid
flowchart LR
    push[Push to main] --> gha[GitHub Actions]
    gha -->|OIDC| sts[AWS STS]
    sts -->|temporary credentials| gha
    gha -->|plan / apply| tf[Terraform]
    tf <-->|state| state[(S3 state bucket)]
    tf -->|creates| infra[VPC, EC2, Elastic IP, IAM, S3, Route 53]
    gha -->|playbook over SSM| ans[Ansible]
    ans -->|nginx, website, HTTPS| ec2[EC2 web server]
    gha -->|health check| ec2
```

1. A push to `main` starts the workflow.
2. GitHub Actions gets temporary AWS credentials through OIDC.
3. Terraform creates or updates the environment.
4. Ansible connects over AWS Systems Manager (no SSH), installs nginx, copies the website and sets up HTTPS with Let's Encrypt.
5. A health check confirms the site responds over HTTPS.

## Stages

| Stage | Folder | Tool | Docs |
|---|---|---|---|
| AWS setup | `ci-policies/` | Run once from my machine | [README](ci-policies/README.md) |
| Infrastructure | `infrastructure/` | Terraform, S3 backend | [README](infrastructure/README.md) |
| Configuration and deployment | `configuration/`, `application/` | Ansible | [README](configuration/README.md), [website](application/README.md) |
| Verification | `scripts/` | Bash | [README](scripts/README.md) |
| CI/CD | `.github/workflows/` | GitHub Actions | [README](.github/workflows/README.md) |

## Project Structure

```text
.
├── ci-policies/              IAM policies for the CI role
├── infrastructure/
│   ├── modules/              vpc, security-group, iam, ec2, s3, route53
│   └── environments/         dev, prod (Terraform runs here)
├── configuration/            Ansible inventory, playbook, webserver role
├── application/website/      static website
├── scripts/                  health check, identity check
├── .github/workflows/        deploy.yaml and the stage workflows
└── .env.example              template for local values
```

## Getting Started

You need the AWS CLI, Terraform 1.10 or newer, Python 3.13 or newer, and the GitHub CLI.

1. **Local values.** Copy the template and fill it in. The comments in the file show how to look up each value.
   ```bash
   cp .env.example .env
   set -a && source .env && set +a
   ```
2. **AWS setup.** Once per account, create the state bucket, the GitHub OIDC provider and the CI role with its policies. See [`ci-policies/`](ci-policies/README.md#set-up). Then set the `AWS_ROLE_ARN` and `AWS_ACCOUNT_ID` repository secrets.
3. **Deploy.** Merge to `main`, which deploys dev. Deploy prod with a manual run:
   ```bash
   gh workflow run deploy.yaml --ref main -f environment=prod
   ```
4. **Destroy.** Run the workflow manually with `action` set to `destroy` and the environment name in `confirm`. See [Destroy](.github/workflows/README.md#destroy).

## Local Values (`.env`)

The AWS account ID is never committed. Terraform reads it from `TF_VAR_aws_account_id` in `.env`, which is git-ignored. CI gets it from the `AWS_ACCOUNT_ID` repository secret.

| Variable | Used by | Purpose |
|---|---|---|
| `TF_VAR_aws_account_id` | `infrastructure/environments/*` | Terraform refuses to run against any other account |

## Security

- No AWS access keys in GitHub. CI uses short-lived OIDC credentials.
- The IAM role trusts only the `main` branch of this repository, matched by immutable owner and repository IDs.
- CI permissions cover only the actions this project needs, in one account and region. Where AWS allows it, they are limited to this project's IAM roles, Ansible buckets, Route 53 records, SSM sessions and `environments/` state files.
- No SSH. Port 22 is closed, and Ansible uses AWS Systems Manager.
- The website is served over HTTPS only. HTTP redirects to HTTPS.
- The instance requires IMDSv2 and has an encrypted disk.
- The state bucket is private, encrypted and versioned.
- `allowed_account_ids` stops Terraform if the credentials belong to a different account.
- `main` is protected by a ruleset. Changes go through pull requests.

## Project Status

- [x] State bucket, GitHub OIDC role, trust policy and CI permissions
- [x] dev and prod environments in Terraform, dev deployed by CI
- [x] Ansible deploys the website over SSM, with HTTPS from Let's Encrypt
- [x] Health check after every deploy
- [x] CI split into validate, terraform and ansible workflows
- [x] Manual destroy with a typed confirmation
- [x] AWS setup moved out of this repository. The CI policies stay in `ci-policies/`.
- [ ] prod deployed
