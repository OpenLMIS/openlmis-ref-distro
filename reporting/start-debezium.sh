#!/bin/bash

docker-compose \
    -f docker-compose.yml \
    -f docker-compose.debezium.yml \
    up \
    --scale scalyr=0 \
    --scale nifi=0 \
    --scale nginx=0 \
    --scale superset=0