# Configuration

Ansible installs nginx on the web server, copies the website from `application/website/` to `/var/www/agex`, and serves it over HTTPS with a Let's Encrypt certificate.

```text
configuration/
├── ansible.cfg
├── requirements.txt          Python packages (ansible-core, ansible-lint, boto3)
├── requirements.yml          Ansible collections (amazon.aws)
├── .ansible-lint
├── inventories/
│   ├── aws_ec2.yml           finds the instances in AWS
│   └── group_vars/           settings per environment
├── playbooks/
│   └── deploy-website.yml
└── roles/
    └── webserver/            nginx, website, certificate
```

## How It Connects

- **No SSH.** Ansible connects through AWS Systems Manager (`amazon.aws.aws_ssm`). Port 22 is closed and there are no SSH keys.
- **Files go through S3.** Ansible uploads each file to the environment's `*-ansible-ssm` bucket, and the instance downloads it from a presigned URL. The instance needs no S3 permissions.
- **Inventory.** `aws_ec2.yml` finds running instances by their `Project` tag and groups them by `Environment` tag: `env_dev` and `env_prod`.

## Settings

| Variable | Set in | Value |
|---|---|---|
| `ansible_connection`, `ansible_aws_ssm_region` | `group_vars/all.yml` | SSM connection in `ap-southeast-1` |
| `ansible_aws_ssm_bucket_name` | `group_vars/env_<env>.yml` | The environment's Ansible bucket |
| `webserver_server_name` | `group_vars/env_<env>.yml` | `agex-dev.localhostshinn.xyz` or `agex.localhostshinn.xyz` |
| `webserver_root` | `roles/webserver/defaults` | `/var/www/agex` |
| `webserver_acme_root` | `roles/webserver/defaults` | `/var/www/letsencrypt` |

## What the Playbook Does

1. Waits until the instance is reachable over SSM. A new instance takes 1–2 minutes.
2. Installs nginx and certbot.
3. Copies the website and adds the HTTP config. Port 80 only answers the Let's Encrypt check and redirects everything else to HTTPS.
4. Gets the certificate with `certbot --webroot`. It skips this step if the certificate already exists.
5. Adds the HTTPS config and turns on `certbot-renew.timer`, which renews the certificate and reloads nginx.

Running it again changes nothing (`changed=0`).

## Run Locally

You need Python 3.13 or newer, AWS credentials, and the [Session Manager plugin](https://docs.aws.amazon.com/systems-manager/latest/userguide/session-manager-working-with-install-plugin.html).

```bash
cd configuration
python3 -m venv ../.venv && source ../.venv/bin/activate
pip install -r requirements.txt
ansible-galaxy collection install -r requirements.yml

ansible-inventory --graph
ansible-playbook playbooks/deploy-website.yml -e target_env=dev    # or prod
ansible-lint
```

## Let's Encrypt Limit

Let's Encrypt issues about 5 certificates a week for the same domain. A new instance needs a new certificate, so don't recreate an instance many times in one week. To test, add `--staging` to the certbot command in `roles/webserver/tasks/main.yml`. Browsers don't trust staging certificates, so remove it afterwards.
