# Workflows

`deploy.yaml` is the entry point. It decides when to run and calls one reusable workflow per stage.

| File | Runs |
|---|---|
| `deploy.yaml` | Triggers, then validate → terraform → ansible |
| `_validate.yaml` | `terraform fmt -check`, `terraform validate` for each environment, a JSON check of `ci-policies/`, `ansible-lint`. No AWS access. |
| `_terraform.yaml` | `terraform plan` and `apply`, or a destroy, for one environment. Outputs the website URL. |
| `_ansible.yaml` | The playbook over SSM, then `scripts/health-check.sh` |

Files that start with `_` are only called by `deploy.yaml`.

## When It Runs

It runs when files change under `infrastructure/`, `ci-policies/`, `configuration/`, `application/`, `scripts/` or `.github/workflows/`. Changes to `.md` files don't start it.

| Event | Validate | Terraform and Ansible |
|---|---|---|
| Pull request to `main` | Yes | No |
| Push to `main`, including a merged PR | Yes | Yes, dev |
| Manual run on `main` | Yes | Yes, the environment and action you pick |
| Manual run on another branch | Yes | No |

The IAM role trusts only `main`. Pull requests and other branches can't log in to AWS.

Deploy prod:

```bash
gh workflow run deploy.yaml --ref main -f environment=prod
gh run watch
```

**Merging to `main` deploys dev.** Run `terraform plan` locally before merging infrastructure changes.

## Destroy

Run the workflow manually with `action` set to `destroy`, and type the environment name in `confirm`. In GitHub: **Actions → Deploy → Run workflow**.

```bash
gh workflow run deploy.yaml --ref main -f environment=dev -f action=destroy -f confirm=dev
gh run watch
```

- Terraform runs `plan -destroy`, then applies that plan. Ansible is skipped.
- If `confirm` doesn't match the environment, the run stops before logging in to AWS.
- The state bucket, the OIDC role and the Route 53 hosted zone are not managed here, so they stay.
- A push to `main` that changes deployed files creates dev again. To keep it down, disable the workflow after the destroy: `gh workflow disable deploy.yaml`. A disabled workflow can't run manually either.

## Jobs

- **Terraform:** logs in with OIDC, checks the identity with `scripts/verify-aws-identity.sh`, then runs `plan -out=tfplan` (`plan -destroy` for a destroy) and `apply tfplan` in `infrastructure/environments/<env>`.
- **Ansible:** logs in with the same role, installs Python 3.13, the pinned packages from `configuration/requirements.txt` and Session Manager plugin `1.2.896.0`, runs `deploy-website.yml`, then the health check.
- Runs for the same environment never run at the same time. A new run waits until the current one finishes.
- If Ansible fails, Terraform has already finished. Fix the problem and re-run only the failed job.

## Secrets

| Secret | Value |
|---|---|
| `AWS_ROLE_ARN` | ARN of `github-actions-terraform-role`. See [`ci-policies/`](../../ci-policies/README.md). |
| `AWS_ACCOUNT_ID` | Same as `TF_VAR_aws_account_id` in `.env` |

The account ID is masked in the logs.
