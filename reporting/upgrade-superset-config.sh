#!/usr/bin/env bash

docker container create --name superset-config-upgrade -v reporting_config-volume:/config hello-world
docker cp ./config/services/superset/. superset-config-upgrade:/config/superset
docker rm superset-config-upgrade
