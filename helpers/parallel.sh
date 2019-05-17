#!/usr/bin/env bash
set -eo pipefail

function run_tasks_in_parallel() {
  task_type=$1
  echo "Running ${task_type} in Parallel."

  shift
  printf "\n\n"
  if parallel ${_PARALLEL_OPTIONS} bash -c '"set -exo pipefail;"{}' ::: "$@"; then
    echo "Running ${task_type} in Parallel Finished."
    return 0
  else
    echo "Running ${task_type} in Parallel Failed."
    return 1
  fi
}