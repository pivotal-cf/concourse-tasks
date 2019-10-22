#!/usr/bin/env bash
set -eo pipefail
if [[ "$DEBUG" == "true" ]]; then
  set -x
fi

root_dir=$(cd $(dirname $BASH_SOURCE)/../../.. && pwd -P)
source ${root_dir}/concourse-tasks/helpers/environment-targeting.sh
target-bosh

release_name=$1
release_version=$(bosh releases --column "Version" --column "Name" | grep ${release_name} | awk '{print $2}' | sed 's/\*//g' | head -n 1)
deployment_name="compilation-${release_name}-${release_version}-${STEMCELL_OS}"

function cleanup() {
  bosh --non-interactive \
  -d ${deployment_name} \
  delete-deployment
}

trap cleanup EXIT

bosh deploy --non-interactive -d compilation-${release_name}-${release_version} <(cat <<EOF
name: ${deployment_name}
releases:
- name: ${release_name}
  version: "${release_version}"
stemcells:
- alias: default
  os: ${STEMCELL_OS}
  version: "${STEMCELL_VERSION}"
instance_groups: []
update:
  canaries: 1
  max_in_flight: 1
  canary_watch_time: 1000-90000
  update_watch_time: 1000-90000
EOF
)

bosh \
  -d ${deployment_name} \
  export-release \
  ${release_name}/${release_version} \
  "${STEMCELL_OS}/${STEMCELL_VERSION}" \
  --dir=${root_dir}/exported-releases
