# Workflows

`deploy.yaml` is the entry point. It decides when to run and calls one reusable workflow per stage.

| File | Runs |
|---|---|
| `deploy.yaml` | Triggers, then validate → terraform → ansible |
| `_validate.yaml` | `terraform fmt -check`, `terraform validate` for each root, `ansible-lint`. No AWS access. |
| `_terraform.yaml` | `terraform plan` and `apply` for one environment, and outputs the website URL |
| `_ansible.yaml` | The playbook over SSM, then `scripts/health-check.sh` |

Files that start with `_` are only called by `deploy.yaml`.

## When It Runs

It runs when files change under `infrastructure/`, `bootstrap/02-github-oidc/`, `configuration/`, `application/`, `scripts/` or `.github/workflows/`. Changes to `.md` files don't start it.

| Event | Validate | Terraform and Ansible |
|---|---|---|
| Pull request to `main` | Yes | No |
| Push to `main`, including a merged PR | Yes | Yes, dev |
| Manual run on `main` | Yes | Yes, the environment you pick |
| Manual run on another branch | Yes | No |

The IAM role trusts only `main`. Pull requests and other branches can't log in to AWS.

Deploy prod:

```bash
gh workflow run deploy.yaml --ref main -f environment=prod
gh run watch
```

**Merging to `main` deploys dev.** Run `terraform plan` locally before merging infrastructure changes.

## Jobs

- **Terraform:** logs in with OIDC, checks the identity with `scripts/verify-aws-identity.sh`, then runs `plan -out=tfplan` and `apply tfplan` in `infrastructure/environments/<env>`.
- **Ansible:** logs in with the same role, installs Python 3.13, the pinned packages from `configuration/requirements.txt` and Session Manager plugin `1.2.896.0`, runs `deploy-website.yml`, then the health check.
- Runs for the same environment wait in a queue. They never run at the same time.
- If Ansible fails, Terraform has already finished. Fix the problem and re-run only the failed job.

## Secrets

| Secret | Value |
|---|---|
| `AWS_ROLE_ARN` | `terraform -chdir=bootstrap/02-github-oidc output -raw github_actions_role_arn` |
| `AWS_ACCOUNT_ID` | Same as `TF_VAR_aws_account_id` in `.env` |

The account ID is masked in the logs.
