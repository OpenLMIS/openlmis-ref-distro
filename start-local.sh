#!/bin/bash

######################################################################
# Useful for starting a local copy for testing/development.
#
# Using bash and some simple conventions around ifconfig/ipconfig
# attempts to find the local IP (not a public IP in case of NAT)
# to start the Reference Distrubtion on.
#
# WARNING:  this is expiremental, you should back-up your .env
# file first before running this script.
######################################################################

set -e
HOST_ADDR=''

findHost() {
  if command -v ipconfig >/dev/null 2>&1; then
    echo '... getting Host IP from ipconfig'
    HOST_ADDR=`ipconfig getifaddr en0`
  else
    echo '... getting Host IP from ifconfig'
    HOST_ADDR=`ifconfig  | grep 'inet addr:'| grep -v '127.0.0.1' | cut -d: -f2 | awk '{ print $1}'`
  fi

  echo "IP: ${HOST_ADDR}"
}

checkOrFetchEnv() {
  if [ ! -f ".env" ]; then
    echo '.env file not found, fetching from github...'
    wget -O .env https://raw.githubusercontent.com/OpenLMIS/openlmis-config/master/.env
  else
    echo '.env file found'
  fi
}

setEnvByIp() {
  echo "Replacing VIRTUAL_HOST and BASE_URL of .env file with ${HOST_ADDR}"
  sed -i '' -e "s#^VIRTUAL_HOST.*#VIRTUAL_HOST=${HOST_ADDR}#" .env
  sed -i '' -e "s#^BASE_URL.*#BASE_URL=http://${HOST_ADDR}#" .env
}

findHost
checkOrFetchEnv
setEnvByIp

BOLD=$(tput bold)
echo "Starting OpenLMIS Blue on ${BOLD}${HOST_ADDR}"
docker-compose up --build --remove-orphans --force-recreate
