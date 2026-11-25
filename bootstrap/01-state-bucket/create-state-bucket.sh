#!/usr/bin/env bash
set -euo pipefail

# Set your bucket name and AWS region
BUCKET_NAME="shinn-terraform-state-foundation"
AWS_REGION="ap-southeast-1"

# Bucket config files live next to this script, so it works from any directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ENCRYPTION_FILE="$SCRIPT_DIR/encryption.json"
PUBLIC_ACCESS_BLOCK_FILE="$SCRIPT_DIR/public-access-block.json"
OWNERSHIP_CONTROLS_FILE="$SCRIPT_DIR/ownership-controls.json"
LIFECYCLE_FILE="$SCRIPT_DIR/lifecycle.json"

# Make sure every config file exists before touching AWS
for config_file in "$ENCRYPTION_FILE" "$PUBLIC_ACCESS_BLOCK_FILE" "$OWNERSHIP_CONTROLS_FILE" "$LIFECYCLE_FILE"; do
  if [[ ! -r "$config_file" ]]; then
    echo "Error: config file not found or not readable: $config_file" >&2
    exit 1
  fi
done

# Check AWS credentials
aws sts get-caller-identity >/dev/null

# Create the S3 bucket in Singapore, unless it already exists
if head_output=$(aws s3api head-bucket --bucket "$BUCKET_NAME" --region "$AWS_REGION" 2>&1); then
  echo "Bucket already exists and you own it: $BUCKET_NAME (skipping creation)"
elif grep -q "(404)" <<<"$head_output"; then
  echo "Creating bucket: $BUCKET_NAME"
  aws s3api create-bucket \
    --bucket "$BUCKET_NAME" \
    --region "$AWS_REGION" \
    --create-bucket-configuration LocationConstraint="$AWS_REGION"
else
  # 403 means the name is taken by another account or you lack access
  echo "Error: cannot use bucket '$BUCKET_NAME':" >&2
  echo "$head_output" >&2
  exit 1
fi

# Enable versioning to protect previous state files
aws s3api put-bucket-versioning \
  --bucket "$BUCKET_NAME" \
  --region "$AWS_REGION" \
  --versioning-configuration Status=Enabled

# Enable default S3-managed encryption
aws s3api put-bucket-encryption \
  --bucket "$BUCKET_NAME" \
  --region "$AWS_REGION" \
  --server-side-encryption-configuration "file://$ENCRYPTION_FILE"

# Block all public access
aws s3api put-public-access-block \
  --bucket "$BUCKET_NAME" \
  --region "$AWS_REGION" \
  --public-access-block-configuration "file://$PUBLIC_ACCESS_BLOCK_FILE"

# Enforce bucket ownership and disable ACLs
aws s3api put-bucket-ownership-controls \
  --bucket "$BUCKET_NAME" \
  --region "$AWS_REGION" \
  --ownership-controls "file://$OWNERSHIP_CONTROLS_FILE"

# Configure lifecycle cleanup
aws s3api put-bucket-lifecycle-configuration \
  --bucket "$BUCKET_NAME" \
  --region "$AWS_REGION" \
  --lifecycle-configuration "file://$LIFECYCLE_FILE"

# Display the bucket name when setup is complete
echo "S3 Terraform state bucket ready: $BUCKET_NAME"
