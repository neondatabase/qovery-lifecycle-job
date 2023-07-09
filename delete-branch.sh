
#!/bin/sh

# exit on error
set -e

branch_id=$(curl --silent \
  "https://console.neon.tech/api/v2/projects/'$PROJECT_ID'/branches" \
  --header "Accept: application/json" \
  --header "Content-Type: application/json" \
  --header "Authorization: Bearer '$NEON_API_KEY'" \
  | jq -r .branches \
  | jq -c '.[] | select(.name | contains("'$QOVERY_ENVIRONMENT_NAME'")) .id' \
  | jq -r \
  ) \

OUTPUT=`curl -X 'DELETE' \
  "https://console.neon.tech/api/v2/projects/'$PROJECT_ID'/branches/'$branch_id'" \
  -H 'accept: application/json' \
  -H "Authorization: Bearer '$NEON_API_KEY'"`
echo $OUTPUT

echo "shell script executed successfully with output values - check out your Qovery environment variables :)"