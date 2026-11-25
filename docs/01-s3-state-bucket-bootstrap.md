# S3 Terraform State Bucket Bootstrap

`bootstrap/01-state-bucket/` contains a Bash script, and the JSON configuration files it applies, to create and configure an Amazon S3 bucket for storing Terraform state.

The bucket is created using AWS CLI and configured with security controls and lifecycle cleanup.

## Purpose

Terraform state keeps track of the infrastructure managed by Terraform.

Storing state in an S3 bucket allows Terraform state to be shared between environments and CI/CD workflows.

This bootstrap script prepares the S3 bucket before Terraform uses it as a remote backend.

## Files

| File | Purpose |
|---|---|
| `create-state-bucket.sh` | Creates the bucket if needed and applies all settings |
| `encryption.json` | Default SSE-S3 (AES256) encryption |
| `public-access-block.json` | Blocks all public access |
| `ownership-controls.json` | BucketOwnerEnforced (ACLs disabled) |
| `lifecycle.json` | Cleanup rules for old versions, delete markers and incomplete uploads |

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

The bucket name and region are set at the top of `create-state-bucket.sh`:

```bash
BUCKET_NAME="shinn-terraform-state-foundation"
AWS_REGION="ap-southeast-1"
```

Change `BUCKET_NAME` if you reuse this project in another AWS account.

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
| Noncurrent version expiration | 90 days (5 newest noncurrent versions kept) |
| Incomplete multipart upload cleanup | 7 days |
| Expired delete markers | Removed |
| Current Terraform state | Preserved |

## Lifecycle Policy

The lifecycle policy automatically manages old and incomplete data.

### Noncurrent version expiration

Older (noncurrent) object versions are permanently deleted 90 days after they are replaced. The 5 most recent noncurrent versions of each object are always kept, even when they are older than 90 days.

This controls storage costs while keeping previous Terraform state versions available for recovery.

### Incomplete multipart upload cleanup

Multipart uploads that have not been completed are aborted after 7 days.

This removes storage used by unfinished uploads.

### Expired delete markers

Expired delete markers are removed when applicable.

The lifecycle policy does not expire the current Terraform state object.

## Verification

The commands below use shell variables, so set them in your terminal first:

```bash
BUCKET_NAME="shinn-terraform-state-foundation"
AWS_REGION="ap-southeast-1"
```

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

Check object ownership:

```bash
aws s3api get-bucket-ownership-controls \
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

- The script is safe to re-run. If the bucket already exists and you own it, creation is skipped and all settings are re-applied.
- If the name is taken by another AWS account, or you lack access, the script prints the error and stops before changing anything.
- The script checks that all four JSON files exist before calling AWS, and it can be run from any directory.
- The bucket name must be globally unique.
- The current Terraform state must not be automatically expired.
- Do not commit AWS credentials or Terraform state files to GitHub.
- Keep the bucket private and restrict access using IAM.

## Next Step

After verifying the bucket, configure Terraform to use it as a remote backend for infrastructure state.

