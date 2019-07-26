#!/usr/bin/env bash
# source this file to target your interactive shell

# Optional env overrides:
# OM_PATH to save somewhere other than /tmp

source $(dirname $BASH_SOURCE)/../../helpers/toolsmiths.sh

if [ $# -ne 1 ]; then
    echo "Usage: $0 <Pooled Env Name>"
    return 1
fi

export ENV_NAME=$1
echo "Targeting ${ENV_NAME}."

if ! smith read -e ${ENV_NAME} > /tmp/claimed-metadata; then
  return 1;
fi

export ENV_METADATA="/tmp/${ENV_NAME}-metadata"
mv /tmp/claimed-metadata ${ENV_METADATA}

echo "Bosh Login"
bosh-login ${ENV_METADATA}

PRODUCTS=$(om available-products --format=json | jq '.[].name')

if [[ $PRODUCTS == *"cf"* ]]; then
  echo "CF Login"
  export CF_ADMIN_PASSWORD=$(om credentials -p cf -c .uaa.admin_credentials -f password)
  export CF_ADMIN_USER=$(om credentials -p cf -c .uaa.admin_credentials -f identity)
  
  cf api https://api.$(jq .sys_domain -r ${ENV_METADATA}) --skip-ssl-validation
  cf auth ${CF_ADMIN_USER} ${CF_ADMIN_PASSWORD}
fi

if [[ $PRODUCTS == *"pivotal-container-service"* ]]; then
  echo "PKS Login"
  export PKS_API_USER=$( jq < $ENV_METADATA .pks_api.uaa_admin_user -r)
  export PKS_API_PASSWORD=$( jq < $ENV_METADATA .pks_api.uaa_admin_password -r)
  export PKS_API_URL=$( jq < $ENV_METADATA .pks_api.url -r)

  pks login -a "${PKS_API_URL}" -u "${PKS_API_USER}" -p "${PKS_API_PASSWORD}" --skip-ssl-validation
fi
  
jq .ops_manager.password -r ${ENV_METADATA} | pbcopy
echo "OpsMan password copied, log in at: $(jq .ops_manager.url -r ${ENV_METADATA})"
