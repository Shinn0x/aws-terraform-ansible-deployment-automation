# AWS Terraform Ansible Deployment Automation

A reusable AWS infrastructure provisioning and application deployment project using Terraform, Ansible, GitHub Actions, and AWS IAM OIDC.

## Project Overview

This project demonstrates how to automate the provisioning of AWS infrastructure and deployment of a website without relying on manual AWS Console setup.

The goal is to build a repeatable workflow that can provision infrastructure, configure servers, deploy an application, and verify that the deployment is healthy.

## Architecture

The project will be developed in the following stages:

1. Bootstrap an S3 bucket for Terraform remote state.
2. Configure GitHub Actions authentication using AWS IAM OIDC.
3. Provision AWS infrastructure using Terraform.
4. Configure the EC2 instance and deploy a website using Ansible.
5. Run automated health checks to verify the deployment.

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
│   │   └── create-state-bucket.sh
│   └── 02-github-oidc/
├── infrastructure/
├── configuration/
├── application/
├── scripts/
├── docs/
├── .github/
│   └── workflows/
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
- Noncurrent object versions: Expire after 90 days
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

Update the bucket name and region in the script:

```bash
BUCKET_NAME="your-unique-terraform-state-bucket"
AWS_REGION="ap-southeast-1"
```

Run the script:

```bash
chmod +x bootstrap/01-state-bucket/create-state-bucket.sh

./bootstrap/01-state-bucket/create-state-bucket.sh
```

Verify the bucket versioning:

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

## Section 02 — GitHub Actions OIDC

This stage will configure AWS IAM OIDC authentication for GitHub Actions.

Terraform will create:

- GitHub's OIDC identity provider in AWS IAM
- An IAM role for GitHub Actions
- A trust policy restricted to the project repository and branch

GitHub Actions will use temporary credentials instead of long-lived AWS access keys.

The initial OIDC bootstrap will use local Terraform state. The state can later be migrated to the S3 backend.

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
- Restrict GitHub OIDC trust to the intended repository and branch.
- Block public access to the Terraform state bucket.
- Enable S3 versioning to support state recovery.
- Do not commit AWS credentials, Terraform state files, or sensitive variables.
- Keep the current Terraform state object protected from lifecycle expiration.

## Project Status

- [x] Repository initialized
- [x] S3 state bucket bootstrap script created
- [ ] Run and verify S3 bucket bootstrap
- [ ] Configure GitHub OIDC using Terraform
- [ ] Configure Terraform remote state
- [ ] Provision AWS infrastructure
- [ ] Automate deployment with Ansible
- [ ] Add deployment health checks

## Learning Objectives

This project demonstrates practical experience with AWS infrastructure automation, Terraform state management, IAM OIDC authentication, CI/CD pipelines, configuration management, and automated deployment verification.

