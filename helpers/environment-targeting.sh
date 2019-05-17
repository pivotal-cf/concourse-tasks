#!/usr/bin/env bash

function target-bosh() {
  if [[ -d pas-env ]]; then
    #TODO move this
    source $(dirname $BASH_SOURCE)/toolsmiths-env-helpers.sh
    retry 3 bosh-login $PWD/pas-env/metadata
  elif [[ -d bbl-state ]]; then
    pushd "bbl-state/$BBL_STATE_DIR"
      eval "$(bbl print-env)"
    popd
  fi
}