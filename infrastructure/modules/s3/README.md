# S3 Module

Creates the bucket Ansible uses to copy files to the web server over AWS Systems Manager.

The Ansible `amazon.aws.aws_ssm` connection uploads each file to this bucket, then tells the instance to download it with `curl` from a presigned URL. The instance needs no S3 permissions of its own. The files are deleted at the end of each Ansible run.

| Setting | Value |
|---|---|
| Public access | Blocked |
| Encryption | SSE-S3 (`AES256`) |
| HTTPS | Required. The bucket policy denies requests without TLS. |
| Versioning | Off, so deleted files don't stay in old versions |
| Lifecycle | Files left behind (for example by a stopped run) are deleted after 1 day |
| `force_destroy` | On, so `terraform destroy` works even if files are left |

## Usage

```hcl
module "ansible_bucket" {
  source = "../../modules/s3"

  name = "${local.name_prefix}-ansible-ssm"
}
```

## Inputs

| Name | Description |
|---|---|
| `name` | Bucket name. Must be globally unique. |

## Outputs

| Name | Description |
|---|---|
| `bucket_name` | Name of the bucket, for `ansible_aws_ssm_bucket_name` |
| `bucket_arn` | ARN of the bucket |
