#!/bin/bash

nohup /start.sh &> nohup.out &

until $(curl --output /dev/null --silent --get --fail http://localhost:9090/proxy); do
  printf '.'
  sleep 5
done
echo 'proxy started'
echo $(curl --silent -X GET http://localhost:9090/proxy)

echo 'starting proxy on 9091'
echo $(curl --silent -X POST -d 'port=9091&trustAllServers=true' http://localhost:9090/proxy)

echo $(curl --silent -X PUT http://localhost:9090/proxy/9091/har)

tail -f nohup.out
