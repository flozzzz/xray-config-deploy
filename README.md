# xray-deploy

Automated deployment of [Xray-core](https://github.com/XTLS/Xray-core) configuration to multiple servers via GitHub Actions.

## How it works

On every push to `main`, GitHub Actions connects via SSH to each server and applies the new config. If xray fails to start after deployment, it automatically rolls back to the backup.

## Structure

config/
  config.server1.json.template  — config template for server 1
  config.server2.json.template  — config template for server 2
scripts/
  deploy.sh                     — deploy script with rollback
.github/workflows/
  deploy.yml                    — CI/CD pipeline

## Setup

Add the following GitHub Secrets:

| Secret | Description |
|---|---|
| SSH_HOST1 / SSH_HOST2 | Server IP addresses |
| SSH_USER1 / SSH_USER2 | SSH username |
| SSH_PRIVATE_KEY1 / SSH_PRIVATE_KEY2 | Private SSH key |
| SERVER1_UUID1..3 | Client UUIDs for server 1 |
| SERVER2_UUID1..4 | Client UUIDs for server 2 |
| SERVER1/2_PRIVATE_KEY | Reality privateKey |
| SERVER1_SHORTIDS1/2 | ShortIDs for server 1 |
| SERVER2_SHORTIDS1 | ShortID for server 2 |
