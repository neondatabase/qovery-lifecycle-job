
#!/bin/sh

# exit on error
set -e

qovery_env_name="$QOVERY_ENVIRONMENT_NAME"

# Remove square brackets
sanitized_qovery_env_name="${qovery_env_name//[\[\]]/}"

# Replace spaces with underscores
sanitized_qovery_env_name="${sanitized_qovery_env_name// /_}"

# Remove special characters
sanitized_qovery_env_name="${sanitized_qovery_env_name//-/}"
sanitized_qovery_env_name="${sanitized_qovery_env_name//T/}"
sanitized_qovery_env_name="${sanitized_qovery_env_name//:/}"

# Replace " and . with _
sanitized_qovery_env_name="${sanitized_qovery_env_name//\"/_}"
sanitized_qovery_env_name="${sanitized_qovery_env_name//./_}"

echo "Sanitized environment name: $sanitized_qovery_env_name"

# Get branch ID by name
branch_id=$(curl --silent \
  "https://console.neon.tech/api/v2/projects/$NEON_PROJECT_ID/branches" \
  --header "Accept: application/json" \
  --header "Content-Type: application/json" \
  --header "Authorization: Bearer $NEON_API_KEY" \
  | jq -r .branches \
  | jq -c '.[] | select(.name | contains("'$sanitized_qovery_env_name'")) .id' \
  | jq -r \
  ) \

OUTPUT=`curl -X 'DELETE' \
  "https://console.neon.tech/api/v2/projects/$NEON_PROJECT_ID/branches/$branch_id" \
  -H 'accept: application/json' \
  -H "Authorization: Bearer $NEON_API_KEY"`

# print output and format using jq
echo $OUTPUT | jq

echo "Branch deleted successfully"
