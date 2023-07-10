# Qovery lifecycle Job

This example shows how to execute a bash script and pass environment variables to other services within the same environment with Qovery Lifecycle Job. The `create-branch.sh` script creates a Neon branch, and runs whenever an environment is created. On the other hand, the `delete-branch.sh` script deletes a Neon branch, and runs whenever an environment is deleted.

## Prerequisites

To be able to test this script you will need to have Docker installed on your machine. If you don't have Docker installed, you can follow the instructions [here](https://docs.docker.com/get-docker/).

You will also need a Neon account. If you don't have one, you can create one [here](https://neon.tech/).

## How to use

### Necessary environment variables

Run the following command to create a `.env` file:

```bash
cp .env.example .env
```

Then, fill in the following environment variables:

- `NEON_API_KEY`: Your Neon API key. Check out the [Neon API documentation](https://neon.tech/docs/manage/api-keys#create-an-api-key) to learn how to generate one.
- `PGUSERNAME`: is the database user
- `PGPASSWORD`: is the database user
- `NEON_PROJECT_ID`: you can find it in your Neon project settings.
- `QOVERY_ENVIRONMENT_NAME`: you won't need this when deploying the lifecycle job to Qovery. This is only for testing purposes.

### Locally

First, clone the repository to your local machine:

```bash

git clone
```

To test the script, you can run the following commands:

While Docker is running, run the following command to build the image:

```bash
docker build -t shell-script .
```

Run the following command to run the image:

This command will run the `create-branch.sh` script:

```bash
docker run shell-script create-branch.sh --env-file ./.env
```

This command will run the `create-branch.sh` script:

```bash
docker run shell-script delete-branch.sh --env-file ./.env
```
