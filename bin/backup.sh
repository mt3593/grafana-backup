#!/bin/bash
set -eo pipefail

MISSING_ENV_VARS=false

has_env() {
  local env_name="$1"
  local value=$(eval "echo \"\$$env_name\"")
  if [ -z "$value" ]; then
    echo "Missing environment variable: $env_name"
    MISSING_ENV_VARS=true
  fi
}

has_env "GIT_NAME"
has_env "GIT_EMAIL"
## The following are used to construct the url
has_env "GIT_REPO_USERNAME"
has_env "GIT_REPO"

has_env "GRAFANA_URL"
has_env "GRAFANA_USERNAME"
has_env "GRAFANA_PASSWORD"
set -u

if [ $MISSING_ENV_VARS = true ]; then
  echo "Failing due to missing environment variables"
  exit 1
fi

## Check we have at least one of the auth methods
TOKEN=false
SSH_PATH="/root/.ssh/id_rsa"
if [ -f "$SSH_PATH" ]; then
  chown root:root /root/.ssh
  touch /root/.ssh/known_hosts
  ssh-keyscan -t rsa github.com >> /root/.ssh/known_hosts
  GIT_URL_WITH_AUTH="git@github.com:${GIT_REPO_USERNAME}/${GIT_REPO}.git"
else
  $(has_env "GIT_TOKEN_USERNAME")
  $(has_env "GIT_TOKEN")
  if [ $MISSING_ENV_VARS = true ]; then
    echo "Missing GIT_TOKEN and GIT_TOKEN_USERNAME or missing ~/.ssh/id_rsa file for auth."
    exit 1
  else
    GIT_URL_WITH_AUTH="https://${GIT_TOKEN_USERNAME}:${GIT_TOKEN}@github.com/${GIT_REPO_USERNAME}/${GIT_REPO}.git"
  fi
fi

echo "Pulling down repo"

git config --global user.name "$GIT_NAME"
git config --global user.email "$GIT_EMAIL"

cd /tmp
git clone "$GIT_URL_WITH_AUTH"
cd "$GIT_REPO"

echo "Setting up wizzy"
## Ensure we don't save the wizzy config
grep -qxF '/conf' .gitignore || echo '/conf' >> .gitignore

wizzy init

wizzy set grafana url "$GRAFANA_URL"
wizzy set grafana username "$GRAFANA_USERNAME"
wizzy set grafana password "$GRAFANA_PASSWORD"


echo "Getting current setup"
wizzy import dashboards
wizzy import datasources

## Now add to git and push back up to the repo
echo "Commiting new setup"
git add .
git commit -m "Backup"
git push origin master
