#!/bin/bash

######################################################################
# Useful for starting a local copy for testing/development.
#
# Using bash and some simple conventions around ifconfig/ipconfig
# attempts to find the local IP (not a public IP in case of NAT)
# to start the Reference Distrubtion on.
#
# WARNING:  this is expiremental, you should back-up your settings.env
# file first before running this script.
######################################################################

set -e
HOST_ADDR=''
INTERFACE=`netstat -r -f inet | grep default | awk '{print $4}'`

findHost() {
  # if command -v ipconfig >/dev/null 2>&1; then
  #   echo '... getting Host IP from ipconfig'
  #   HOST_ADDR=`ipconfig getifaddr en0`
  # else
    echo '... getting Host IP from ifconfig'
    HOST_ADDR=`ifconfig $INTERFACE | grep 'inet ' | cut -d: -f2 | awk '{ print $2}'`
  # fi

  echo "IP: ${HOST_ADDR}"
}

checkOrFetchEnv() {
  if [ ! -f "settings.env" ]; then
    echo 'settings.env file not found, copying settings-sample.env'
    cp settings-sample.env settings.env
  else
    echo 'settings.env file found'
  fi
}

setEnvByIp() {
  echo "Replacing VIRTUAL_HOST, TRUSTED_HOSTNAME and OL_BASE_URL of settings.env file with ${HOST_ADDR}"
  sed -i '' -e "s#^VIRTUAL_HOST.*#VIRTUAL_HOST=${HOST_ADDR}#" settings.env 2>/dev/null || true
  sed -i '' -e "s#^TRUSTED_HOSTNAME.*#TRUSTED_HOSTNAME=${HOST_ADDR}#" settings.env 2>/dev/null || true
  sed -i '' -e "s#^OL_BASE_URL.*#OL_BASE_URL=http://${HOST_ADDR}#" settings.env 2>/dev/null || true
}

findHost
checkOrFetchEnv
setEnvByIp

BOLD=$(tput bold)
echo "Starting OpenLMIS Reporting Stack on ${BOLD}${HOST_ADDR}"
docker-compose \
  -f docker-compose.local.yml \
  up \
  --build \
  --remove-orphans \
  --force-recreate
