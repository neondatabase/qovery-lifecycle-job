
#!/bin/sh

# exit on error
set -e

# Get branch ID by name
branch_id=$(curl --silent \
  "https://console.neon.tech/api/v2/projects/$NEON_PROJECT_ID/branches" \
  --header "Accept: application/json" \
  --header "Content-Type: application/json" \
  --header "Authorization: Bearer $NEON_API_KEY" \
  | jq -r .branches \
  | jq -c '.[] | select(.name | contains("'$QOVERY_ENVIRONMENT_NAME'")) .id' \
  | jq -r \
  ) \

OUTPUT=`curl -X 'DELETE' \
  "https://console.neon.tech/api/v2/projects/$NEON_PROJECT_ID/branches/$branch_id" \
  -H 'accept: application/json' \
  -H "Authorization: Bearer $NEON_API_KEY"`

# print output and format using jq
echo $OUTPUT | jq

echo "Branch deleted successfully"