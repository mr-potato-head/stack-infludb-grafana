#!/bin/bash

set -e

##########################################
# Settings
##########################################
# INFLUDB
INFLUXDB_ADMIN_USER=admin
INFLUXDB_ADMIN_PASSWORD=4DM1NP455W0rD1NF1UXJ33D0M
INFLUXDB_ADMIN_TOKEN=4DM1N70K3N1NF1UXJ33D0M
INFLUXDB_ORGANIZATION=JEEDOM
INFLUXDB_BUCKET=jeedom

# GRAFANA
GRAFANA_ADMIN_USER=admin
GRAFANA_ADMIN_PASSWORD=4DM1NP455W0rD6r4F4N4J33D0M
##########################################

# Create volumes
echo "Creating docker volumes..."
docker volume create --name=volume_grafana
docker volume create --name=volume_influxdb

# Run influxdb docker for the first time in setup mode
echo "Setup InfluxDB..."
docker run -d -p 8086:8086 \
  -v volume_influxdb:/var/lib/influxdb2 \
  -e DOCKER_INFLUXDB_INIT_MODE=setup \
  -e DOCKER_INFLUXDB_INIT_USERNAME=$INFLUXDB_ADMIN_USER \
  -e DOCKER_INFLUXDB_INIT_PASSWORD=$INFLUXDB_ADMIN_PASSWORD \
  -e DOCKER_INFLUXDB_INIT_ORG=$INFLUXDB_ORGANIZATION \
  -e DOCKER_INFLUXDB_INIT_BUCKET=$INFLUXDB_BUCKET \
  -e DOCKER_INFLUXDB_INIT_ADMIN_TOKEN=$INFLUXDB_ADMIN_TOKEN \
  --name docker_influx \
  influxdb:2.0

# Add some delay to let influxdb start
echo "Add some delay to let influxdb start (30s)..."
sleep 30

# Create admin configuration in order to be able to run influx CLI commands in the container
echo "Creating admin config..."
docker exec -it docker_influx influx config create --active -n admin-config -u http://localhost:8086 -t ${INFLUXDB_ADMIN_TOKEN} -o ${INFLUXDB_ORGANIZATION}

# Get bucket ID of specific bucket
echo "Getting bucket ID..."
BUCKET_ID=$(docker exec -i docker_influx influx bucket list --org ${INFLUXDB_ORGANIZATION} | grep ${INFLUXDB_BUCKET} | awk -F" " '{print $1}')

# Create token with read right for Grafana
echo "Creating read token..."
READ_TOKEN=$(docker exec -i docker_influx influx auth create --read-bucket $BUCKET_ID --description READ_TOKEN | grep READ_TOKEN | awk -F" " '{print $3}')

# Create token with read/write right for the bridge
echo "Creating read/write token..."
READ_WRITE_TOKEN=$(docker exec -i docker_influx influx auth create --read-bucket $BUCKET_ID --write-bucket $BUCKET_ID --description READ_WRITE_TOKEN  | grep READ_WRITE_TOKEN | awk -F" " '{print $3}')

# Update .env file
echo "Creating .env file..."
export INFLUXDB_ORGANIZATION=$INFLUXDB_ORGANIZATION
export INFLUXDB_BUCKET=$INFLUXDB_BUCKET
export READ_TOKEN=$READ_TOKEN
export READ_WRITE_TOKEN=$READ_WRITE_TOKEN
export GRAFANA_ADMIN_USER=$GRAFANA_ADMIN_USER
export GRAFANA_ADMIN_PASSWORD=$GRAFANA_ADMIN_PASSWORD
envsubst < ".env_template" > ".env"

# Shutdown all containers
echo "Shuting down all running containers..."
docker stop $(docker ps -a -q)
docker rm $(docker ps -a -q)

# Pull images from docker hub and/or github
echo "Pulling docker images..."
docker compose -f ./docker-compose.yml pull 

# Start the whole stack (bridge, influx, grafana)
echo "Starting docker containers..."
docker compose -f ./docker-compose.yml up 