#!/usr/bin/env bash
set -eo pipefail
if [[ -z ${DEBUG} && "$DEBUG" = true ]]; then
  set -x
fi

root_dir=$(cd $(dirname $BASH_SOURCE)/../../.. && pwd -P)
source ${root_dir}/concourse-tasks/helpers/environment-targeting.sh
target-bosh

release_name=$1
release_version=$(bosh releases --column "Version" --column "Name" | grep ${release_name} | awk '{print $2}' | sed 's/\*//g' | head -n 1)

bosh deploy --non-interactive -d compilation-${release_name}-${release_version} <(cat <<EOF
name: compilation-${release_name}-${release_version}
releases:
- name: ${release_name}
  version: "${release_version}"
stemcells:
- alias: default
  os: ${STEMCELL_OS}
  version: ${STEMCELL_VERSION}
instance_groups: []
update:
  canaries: 1
  max_in_flight: 1
  canary_watch_time: 1000-90000
  update_watch_time: 1000-90000
EOF
)

bosh \
  -d compilation-${release_name}-${release_version} \
  export-release \
  ${release_name}/${release_version} \
  ${STEMCELL_OS}/${STEMCELL_VERSION} \
  --dir=${root_dir}/exported-releases

