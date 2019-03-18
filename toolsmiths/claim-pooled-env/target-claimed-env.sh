#!/usr/bin/env bash
set -eu

# source this file to target your interactive shell

# Optional env overrides:
# CONCOURSE_TARGET if other than 'denver'
# OM_PATH to save somewhere other than /tmp

install-om() {
  if ! which om >/dev/null; then
      OM_PATH=${OM_PATH:-$(mktemp -d)}
      curl -sL https://github.com/pivotal-cf/om/releases/latest/download/om-$(uname | tr '[:upper:]' '[:lower:]') >$OM_PATH/om
      chmod +x $OM_PATH/om
      export PATH="$PATH:$OM_PATH"
  fi
}

target-om() {
  ENV_METADATA=$1
  export OM_USERNAME=$(jq .ops_manager.username -r ${ENV_METADATA})
  export OM_PASSWORD=$(jq .ops_manager.password -r ${ENV_METADATA})
  export OM_TARGET=$(jq .ops_manager.url -r ${ENV_METADATA})
  export OM_SKIP_SSL_VALIDATION=true # TODO: we have the certs in ENV_METADATA, can we provide them to om?
}

bosh-login() {
  ENV_METADATA=$1
  local ops_manager_dns=$(jq .ops_manager_dns -r ${ENV_METADATA})
  local env_name=$(jq .name -r ${ENV_METADATA})

  install-om
  target-om ${ENV_METADATA}

  eval "$(om bosh-env)"

  jq .ops_manager_private_key -r ${ENV_METADATA} > /tmp/${env_name}.key
  chmod 600 /tmp/${env_name}.key

  export BOSH_ALL_PROXY="ssh+socks5://ubuntu@${ops_manager_dns}:22?private-key=/tmp/${env_name}.key"
  export CREDHUB_PROXY="ssh+socks5://ubuntu@${ops_manager_dns}:22?private-key=/tmp/${env_name}.key"
  export SYS_DOMAIN=$(jq .sys_domain -r ${ENV_METADATA})

  credhub login
}

get-cf-deployment-name() {
  bosh deployments --json | jq -r '.Tables[].Rows | map(select(.release_s | contains("garden-runc"))) | .[0].name'
}

if [ $# -ne 1 ]; then
    echo "Usage: $0 <concourse-job>"
    return
fi

fly -t ${CONCOURSE_TARGET:-denver} login -b
fly -t ${CONCOURSE_TARGET:-denver} w -j ${1} | tail -1  | sed 's/succeeded$//' >/tmp/claimed-metadata
export ENV_NAME=$(jq .name -r /tmp/claimed-metadata)
echo "Targeting ${ENV_NAME}."

export ENV_METADATA="/tmp/${ENV_NAME}-metadata"
mv /tmp/claimed-metadata ${ENV_METADATA}

bosh-login ${ENV_METADATA}

export CF_ADMIN_PASSWORD=$(om credentials -p cf -c .uaa.admin_credentials -f password)
export CF_ADMIN_USER=$(om credentials -p cf -c .uaa.admin_credentials -f identity)
cf login -a https://api.$(jq .sys_domain -r ${ENV_METADATA}) -u ${CF_ADMIN_USER} -p ${CF_ADMIN_PASSWORD} --skip-ssl-validation

jq .ops_manager.password -r ${ENV_METADATA} | pbcopy
echo "OpsMan password copied, log in at: $(jq .ops_manager.url -r ${ENV_METADATA})"
