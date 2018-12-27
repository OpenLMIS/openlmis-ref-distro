#!/bin/bash

docker-compose -f docker-compose.yml -f docker-compose.debezium.yml \
    exec kafka /usr/bin/kafka-console-consumer \
    --bootstrap-server kafka:29092 \
    --from-beginning \
    --property print.key=true \
    --topic openlmis.referencedata.programs