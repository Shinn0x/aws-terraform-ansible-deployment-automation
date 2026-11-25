# S3 Terraform State Bucket Bootstrap

This directory contains a Bash script that creates and configures an Amazon S3 bucket for storing Terraform state.

The bucket is created using AWS CLI and configured with security controls and lifecycle cleanup.

## Purpose

Terraform state keeps track of the infrastructure managed by Terraform.

Storing state in an S3 bucket allows Terraform state to be shared between environments and CI/CD workflows.

This bootstrap script prepares the S3 bucket before Terraform uses it as a remote backend.

## Prerequisites

- AWS CLI v2 installed
- AWS CLI configured with valid credentials
- Appropriate IAM permissions to create and configure an S3 bucket
- A globally unique S3 bucket name

Verify your AWS identity:

```bash
aws sts get-caller-identity
```

## Configuration

Open `create-state-bucket.sh` and update the following variables:

```bash
BUCKET_NAME="your-unique-terraform-state-bucket"
AWS_REGION="ap-southeast-1"
```

The bucket is created in the Singapore AWS Region.

S3 bucket names must be globally unique.

## Usage

From the project root, make the script executable:

```bash
chmod +x bootstrap/01-state-bucket/create-state-bucket.sh
```

Run the script:

```bash
./bootstrap/01-state-bucket/create-state-bucket.sh
```

The script creates the bucket and applies the following configuration.

## Bucket Configuration

| Setting | Configuration |
|---|---|
| Region | `ap-southeast-1` |
| Versioning | Enabled |
| Default encryption | SSE-S3 |
| Public access | Blocked |
| Object ownership | BucketOwnerEnforced |
| Noncurrent version expiration | 90 days |
| Incomplete multipart upload cleanup | 7 days |
| Current Terraform state | Preserved |

## Lifecycle Policy

The lifecycle policy automatically manages old and incomplete data.

### Noncurrent version expiration

Older object versions are permanently deleted after 90 days.

This helps control storage costs while retaining previous Terraform state versions for recovery.

### Incomplete multipart upload cleanup

Multipart uploads that have not been completed are aborted after 7 days.

This removes storage used by unfinished uploads.

### Expired delete markers

Expired delete markers are removed when applicable.

The lifecycle policy does not expire the current Terraform state object.

## Verification

Check bucket versioning:

```bash
aws s3api get-bucket-versioning \
  --bucket "$BUCKET_NAME" \
  --region "$AWS_REGION"
```

Check encryption:

```bash
aws s3api get-bucket-encryption \
  --bucket "$BUCKET_NAME" \
  --region "$AWS_REGION"
```

Check public access settings:

```bash
aws s3api get-public-access-block \
  --bucket "$BUCKET_NAME" \
  --region "$AWS_REGION"
```

Check lifecycle configuration:

```bash
aws s3api get-bucket-lifecycle-configuration \
  --bucket "$BUCKET_NAME" \
  --region "$AWS_REGION"
```

## Important Notes

- This script is intended to create a new bucket.
- If the bucket already exists, the creation command will fail and the script will stop.
- The bucket name must be globally unique.
- The current Terraform state must not be automatically expired.
- Do not commit AWS credentials or Terraform state files to GitHub.
- Keep the bucket private and restrict access using IAM.

## Next Step

After verifying the bucket, configure Terraform to use it as a remote backend for infrastructure state.

