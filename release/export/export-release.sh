#!/usr/bin/env bash
set -eu

root_dir=$($(dirname $BASH_SOURCE)/../../.. && pwd -P)
source $(dirname $BASH_SOURCE)/concourse-tasks/helpers/environment-targeting.sh
target-bosh

release_name=$1
release_version=$(bosh releases --column "Version" --column "Name" | grep ${release_name} | awk '{print $2"/"$1}' | sed 's/\*//g' | head -n 1)

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

