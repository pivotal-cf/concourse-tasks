#!/usr/bin/env bash
# source this file to target your interactive shell

# Optional env overrides:
# CONCOURSE_TARGET if other than 'denver'
# OM_PATH to save somewhere other than /tmp

source $(dirname $BASH_SOURCE)/../helpers/claimed-env.sh

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
