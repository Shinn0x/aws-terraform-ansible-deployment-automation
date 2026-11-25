
#!/usr/bin/env bash
set -euo pipefail

ROOT="$(git rev-parse --show-toplevel)"
cd "$ROOT"

if [[ ! -d "$ROOT/.git" ]]; then
    echo "Error: Run this script from the Git repository root."
    exit 1
fi

echo "Creating project structure..."

# Section 01: S3 state bucket bootstrap
mkdir -p bootstrap/01-state-bucket

# Section 02: GitHub OIDC bootstrap
mkdir -p bootstrap/02-github-oidc

# Section 03: Terraform infrastructure
mkdir -p infrastructure/modules/vpc
mkdir -p infrastructure/modules/ec2
mkdir -p infrastructure/modules/iam
mkdir -p infrastructure/modules/security-group
mkdir -p infrastructure/environments/dev

# Section 04: Ansible configuration
mkdir -p configuration/inventories
mkdir -p configuration/playbooks
mkdir -p configuration/roles/webserver/tasks
mkdir -p configuration/roles/webserver/handlers
mkdir -p configuration/roles/webserver/templates
mkdir -p configuration/roles/webserver/defaults

# Static website
mkdir -p application/website/css
mkdir -p application/website/js
mkdir -p application/website/assets

# Shared scripts and documentation
mkdir -p scripts
mkdir -p docs/decisions

# GitHub Actions
mkdir -p .github/workflows

# Section 01 files
touch bootstrap/01-state-bucket/create-state-bucket.sh
touch bootstrap/01-state-bucket/README.md

# Section 02 files
touch bootstrap/02-github-oidc/main.tf
touch bootstrap/02-github-oidc/variables.tf
touch bootstrap/02-github-oidc/outputs.tf
touch bootstrap/02-github-oidc/providers.tf
touch bootstrap/02-github-oidc/terraform.tfvars.example
touch bootstrap/02-github-oidc/README.md

# Terraform infrastructure files
touch infrastructure/modules/vpc/main.tf
touch infrastructure/modules/vpc/variables.tf
touch infrastructure/modules/vpc/outputs.tf

touch infrastructure/modules/ec2/main.tf
touch infrastructure/modules/ec2/variables.tf
touch infrastructure/modules/ec2/outputs.tf

touch infrastructure/modules/iam/main.tf
touch infrastructure/modules/iam/variables.tf
touch infrastructure/modules/iam/outputs.tf

touch infrastructure/modules/security-group/main.tf
touch infrastructure/modules/security-group/variables.tf
touch infrastructure/modules/security-group/outputs.tf

touch infrastructure/environments/dev/main.tf
touch infrastructure/environments/dev/variables.tf
touch infrastructure/environments/dev/outputs.tf
touch infrastructure/environments/dev/providers.tf
touch infrastructure/environments/dev/backend.tf
touch infrastructure/environments/dev/terraform.tfvars.example

# Ansible files
touch configuration/ansible.cfg
touch configuration/inventories/aws_ec2.yml
touch configuration/playbooks/deploy-website.yml

touch configuration/roles/webserver/tasks/main.yml
touch configuration/roles/webserver/handlers/main.yml
touch configuration/roles/webserver/defaults/main.yml

# Website files
touch application/website/index.html
touch application/website/css/style.css
touch application/website/js/main.js

# Shared scripts
touch scripts/validate.sh
touch scripts/health-check.sh

# GitHub Actions workflows
touch .github/workflows/terraform.yml
touch .github/workflows/deploy.yml
touch .github/workflows/reusable-terraform-plan.yml
touch .github/workflows/reusable-ansible-deploy.yml

# Documentation
touch docs/architecture.md

# Root files
touch .gitignore
touch README.md

echo "Project structure created successfully!"
echo "Repository root: $ROOT"

