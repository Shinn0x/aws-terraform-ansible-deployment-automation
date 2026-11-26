# Get the current AWS Account ID
data "aws_caller_identity" "current" {

}

# Register GitHub as an OIDC identity provider in AWS
resource "aws_iam_openid_connect_provider" "github" {
  url = "https://token.actions.githubusercontent.com"

  client_id_list = [
    "sts.amazonaws.com"
  ]
}

# GitHub's immutable subject format:
# repo:OWNER@OWNER_ID/REPO@REPO_ID:ref:refs/heads/BRANCH
locals {
  github_oidc_subject = "repo:${var.github_owner}@${var.github_owner_id}/${var.github_repo}@${var.github_repo_id}:ref:refs/heads/${var.github_branch}"
}

# Define which GitHub workflow identity can assume the role
data "aws_iam_policy_document" "github_assume_role" {
  statement {
    effect = "Allow"

    actions = [
      "sts:AssumeRoleWithWebIdentity"
    ]

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

# Create the IAM role for GitHub Actions
resource "aws_iam_role" "github_actions" {
  name               = "github-actions-terraform-role"
  assume_role_policy = data.aws_iam_policy_document.github_assume_role.json
}

# Create the permissions policy from the JSON file
resource "aws_iam_policy" "github_actions" {
  name = "github-actions-terraform-policy"
  # Changing the description would force Terraform to replace the policy
  description = "Permissions for GitHub Actions Terraform state access"

  # Account ID comes from .env, so it is never committed
  policy = templatefile("${path.module}/github-actions-policy.json", {
    state_bucket_name = var.state_bucket_name
    aws_region        = var.aws_region
    account_id        = var.aws_account_id
  })
}

# Attach the policy to the GitHub Actions role
resource "aws_iam_role_policy_attachment" "github_actions" {
  role       = aws_iam_role.github_actions.name
  policy_arn = aws_iam_policy.github_actions.arn
}

# Ansible bucket and SSM sessions. Separate because the first policy is near the size limit
resource "aws_iam_policy" "github_actions_ansible" {
  name        = "github-actions-ansible-policy"
  description = "Permissions for GitHub Actions to run Ansible over SSM"

  policy = templatefile("${path.module}/github-actions-ansible-policy.json", {
    aws_region = var.aws_region
    account_id = var.aws_account_id
  })
}

resource "aws_iam_role_policy_attachment" "github_actions_ansible" {
  role       = aws_iam_role.github_actions.name
  policy_arn = aws_iam_policy.github_actions_ansible.arn
}
