#!/bin/sh

# clean up commands from https://openlmis.atlassian.net/wiki/display/OP/Docker+Cheat+Sheet
docker stop $(docker ps -a -q)
docker rm $(docker ps -a -q)
docker volume rm $(docker volume ls -qf dangling=true)
docker images | grep "<none>" | awk '{print $3}' | xargs docker rmi
