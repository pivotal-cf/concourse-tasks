# cut-final

This task cuts a final bosh release, commits to Git, and creates a GitHub release.

## Example

### Configuration

```yaml
resources:
- name: my-release
  type: git
  source:
    uri: ((my-release-uri))
    branch: develop
    private_key: ((private-key))

- name: my-github-release
  type: github-release
  source:
    owner: pivotal-cf
    repository: my-release
    access_token: ((github-access-token))

jobs:
- name: create-release-patch
  serial: true
  plan:
  - aggregate:
    - get: release
      resource: my-release
    - get: concourse-tasks
  - task: cut-final
    file: concourse-tasks/release/cut-final/task.yml
    params:
      GIT_USER_NAME: ((git_username))
      GIT_USER_EMAIL: ((git_email))
      BLOBSTORE_ACCESS_KEY_ID: ((s3-access-key))
      BLOBSTORE_SECRET_ACCESS_KEY: ((s3-access-secret))
      GITHUB_RELEASE_NAME: My Release
      RELEASE_NAME: my-release
      FETCH_DEPENDENCIES_SCRIPT: ./scripts/fetch-dependencies.sh --vendor-only=true
      BUMP: PATCH
  - put: release
    resource: my-release
    params:
      repository: output-repo
  - put: my-github-release
    params:
      name: output-metadata/name
      tag: output-metadata/tag
      commitish: output-metadata/commit
      globs:
      - output-release/*
```