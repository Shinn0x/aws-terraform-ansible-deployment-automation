# 01 — Terraform State Bucket

Creates the S3 bucket that stores Terraform state for the dev and prod environments.

## Files

| File | Purpose |
|---|---|
| `create-state-bucket.sh` | Creates the bucket if needed and applies all settings |
| `encryption.json` | Default SSE-S3 (AES256) encryption |
| `public-access-block.json` | Blocks all public access |
| `ownership-controls.json` | BucketOwnerEnforced (ACLs disabled) |
| `lifecycle.json` | Cleanup rules for old versions, delete markers and incomplete uploads |

## Bucket Settings

| Setting | Value |
|---|---|
| Name | `shinn-terraform-state-foundation` |
| Region | `ap-southeast-1` |
| Versioning | Enabled |
| Encryption | SSE-S3 |
| Public access | Blocked |
| Object ownership | BucketOwnerEnforced |
| Old versions | Deleted 90 days after they are replaced. The 5 newest are always kept. |
| Incomplete uploads | Aborted after 7 days |
| Expired delete markers | Removed |

The current state file is never expired.

## Usage

You need the AWS CLI with credentials that can create and configure S3 buckets.

```bash
./bootstrap/01-state-bucket/create-state-bucket.sh
```

- Safe to re-run. If you already own the bucket, it skips creation and applies the settings again.
- Stops before changing anything if the name belongs to another account.
- Bucket names are global. To reuse this project, change `BUCKET_NAME` at the top of the script, and the same name in `bootstrap/02-github-oidc/variables.tf`, `infrastructure/environments/*/backend.tf` and `.github/workflows/_terraform.yaml`.

## Check

```bash
aws s3api get-bucket-versioning --bucket shinn-terraform-state-foundation
aws s3api get-bucket-lifecycle-configuration --bucket shinn-terraform-state-foundation
```
