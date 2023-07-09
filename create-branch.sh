#!/bin/sh

# exit on error
set -e

branch=$(curl --silent \
  "https://console.neon.tech/api/v2/projects/'$PROJECT_ID'/branches" \
  --header "Accept: application/json" \
  --header "Content-Type: application/json" \
  --header "Authorization: Bearer '$API_KEY'" \
  --data "{
    \"branch\": {
      \"name\": \"'$QOVERY_ENVIRONMENT_NAME'\"
    },
    \"endpoints\": [
      {
        \"type\": \"read_write\"
      }
    ]
  }")

if [[ $branch == *"already exists"* ]]; then

# Get the branch id by its name. We list all branches and filter by name
branch_id=$(curl --silent \
    "https://console.neon.tech/api/v2/projects/'$PROJECT_ID'/branches" \
    --header "Accept: application/json" \
    --header "Content-Type: application/json" \
    --header "Authorization: Bearer '$API_KEY'" \
    | jq -r .branches \
    | jq -c '.[] | select(.name | contains("'$QOVERY_ENVIRONMENT_NAME'")) .id' \
    | jq -r \
    ) \


# Get the list of endpoints for the branch by its id. 
endpoints=$(curl --silent \
    "https://console.neon.tech/api/v2/projects/'$PROJECT_ID'/branches/'$branch_id'/endpoints" \
    --header "Accept: application/json" \
    --header "Content-Type: application/json" \
    --header "Authorization: Bearer '$API_KEY'" \
    ) \

endpoint_id=$(echo $endpoints | jq --raw-output '.endpoints[0].host' | cut -d'.' -f1)
region=$(echo $endpoints | jq --raw-output '.endpoints[0].host' | cut -d'.' -f2)
cloud_provider=$(echo $endpoints | jq --raw-output '.endpoints[0].host' | cut -d'.' -f3)
host=$(echo $endpoints | jq --raw-output '.endpoints[0].host')
branch_id=$(echo $endpoints | jq --raw-output '.endpoints[0].branch_id')

echo '{
  "host": {
    "sensitive": true,
    "value": "'$host'"
  },
  "endpoint_id": {
    "sensitive": true,
    "value": "'$endpoint_id'"
  },
    "branch_id": {
    "sensitive": true,
    "value": "'$branch_id'"
  },
    "db_url": {
    "sensitive": true,
    "value": "postgres://'$PGUSERNAME':'$PGPASSWORD'@'$endpoint_id'.'$region'.'$cloud_provider'.neon.tech"
  },
    "db_url_with_pooler": {
    "sensitive": true,
    "value": "postgres://'$PGUSERNAME':'$PGPASSWORD'@'$endpoint_id'-pooler.'$region'.'$cloud_provider'.neon.tech"
  }
}' > /qovery-output/qovery-output.json

else
  endpoint_id=$(echo $branch | jq --raw-output '.endpoints[0].host' | cut -d'.' -f1)
  region=$(echo $branch | jq --raw-output '.endpoints[0].host' | cut -d'.' -f2)
  cloud_provider=$(echo $branch | jq --raw-output '.endpoints[0].host' | cut -d'.' -f3)
  host=$(echo $branch | jq --raw-output '.endpoints[0].host')
  branch_id=$(echo $branch | jq --raw-output '.endpoints[0].branch_id')

  echo '{
  "host": {
    "sensitive": true,
    "value": "'$host'"
  },
  "endpoint_id": {
    "sensitive": true,
    "value": "'$endpoint_id'"
  },
    "branch_id": {
    "sensitive": true,
    "value": "'$branch_id'"
  },
    "db_url": {
    "sensitive": true,
    "value": "postgres://$PGUSERNAME:'$PGPASSWORD'@'$endpoint_id'.'$region'.'$cloud_provider'.neon.tech"
  },
    "db_url_with_pooler": {
    "sensitive": true,
    "value": "postgres://'$PGUSERNAME':'$PGPASSWORD'@'$endpoint_id'-pooler.'$region'.'$cloud_provider'.neon.tech"
  }
}' > /qovery-output/qovery-output.json

fi


echo "shell script executed successfully with output values - check out your Qovery environment variables :)"