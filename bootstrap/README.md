# Bootstrap

One-time setup that the rest of the project needs before it can run. Both steps run from your machine, once per AWS account.

| Step | Folder | Tool | Creates |
|---|---|---|---|
| 01 | [`01-state-bucket/`](01-state-bucket/README.md) | AWS CLI | S3 bucket for Terraform state |
| 02 | [`02-github-oidc/`](02-github-oidc/README.md) | Terraform, local state | GitHub OIDC provider, IAM role and policies for GitHub Actions |

Why these are separate:

- **State bucket:** Terraform can't store state in a bucket that doesn't exist yet, so the bucket is made with the AWS CLI.
- **OIDC role:** GitHub Actions can't log in to AWS until the role exists, so it is applied locally.

Run them in order: 01, then 02.
