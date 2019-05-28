# check-claimed-envs

This task uses the Toolsmiths API to check for claimed pooled environments.

## Example

### Configuration

```yaml
jobs:
- name: check-claimed-envs
  plan:
  - get: concourse-tasks

  - task: ensure-no-claimed-environments
    file: concourse-tasks/toolsmiths/check-claimed-envs/task.yml
    params:
      TOOLSMITHS_API_TOKEN: ((toolsmiths-api-key))
    tags: [ ((toolsmiths-workers-tag)) ]

  - put: slack-alert
    params:
      attachments_file: alert/attachments
      username: ((claimed-envs-slack-username))
      icon_emoji: ((claimed-envs-slack-icon))

resources:
- name: slack-alert
  type: slack-notification
  source:
    url: ((slack-webhook-url))

- name: concourse-tasks
  type: git
  source:
    uri: https://github.com/pivotal-cf/concourse-tasks
    branch: master

resource_types:
- name: slack-notification
  type: docker-image
  source:
    repository: cfcommunity/slack-notification-resource
    tag: latest

```
