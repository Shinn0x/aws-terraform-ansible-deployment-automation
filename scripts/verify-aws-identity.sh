#!/usr/bin/env bash
# Check the credentials are the expected role in the expected account
# Usage: EXPECTED_ACCOUNT_ID=123456789012 ./scripts/verify-aws-identity.sh
set -euo pipefail

expected_account="${EXPECTED_ACCOUNT_ID:-}"
expected_role="${EXPECTED_ROLE:-github-actions-terraform-role}"

if [[ -z "$expected_account" ]]; then
  echo "::error::The AWS_ACCOUNT_ID repository secret is not set."
  exit 1
fi

read -r account arn < <(aws sts get-caller-identity --query '[Account, Arn]' --output text)

if [[ "$account" != "$expected_account" ]]; then
  echo "::error::The credentials are for a different AWS account than the AWS_ACCOUNT_ID secret."
  exit 1
fi

case "$arn" in
  *":assumed-role/${expected_role}/"*)
    echo "OIDC role assumed in the expected account." ;;
  *)
    echo "::error::Expected ${expected_role}, got a different identity."
    exit 1 ;;
esac
