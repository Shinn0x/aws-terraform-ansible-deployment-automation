# CI Policies

IAM policies for `github-actions-terraform-role`, the role GitHub Actions assumes with OIDC.

| File | Used by |
|---|---|
| `github-actions-policy.json` | Terraform |
| `github-actions-ansible-policy.json` | Ansible |

CI doesn't create or change this role. The role, its trust policy, the GitHub OIDC provider and the Terraform state bucket are set up from my machine with my `aws-bootstrap` scripts. They also give the role a state policy, and attach the two policies in this folder. These two live here because they name this project's resources, so a new resource and its permission change in the same pull request.

## Set Up

To run this project in another AWS account, create these once before the first deploy:

1. An S3 bucket for Terraform state, with versioning and encryption. Its name is in `infrastructure/environments/*/backend.tf` and in the bucket check in `.github/workflows/_terraform.yaml`.
2. The GitHub OIDC provider: `https://token.actions.githubusercontent.com`, audience `sts.amazonaws.com`.
3. The `github-actions-terraform-role` role with the [trust policy](#trust-policy), the [state policy](#permissions) and the two policies in this folder.
4. The `AWS_ROLE_ARN` and `AWS_ACCOUNT_ID` repository secrets. See [Secrets](../.github/workflows/README.md#secrets).

The JSON files are templates. Fill in `${aws_region}` and `${account_id}` before attaching them, so the account ID is never committed. `$${aws:userid}` in the Ansible policy is the template's way of writing the IAM variable `${aws:userid}`.

## Trust Policy

The role trusts one GitHub OIDC subject (`sub`), in GitHub's immutable format, for the `sts.amazonaws.com` audience only:

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Federated": "arn:aws:iam::ACCOUNT_ID:oidc-provider/token.actions.githubusercontent.com"
      },
      "Action": "sts:AssumeRoleWithWebIdentity",
      "Condition": {
        "StringEquals": {
          "token.actions.githubusercontent.com:aud": "sts.amazonaws.com",
          "token.actions.githubusercontent.com:sub": "repo:OWNER@OWNER_ID/REPO@REPO_ID:ref:refs/heads/main"
        }
      }
    }
  ]
}
```

The numeric IDs don't change when the owner or repository is renamed, so another repository that reuses the name can't assume the role. GitHub uses this format for repositories created after July 15, 2026. Older repositories send `repo:OWNER/REPO:ref:refs/heads/BRANCH` unless they opt in.

Pull requests and other branches send a different subject, so they can't assume the role.

## Permissions

The role has three policies.

**State policy**, from the setup. It is the same for every project, so it isn't in this folder. In `aws-bootstrap` the folder is set with `STATE_PREFIX`, which is `environments` for this project.

| Statement | Allows |
|---|---|
| `AllowIdentityCheck` | `sts:GetCallerIdentity` |
| `TerraformStateBucketAccess` | List the state bucket, and read its versioning setting |
| `TerraformStateObjectAccess` | Read, write and delete only the files under `environments/`, including the `.tflock` files |

Listing shows the names of every file in the bucket, but the role's own state, kept under `bootstrap/`, can't be read or changed. The state keys in `infrastructure/environments/*/backend.tf` must start with `environments/`.

**`github-actions-policy.json`** (Terraform):

| Statement | Allows |
|---|---|
| `VpcRead`, `Ec2Read` | `ec2:Describe*`, limited to the region (these calls can't be scoped to a resource) |
| `VpcManage` | VPC, subnet, internet gateway, route table and routes |
| `SecurityGroupManage` | The security group and its rules |
| `InstanceManage` | Launch, change and terminate the instance |
| `ElasticIpManage` | The Elastic IP |
| `AmiParameterRead` | Only the Amazon Linux 2023 AMI parameter |
| `InstanceRoleManage`, `InstanceRoleSsmPolicyOnly` | The web server role and instance profile, with only `AmazonSSMManagedInstanceCore` attached |
| `InstanceRolePass` | `iam:PassRole` for the web server role, only to EC2 |
| `Route53Read`, `Route53RecordManage` | Read the zone, and change only the `agex` and `agex-dev` A records |

**`github-actions-ansible-policy.json`** (Ansible). It is a separate policy because the Terraform one is near the 6,144-character IAM limit.

| Statement | Allows |
|---|---|
| `AnsibleBucketManage`, `AnsibleBucketObjects` | This project's `*-ansible-ssm` buckets and their files |
| `SsmSessionProjectInstances`, `SsmSessionDocument` | `ssm:StartSession` on instances tagged with this project, with the default shell document |
| `SsmOwnSessions` | End or resume only sessions the role started |

All three policies pass IAM Access Analyzer `ValidatePolicy` with no findings.

If you rename the website records in `infrastructure/environments/*/variables.tf`, update `Route53RecordManage` too.

## Changing the Policies

CI can't change its own permissions, so apply policy changes from your machine:

1. Edit the JSON on your branch, in the same pull request as the change that needs it.
2. Apply it before merging. Merging to `main` deploys dev, and that deploy fails if the new permission isn't there yet. With `aws-bootstrap`, run `./bootstrap.sh` while the branch is checked out: it shows the plan and asks before changing anything.
3. Merge.
