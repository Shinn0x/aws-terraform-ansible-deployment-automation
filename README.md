# AWS Terraform Ansible Deployment Automation

A reusable AWS infrastructure provisioning and application deployment project using Terraform, Ansible, GitHub Actions, and OpenID Connect (OIDC).

This project demonstrates how to automate AWS infrastructure, server configuration, and static website deployment using Infrastructure as Code and CI/CD.

The objective is to build a reusable deployment foundation that can be adapted for future AWS projects.

## Project Objectives

- Provision AWS infrastructure using Terraform
- Store Terraform state remotely in Amazon S3
- Authenticate GitHub Actions to AWS using OIDC
- Configure EC2 instances using Ansible
- Automate infrastructure and application deployment
- Implement automated deployment verification
- Build reusable Terraform modules, Ansible roles, and GitHub Actions workflows
- Avoid manual AWS Console configuration after the initial bootstrap

## Architecture Overview

The project is divided into five sections:

| Section | Description |
|---|---|
| 01 | AWS S3 remote Terraform state bootstrap |
| 02 | GitHub Actions OIDC authentication |
| 03 | AWS infrastructure provisioning with Terraform |
| 04 | EC2 configuration and website deployment with Ansible |
| 05 | Automated deployment verification |

## Technology Stack

| Technology | Purpose |
|---|---|
| AWS | Cloud infrastructure |
| Amazon S3 | Remote Terraform state |
| AWS IAM | Identity and access management |
| AWS STS | Temporary credentials |
| Terraform | Infrastructure as Code |
| Ansible | Configuration management |
| GitHub Actions | CI/CD automation |
| AWS CLI | Initial bootstrap and AWS operations |
| Boto3 | Optional AWS automation |
| Amazon VPC | Network infrastructure |
| Amazon EC2 | Static website hosting |
| AWS Systems Manager | Secure instance management |

## Repository Structure

```text
aws-terraform-ansible-deployment-automation/
├── bootstrap/
│   ├── 01-state-bucket/
│   └── 02-github-oidc/
├── infrastructure/
│   ├── modules/
│   └── environments/
├── configuration/
│   ├── inventories/
│   ├── playbooks/
│   └── roles/
├── application/
│   └── website/
├── scripts/
│   └── create-structure.sh
├── .github/
│   └── workflows/
├── docs/
├── .gitignore
└── README.md
```

# Section 01 — AWS S3 Remote State Bootstrap

## Objective

Create an Amazon S3 bucket to store Terraform state files.

The bucket is created using AWS CLI as the initial bootstrap step.

## Why Remote State?

Terraform state records the infrastructure managed by Terraform.

Remote state allows the project to:

- Keep state outside the source repository
- Support Terraform execution from GitHub Actions
- Share state between authorized deployment environments
- Recover previous state versions through S3 versioning

## Implementation

Directory:

`bootstrap/01-state-bucket/`

The bootstrap script will automate:

- S3 bucket creation
- Bucket versioning
- Server-side encryption
- Block Public Access
- Bucket ownership controls
- Bucket configuration validation

## Security

The state bucket must remain private.

Terraform state may contain sensitive information, so access must be restricted using IAM permissions.

S3 versioning will be enabled to support recovery from accidental state changes.

## Completion Criteria

- S3 bucket created successfully
- Versioning enabled
- Encryption configured
- Public access blocked
- Bucket configuration validated

# Section 02 — GitHub Actions OIDC Authentication

## Objective

Allow GitHub Actions to authenticate to AWS without storing permanent AWS access keys in GitHub Secrets.

## Authentication Flow

1. GitHub Actions requests an OIDC token.
2. AWS STS validates the token using the GitHub identity provider.
3. AWS grants temporary credentials by assuming the IAM role.
4. GitHub Actions uses the temporary credentials to access authorized AWS resources.

## Implementation

Directory:

`bootstrap/02-github-oidc/`

Terraform will manage:

- GitHub OpenID Connect provider
- IAM role
- IAM trust policy
- Repository and branch restrictions
- IAM permissions for deployment workflows
- Terraform outputs containing the role ARN

## Security

The IAM trust policy will restrict access to the intended GitHub repository and branch.

The IAM role will follow least privilege and receive only the permissions required by deployment workflows.

Permanent AWS access keys will not be stored in GitHub.

## Completion Criteria

- GitHub OIDC provider configured
- IAM role created
- Trust policy restricted to the intended repository
- Role ARN available through Terraform output
- GitHub Actions successfully assumes the role
- Temporary AWS credentials verified

# Section 03 — AWS Infrastructure Provisioning

Status: Planned

Terraform will provision the infrastructure required to host the static website.

Expected resources:

- VPC
- Subnets
- Internet Gateway
- Route tables
- Security groups
- EC2 instance
- EC2 IAM role
- Systems Manager access

Infrastructure will be organized into reusable Terraform modules and environment configurations.

# Section 04 — Configuration Management and Website Deployment

Status: Planned

Ansible will configure the EC2 instance and deploy the static website.

Expected tasks:

- Install and configure a web server
- Deploy website source files
- Configure file permissions
- Manage web server configuration
- Restart services when configuration changes
- Validate web server configuration

Ansible roles and playbooks will be designed for reuse in future projects.

# Section 05 — Automated Verification

Status: Planned

The deployment pipeline will verify that the website is available after deployment.

Expected checks:

- EC2 instance readiness
- Web server service status
- HTTP health check
- Website response validation
- Deployment success reporting

# CI/CD Strategy

GitHub Actions will orchestrate the deployment process.

Planned workflows:

- Terraform formatting and validation
- Terraform plan
- Terraform apply
- Ansible configuration and deployment
- Website health verification

GitHub Actions will authenticate to AWS using OIDC and temporary credentials.

# Reusability

This repository is intended to serve as a reusable deployment foundation for future AWS projects.

Reusable components will include:

- Terraform infrastructure modules
- GitHub Actions reusable workflows
- Ansible roles
- Bootstrap scripts
- Deployment and validation scripts

Project-specific configuration will be separated from reusable automation logic.

# Security Practices

- Use OIDC instead of long-lived AWS access keys
- Apply IAM least privilege
- Restrict GitHub OIDC trust to approved repositories and branches
- Keep Terraform state private
- Enable S3 state versioning
- Avoid committing credentials and sensitive state files
- Use secure network access for EC2 administration

# Project Status

| Section | Status |
|---|---|
| 01 — S3 State Bootstrap | In progress |
| 02 — GitHub OIDC | Planned |
| 03 — Terraform Infrastructure | Planned |
| 04 — Ansible Deployment | Planned |
| 05 — Automated Verification | Planned |

# Learning Outcomes

This project demonstrates practical experience with:

- AWS infrastructure design
- Infrastructure as Code
- Terraform state management
- IAM and OIDC authentication
- CI/CD automation
- Linux configuration management
- AWS networking
- Secure cloud deployment practices

# License

This project is licensed under the MIT License.
