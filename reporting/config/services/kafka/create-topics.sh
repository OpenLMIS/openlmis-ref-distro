#!/bin/sh
sleep 40
kafka-topics --zookeeper zookeeper:32181 --replication-factor 1 --create --topic sohlineitems --partitions 1 --config cleanup.policy=compact --config segment.ms=1000