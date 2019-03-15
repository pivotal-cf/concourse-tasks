# claim-pooled-env

This task uses the `toolsmiths-envs-resource` to display the metadata for a pooled environment.

To use, you'll need to follow the instructions [here](toolsmiths-onboarding) to get your API token and Concourse workers set up.

The accompanying `target-claimed-env.sh` script uses the output of this task to target the BOSH Director and CF API for local debugging. See [the FAQ](toolsmiths-faq) for some helpful tips.

The `pcf-pool` resource type does most of the heavy lifting, so this task just reports the environment details.

## Example

### Configuration

```yaml
resources:
- name: 2.3-env
  type: pcf-pool
  source:
    api_token: ((toolsmiths-api-key))
    hostname: environments.toolsmiths.cf-app.com
    pool_name: us_2_3
  tags: [ ((toolsmiths-workers-tag)) ]

resource_types:
- name: pcf-pool
  type: docker-image
  source:
    repository: cftoolsmiths/toolsmiths-envs-resource

jobs:
- name: claim-2.3-env
  plan:
  - get: before-workday
    trigger: true
  - put: 2.3-env
    params:
      action: claim
    tags: [ ((toolsmiths-workers-tag)) ]
  - task: output-env-details
    file: concourse-tasks/toolsmiths/claim-pooled-env/task.yml
    input_mapping:
      pooled-env: 2.3-env

  - name: unclaim-2.3-env
    plan:
      - get: 2.3-env
        tags: [ ((toolsmiths-workers-tag)) ]
      - put: 2.3-env
        params:
          action: unclaim
          env_file: 2.3-env/metadata
        tags: [ ((toolsmiths-workers-tag)) ]
```

[toolsmiths-onboarding]:  https://docs.google.com/document/d/1afCL7hgFeQ61orx6Z5bP49xauE753n5eSZPuO5bWJeY/edit#heading=h.rzx8m9ypluky
[toolsmiths-faq]:         https://environments.toolsmiths.cf-app.com/faq
