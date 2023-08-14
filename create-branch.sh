#!/bin/bash

# exit on error
set -e  

yarn -s neonctl branches create \
          --api-key $NEON_API_KEY \
          --project-id $NEON_PROJECT_ID \
          --name $QOVERY_ENVIRONMENT_NAME \
          --compute --type read_write -o json \
          2> branch_err > branch_out || true

echo "branch create result:\n" >> debug.log
cat branch_out >> debug.log

branch_id=$(cat branch_out | jq --raw-output '.branch.id')

db_url=$(yarn -s neonctl cs ${QOVERY_ENVIRONMENT_NAME} --project-id $NEON_PROJECT_ID --role-name $PGUSERNAME --database-name $NEON_DATABASE_NAME --api-key $NEON_API_KEY) 
db_url_with_pooler=$(yarn -s neonctl cs ${QOVERY_ENVIRONMENT_NAME} --project-id $NEON_PROJECT_ID --role-name $PGUSERNAME --database-name $NEON_DATABASE_NAME --pooled --api-key $NEON_API_KEY) 

echo '{
    "DIRECT_DATABASE_URL": {
    "sensitive": true,
    "value": "'$db_url'"
  },
    "DATABASE_URL": {
    "sensitive": true,
    "value": "'$db_url_with_pooler'"
  }
}' > /qovery-output/qovery-output.json


echo "Shell script executed successfully with output values - check out your Qovery environment variables :)"