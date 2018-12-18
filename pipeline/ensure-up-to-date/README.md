# ensure-up-to-date

This task ensures that pipelines match what is committed in the repo. It does
not update any configuration, it just fails if fly detects changes.

## Example

The task requires a bit of special configuration to work when credentials are
normally sourced from LastPass. Your `FLY_SCRIPT` should take credentials as
environment variables in order to work in Concourse.

Here's an example `FLY_SCRIPT`:
```bash
fly -t concourse set-pipeline --config ${PROJECT_ROOT}/pipelines/validation.yml
```

It's recommended to write a wrapper for this script that initializes variables
from your credential store for interactive use.

### Configuration

```yaml
resources:
- name: deployments
  type: git
  source:
    uri: ((deployments-repo))
    branch: master
    private_key: ((private-key))

- name: concourse-tasks
  type: git
  source:
    uri: git@github.com:pivotal-cf/concourse-tasks
    branch: master
    private_key: ((private-key))

- name: before_workday
  type: time
  source:
    interval: 24h
    location: America/Denver
    days: [Monday, Tuesday, Wednesday, Thursday, Friday]
    start: 6:00 AM
    stop: 7:00 AM

jobs:
- name: ensure-pipelines-are-flown
  plan:
  - aggregate:
    - get: deployments
      trigger: true
    - get: concourse-tasks
    - get: before_workday
      trigger: true
  - task: validation-pipeline
    file: concourse-tasks/pipeline/ensure-up-to-date/task.yml
    params:
      USER: ((user))
      PASSWORD: ((password))
      TEAM_NAME: ((team))
      CREDS: ((pipelinecreds))
      FLY_SCRIPT: scripts/fly-validation-pipeline.sh
      FLY_TARGET: concourse
      CONCOURSE_URL: https://concourse.com
```
