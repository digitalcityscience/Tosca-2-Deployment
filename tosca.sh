#!/bin/bash
echo "Checking if the environment is set up correctly"
if [ ! -f .env ]; then
  echo "Environment file not found. Please create a .env file in the root directory of the project"
  exit 1
 fi

echo "Environment file found. ✅"
echo "Copying the .env file to the docker build directory 📂"
cp .env dockerfile/.env
echo "Building the TOSCA project's containers 🏗️"
docker compose -f docker-compose-production.yml build
echo "Containers built successfully. ✅"

echo "Starting the TOSCA project's containers 🚀"
docker compose -f docker-compose-production.yml up -d