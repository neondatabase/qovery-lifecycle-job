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

# Extracting the username
username=$(echo "$db_url" | awk -F"://|:" '{print $2}')
echo "Username: $username"

# Extracting the password
password=$(echo "$db_url" | awk -F":" '{print $3}' | awk -F"@" '{print $1}')
echo "Password: ********"

# Extracting the host
host=$(echo "$db_url" | awk -F"@" '{print $2}' | awk -F"/" '{print $1}')
echo "Host: $host"

# Extracting the database
database=$(echo "$db_url" | awk -F"/" '{print $NF}')
echo "Database: $database"

echo '{
    "DIRECT_DATABASE_URL": {
    "sensitive": true,
    "value": "'$db_url'"
  },
    "DATABASE_URL": {
    "sensitive": true,
    "value": "'$db_url_with_pooler'"
  },
    "POSTGRES_HOST": {
    "sensitive": false,
    "value": "'$host'"
  },
    "POSTGRES_PORT": {
    "sensitive": false,
    "value": "5432"
  },
    "POSTGRES_USER": {
    "sensitive": false,
    "value": "'$username'"
  },
    "POSTGRES_PASSWORD": {
    "sensitive": true,
    "value": "'$password'"
  }
}' > /qovery-output/qovery-output.json


echo "Shell script executed successfully with output values - check out your Qovery environment variables :)"
