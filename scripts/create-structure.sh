#!/usr/bin/env bash
# Create the project folders and empty files. Existing files are not changed.
set -euo pipefail

ROOT="$(git rev-parse --show-toplevel 2>/dev/null)" || {
  echo "Error: run this script inside the Git repository." >&2
  exit 1
}
cd "$ROOT"

echo "Creating project structure..."

files=(
  # Root
  README.md
  .gitignore
  .env.example

  # Section 01: S3 state bucket
  bootstrap/README.md
  bootstrap/01-state-bucket/README.md
  bootstrap/01-state-bucket/create-state-bucket.sh
  bootstrap/01-state-bucket/encryption.json
  bootstrap/01-state-bucket/lifecycle.json
  bootstrap/01-state-bucket/ownership-controls.json
  bootstrap/01-state-bucket/public-access-block.json

  # Section 02: GitHub OIDC
  bootstrap/02-github-oidc/README.md
  bootstrap/02-github-oidc/providers.tf
  bootstrap/02-github-oidc/variables.tf
  bootstrap/02-github-oidc/main.tf
  bootstrap/02-github-oidc/outputs.tf
  bootstrap/02-github-oidc/github-actions-policy.json
  bootstrap/02-github-oidc/github-actions-ansible-policy.json
  bootstrap/02-github-oidc/check-github-oidc.sh

  # Section 03: Terraform infrastructure
  infrastructure/README.md
)

for module in vpc security-group iam ec2 s3; do
  files+=(
    "infrastructure/modules/$module/README.md"
    "infrastructure/modules/$module/main.tf"
    "infrastructure/modules/$module/variables.tf"
    "infrastructure/modules/$module/outputs.tf"
  )
done

for env in dev prod; do
  files+=(
    "infrastructure/environments/$env/backend.tf"
    "infrastructure/environments/$env/providers.tf"
    "infrastructure/environments/$env/locals.tf"
    "infrastructure/environments/$env/variables.tf"
    "infrastructure/environments/$env/main.tf"
    "infrastructure/environments/$env/outputs.tf"
  )
done

files+=(
  # Section 04: Ansible configuration
  configuration/README.md
  configuration/ansible.cfg
  configuration/.ansible-lint
  configuration/requirements.txt
  configuration/requirements.yml
  configuration/inventories/aws_ec2.yml
  configuration/inventories/group_vars/all.yml
  configuration/inventories/group_vars/env_dev.yml
  configuration/inventories/group_vars/env_prod.yml
  configuration/playbooks/deploy-website.yml
  configuration/roles/webserver/defaults/main.yml
  configuration/roles/webserver/handlers/main.yml
  configuration/roles/webserver/tasks/main.yml
  configuration/roles/webserver/templates/agex.conf.j2
  configuration/roles/webserver/templates/agex-ssl.conf.j2

  # Section 04: Static website
  application/README.md
  application/website/index.html
  application/website/about.html
  application/website/products.html
  application/website/contact.html
  application/website/privacy.html
  application/website/terms.html
  application/website/on-the-way.html
  application/website/404.html
  application/website/css/style.css
  application/website/js/main.js

  # Section 05: Scripts
  scripts/README.md
  scripts/create-structure.sh
  scripts/health-check.sh
  scripts/verify-aws-identity.sh

  # GitHub Actions
  .github/workflows/README.md
  .github/workflows/deploy.yaml
  .github/workflows/_validate.yaml
  .github/workflows/_terraform.yaml
  .github/workflows/_ansible.yaml
)

mkdir -p application/website/assets

for file in "${files[@]}"; do
  mkdir -p "$(dirname "$file")"
  # touch only creates missing files, it never empties existing ones
  touch "$file"
  if [[ "$file" == *.sh ]]; then
    chmod +x "$file"
  fi
done

echo "Project structure created: ${#files[@]} files"
echo "Repository root: $ROOT"
