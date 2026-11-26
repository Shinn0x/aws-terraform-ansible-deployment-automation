# Scripts

| Script | Used by | Purpose |
|---|---|---|
| `health-check.sh` | The Ansible workflow, after each deploy | Checks the website is up |
| `verify-aws-identity.sh` | The Terraform and Ansible workflows | Checks the credentials are `github-actions-terraform-role` in the expected account |
| `create-structure.sh` | Manual | Creates the project folders and empty files. Existing files are not changed. |

## health-check.sh

```bash
./scripts/health-check.sh https://agex-dev.localhostshinn.xyz
```

It fails unless:

1. `https://<domain>` returns 200 with a valid certificate. It retries while nginx reloads.
2. The page is the Agex site, not the nginx welcome page.
3. `http://<domain>` redirects to HTTPS with a 301.

## verify-aws-identity.sh

```bash
EXPECTED_ACCOUNT_ID=123456789012 ./scripts/verify-aws-identity.sh
```

It fails if the account ID is not set, the credentials belong to a different account, or the identity is not the expected role. `EXPECTED_ROLE` changes the role name.
