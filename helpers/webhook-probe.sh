#!/usr/bin/env bash

if [ $# -ne 2 ]; then
  echo "Usage: $0 slack-user hook-url"
  exit 1
fi

USER=$1
SLACK_WEBHOOK=$2

PAYLOAD=$(mktemp)
cat >> ${PAYLOAD} << EOF
{
  "title": "Webhook probe",
  "title_link": "https://hooks.slack.com/services/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",
  "text": "@${USER} probe posts here."
}
EOF

curl -H "Content-Type: application/json" -d "@${PAYLOAD}" ${SLACK_WEBHOOK}
