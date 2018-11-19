# bump-vendored-golang

This task ensures that your BOSH release is using the latest vendored [golang release](https://github.com/bosh-packages/golang-release).

## Example

### Configuration

```yaml
resources:
- name: golang-release
  type: git
  source:
    uri: git@github.com:bosh-packages/golang-release
    branch: master
    tag_filter: v*
    private_key: ((private-key))

- name: my-release
  type: git
  source:
    uri: ((my-release-uri))
    branch: develop
    private_key: ((private-key))

jobs:
- name: bump-golang-release
  plan:
  - aggregate:
    - get: release
      resource: my-release
    - get: concourse-tasks
      resource: concourse-tasks
    - get: golang-release
      trigger: true
  - task: bump-golang
    file: concourse-tasks/go/bump-vendored-golang/task.yml
    params:
      GIT_USER_NAME: ((git_username))
      GIT_USER_EMAIL: ((git_email))
      BLOBSTORE_ACCESS_KEY_ID: ((s3-access-key))
      BLOBSTORE_SECRET_ACCESS_KEY: ((s3-access-secret))
  - put: my-release
    params:
      repository: output-repo
      rebase: true
```