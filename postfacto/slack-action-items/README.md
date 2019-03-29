# slack-action-items
This task creates a Slack attachment with unfinished Postfacto action items.
The attachment can be used with the slack-notification Concourse resource as shown below.

## Example

### Configuration

```yaml
resource_types:
- name: slack-notification
  type: docker-image
  source:
    repository: cfcommunity/slack-notification-resource
    tag: latest

resources:
- name: weekday-mornings
  type: time
  source:
    start: 8:00 AM
    stop: 9:00 AM
    location: America/Denver
    days: [Monday, Tuesday, Wednesday, Thursday, Friday]

- name: slack-alert
  type: slack-notification
  source:
    url: ((action-items-slack-webhook-url))

- name: concourse-tasks
  type: git
  source:
    uri: https://github.com/pivotal-cf/concourse-tasks
    branch: master

jobs:
# Allows triggering the task without waiting for a weekday morning.
- name: trigger-weekday-mornings
  plan:
    - put: weekday-mornings

- name: weekday-morning-action-item-reminder
  plan:
  - aggregate:
    - get: concourse-tasks
    - get: weekday-mornings
      trigger: true

  - task: create-action-item-reminder
    file: concourse-tasks/postfacto/slack-action-items/task.yml
    params:
      POSTFACTO_RETRO_URL: "https://retros.cfapps.io/retros/my-retro"
      # `POSTFACTO_API_URL` and `POSTFACTO_JWT_TOKEN` can be found by loading your retro
      # with the Network developer console open. The JWT token is the text after `Bearer`
      # in the `Authentication` header.
      POSTFACTO_API_URL: "https://retros-iad-api.cfapps.io/retros/my-retro"
      POSTFACTO_JWT_TOKEN: ((postfacto-jwt-token))

  - put: slack-alert
    params:
      attachments_file: alert/attachments
      username: ((action-items-slack-username))
```
