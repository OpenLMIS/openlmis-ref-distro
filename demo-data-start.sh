#!/bin/bash

######################################################################
# Start with demo data
#
# Start with the full set of demo data (including very large demo
# data, VLDD.
######################################################################

# Get latest demo data image
docker pull openlmis/demo-data

# Start the db and demo data
docker-compose up -d db
docker-compose -f docker-compose.yml -f docker-compose.demo-data.yml up demo-data
docker-compose -f docker-compose.yml -f docker-compose.demo-data.yml rm -f demo-data

# Start as normal once demo data finishes
docker-compose up --build --remove-orphans --force-recreate
