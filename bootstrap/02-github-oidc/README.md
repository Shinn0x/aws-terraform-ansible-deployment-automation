# 02 — GitHub Actions OIDC

Lets GitHub Actions log in to AWS with short-lived credentials, so no AWS access keys are stored in GitHub.

Terraform creates:

- GitHub's OIDC identity provider in IAM
- the `github-actions-terraform-role` IAM role
- a trust policy that allows only the `main` branch of this repository
- two permissions policies: `github-actions-policy.json` (Terraform) and `github-actions-ansible-policy.json` (Ansible)

This folder uses **local state**. `terraform.tfstate` is git-ignored and holds the account ID, so keep a backup and never commit it.

## Usage

```bash
# Load the account and GitHub IDs
set -a && source .env && set +a

cd bootstrap/02-github-oidc

# Check whether the OIDC provider already exists in the account
./check-github-oidc.sh

terraform init
terraform plan
terraform apply
```

If the provider already exists but isn't in the state, import it before `apply`:

```bash
ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)
terraform import aws_iam_openid_connect_provider.github \
  "arn:aws:iam::${ACCOUNT_ID}:oidc-provider/token.actions.githubusercontent.com"
```

## Repository Secrets

The workflow reads these from GitHub secrets:

```bash
set -a && source .env && set +a

gh secret set AWS_ROLE_ARN --body "$(terraform -chdir=bootstrap/02-github-oidc output -raw github_actions_role_arn)"
gh secret set AWS_ACCOUNT_ID --body "$TF_VAR_aws_account_id"
```

## Trust Policy

The role trusts one OIDC subject, in GitHub's immutable format:

```text
repo:OWNER@OWNER_ID/REPO@REPO_ID:ref:refs/heads/main
```

The numeric IDs don't change when the owner or repository is renamed, so another repository that reuses the name can't assume the role. GitHub uses this format for repositories created after July 15, 2026. Older repositories send `repo:OWNER/REPO:ref:refs/heads/BRANCH` unless they opt in.

Pull requests and other branches send a different subject, so they can't assume the role.

```bash
terraform output github_oidc_subject
```

## Permissions

The JSON files are templates. Terraform fills in the state bucket, region and account ID, so the account ID is never committed.

`github-actions-policy.json` (Terraform):

| Statement | Allows |
|---|---|
| `AllowIdentityCheck` | `sts:GetCallerIdentity` |
| `TerraformStateBucketAccess`, `TerraformStateObjectAccess` | Read and write the state bucket, including the `.tflock` files |
| `VpcRead`, `Ec2Read` | `ec2:Describe*`, limited to the region (these calls can't be scoped to a resource) |
| `VpcManage` | VPC, subnet, internet gateway, route table and routes |
| `SecurityGroupManage` | The security group and its rules |
| `InstanceManage` | Launch, change and terminate the instance |
| `ElasticIpManage` | The Elastic IP |
| `AmiParameterRead` | Only the Amazon Linux 2023 AMI parameter |
| `InstanceRoleManage`, `InstanceRoleSsmPolicyOnly` | The web server role and instance profile, with only `AmazonSSMManagedInstanceCore` attached |
| `InstanceRolePass` | `iam:PassRole` for the web server role, only to EC2 |
| `Route53Read`, `Route53RecordManage` | Read the zone, and change only the `agex` and `agex-dev` A records |

`github-actions-ansible-policy.json` (Ansible). It is a separate policy because the first one is near the 6,144-character IAM limit.

| Statement | Allows |
|---|---|
| `AnsibleBucketManage`, `AnsibleBucketObjects` | The `*-ansible-ssm` buckets and their files |
| `SsmSessionProjectInstances`, `SsmSessionDocument` | `ssm:StartSession` on instances tagged with this project, with the default shell document |
| `SsmOwnSessions` | End or resume only sessions the role started |

Both policies pass IAM Access Analyzer `ValidatePolicy` with no findings.

If you rename the website records in `infrastructure/environments/*/variables.tf`, update `Route53RecordManage` too.

## Changing the Policies

CI doesn't apply this folder. After editing a policy, apply it from your machine:

```bash
set -a && source .env && set +a
cd bootstrap/02-github-oidc
terraform plan    # check that only the policies change
terraform apply
```
