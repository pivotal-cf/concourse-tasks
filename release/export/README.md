# export

This task exports bosh releases. The releases must be uploaded to the director prior to running this task.

## Example

### Configuration

Example using bbl environment:
```yaml
jobs:
- name: export-releases
  serial: true
  plan:
  - aggregate:
    - get: concourse-tasks
    - get: bbl-state
  - task: export-releases
    file: concourse-tasks/release/export/task.yml
    params:
      BBL_STATE_DIR: path/to/directory/containing/bbl-state.json
      RELEASE_NAMES: |
        my-cool-release-1
        my-cool-release-2
  - task: show-releases
    config:
      platform: linux
      image_resource:
        type: docker-image
        source:
          repository: loggregator/base
      run:
        path: /bin/bash
        args:
        - -c
        - |
          set -exuo pipefail
          ls exported-releases
      inputs:
      - name: exported-releases

resources:
- name: concourse-tasks
  type: git
  source:
    branch: master
    uri: https://github.com/pivotal-cf/concourse-tasks

- name: bbl-state
  type: git
  source:
    branch: master
    uri: https://github.com/pivotal-cf/my-locks-repo
```

Example using poolsmiths environment:
```yaml
jobs:
- name: export-releases
  serial: true
  plan:
  - aggregate:
    - get: concourse-tasks
    - get: pas-env
      resource: 2.3-env
  - task: export-releases
    file: concourse-tasks/release/export/task.yml
    params:
      RELEASE_NAMES: |
        my-cool-release-1
        my-cool-release-2
  - task: show-releases
    config:
      platform: linux
      image_resource:
        type: docker-image
        source:
          repository: loggregator/base
      run:
        path: /bin/bash
        args:
        - -c
        - |
          set -exuo pipefail
          ls exported-releases
      inputs:
      - name: exported-releases

resources:
- name: 2.3-env
  type: pcf-pool
  source:
    api_token: ((toolsmiths-api-key))
    hostname: environments.toolsmiths.cf-app.com
    pool_name: us_2_3
  tags: [ ((toolsmiths-workers-tag)) ]

- name: concourse-tasks
  type: git
  source:
    uri: https://github.com/pivotal-cf/concourse-tasks
    branch: master

resource_types:
- name: pcf-pool
  type: docker-image
  source:
    repository: cftoolsmiths/toolsmiths-envs-resource
```