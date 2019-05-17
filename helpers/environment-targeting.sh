#!/usr/bin/env bash

function target-bosh() {
  if [[ -d pas-env ]]; then
    source $(dirname $BASH_SOURCE)/toolsmiths.sh
    retry 3 bosh-login $PWD/pas-env/metadata
  elif [[ -d bbl-state ]]; then
    pushd "bbl-state/$BBL_STATE_DIR"
      eval "$(bbl print-env)"
    popd
  fi
}