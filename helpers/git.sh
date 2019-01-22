#!/bin/bash

function git_commit_all() {
  if [ "$#" -lt 2 ]; then
    echo "Usage: commit <repository_directory> <commit_message>"
    return
  fi

  local repository_dir=$1
  local commit_message=$2

  pushd ${repository_dir}
    if [[ "$(git status --porcelain)" = "" ]]; then
      echo "No changes to commit"
    else
      git config user.email "${GIT_USER_EMAIL}"
      git config user.name "${GIT_USER_NAME}"

      git add --all .
      git commit -m "${commit_message}"
    fi
  popd
}