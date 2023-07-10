#!/bin/bash

# exit on error
set -e  

yarn -s neonctl branches create \
          --api-key $NEON_API_KEY \
          --project.id $NEON_PROJECT_ID \
          --branch.name $QOVERY_ENVIRONMENT_NAME \
          --endpoint.type read_write -o json \
          2> branch_err > branch_out || true

echo "branch create result:\n" >> debug.log
cat branch_out >> debug.log


if echo "$(cat branch_err)" | grep -q "already exists"; then
  # Get the branch id by its name. We list all branches and filter by name
  branch_id=$(yarn -s neonctl branches list --project.id $NEON_PROJECT_ID --api-key $NEON_API_KEY -o json \
      | jq -c '.[] | select(.name | contains("'$QOVERY_ENVIRONMENT_NAME'")) .id' \
      | jq -r)

  echo "branch exists, branch id: ${branch_id}" >> debug.log

  branch_id=${branch_id}
  db_url=$(yarn -s neonctl cs ${branch_id} --project.id $NEON_PROJECT_ID --role.name $PGUSERNAME --database.name $NEON_DATABASE_NAME --prisma $PRISMA --api-key $NEON_API_KEY)
  db_url_with_pooler=$(yarn -s neonctl cs ${branch_id} --project.id $NEON_PROJECT_ID --role.name $PGUSERNAME --database.name $NEON_DATABASE_NAME --pooled --prisma $PRISMA --api-key $NEON_API_KEY)

  echo '{
      "db_url": {
      "sensitive": true,
      "value": "'$db_url'"
    },
      "db_url_with_pooler": {
      "sensitive": true,
      "value": "'$db_url_with_pooler'"
    }
  }' > /qovery-output/qovery-output.json

else
  branch_id=$(cat branch_out | jq --raw-output '.branch.id')

  echo "branch doesn't exist, branch id: ${branch_id}" >> debug.log

  branch_id=${branch_id}
  db_url=$(yarn -s neonctl cs ${branch_id} --project.id $NEON_PROJECT_ID --role.name $PGUSERNAME --database.name $NEON_DATABASE_NAME --prisma $PRISMA --api-key $NEON_API_KEY) 
  db_url_with_pooler=$(yarn -s neonctl cs ${branch_id} --project.id $NEON_PROJECT_ID --role.name $PGUSERNAME --database.name $NEON_DATABASE_NAME --pooled --prisma $PRISMA --api-key $NEON_API_KEY) 

  echo '{
      "db_url": {
      "sensitive": true,
      "value": "'$db_url'"
    },
      "db_url_with_pooler": {
      "sensitive": true,
      "value": "'$db_url_with_pooler'"
    }
  }' > /qovery-output/qovery-output.json
fi

echo "Shell script executed successfully with output values - check out your Qovery environment variables :)"