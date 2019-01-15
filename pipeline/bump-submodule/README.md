# bump-submodule
This task bumps the specified submodule and commits the change to the release repo.

## Example

### Configuration

```yaml
resources:
- name: concourse-tasks
  type: git
  source:
    uri: ((concourse-tasks-uri))

- name: my-release
  type: git
  source:
    uri: ((my-release-uri))
    branch: develop
    private_key: ((private-key))

- name: my-submodule
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
    - get: release-repo
      resource: my-release
    - get: submodule-repo
      resource: my-submodule
    - get: concourse-tasks
  - task: bump-my-submodule
    file: concourse-tasks/pipeline/bump-submodule/task.yml
    params:
      GIT_USER_NAME: ((git_username))
      GIT_USER_EMAIL: ((git_email))
      SUBMODULE_DIR: my-release/src/github.com/pivotal/my-submodule
  - put: release
    resource: my-release
    params:
      repository: output-repo
```