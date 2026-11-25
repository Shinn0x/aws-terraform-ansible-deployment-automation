#!/usr/bin/env bash
set -euo pipefail

# Get the AWS account ID
ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)

# Build the GitHub OIDC provider ARN
OIDC_ARN="arn:aws:iam::${ACCOUNT_ID}:oidc-provider/token.actions.githubusercontent.com"

# Check whether the provider exists
if check_output=$(aws iam get-open-id-connect-provider \
    --open-id-connect-provider-arn "$OIDC_ARN" 2>&1); then

    echo "GitHub OIDC provider already exists."
    echo "$OIDC_ARN"

elif grep -q "NoSuchEntity" <<<"$check_output"; then
    echo "GitHub OIDC provider does not exist."

else
    # AccessDenied, throttling, network errors, etc. are not "missing"
    echo "Error: could not check the GitHub OIDC provider:" >&2
    echo "$check_output" >&2
    exit 1
fi
