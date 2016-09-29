#!/bin/sh

# Helper script for refreshing the containers from the DockerHub

set -e

docker pull gliderlabs/consul
docker pull gliderlabs/registrator
docker pull jwilder/nginx-proxy
docker pull openlmis/requisition
docker pull openlmis/referencedata
docker pull openlmis/auth
docker pull openlmis/notification
docker pull openlmis/postgres
docker pull openlmis/rsyslog
