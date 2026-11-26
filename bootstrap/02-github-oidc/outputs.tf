# Values printed after apply
output "aws_account_id" {
  description = "AWS account ID"
  value       = data.aws_caller_identity.current.account_id
}

output "github_oidc_provider_arn" {
  description = "GitHub OIDC provider ARN"
  value       = aws_iam_openid_connect_provider.github.arn
}

# Use this value for the AWS_ROLE_ARN repository secret
output "github_actions_role_arn" {
  description = "IAM role ARN for GitHub Actions"
  value       = aws_iam_role.github_actions.arn
}

output "github_oidc_subject" {
  description = "OIDC sub claim the role trusts. Compare it with the sub of a workflow that gets AccessDenied."
  value       = local.github_oidc_subject
}
