#!/bin/bash

set -e

until curl -s -f "http://connect:8083/"; do
  >&2 echo -e "\nDebezium Connect is unavailable - sleeping"
  sleep 10
done

>&2 echo -e "\nDebezium Connect is up - registering connectors"

# ensure some environment variables are set
: "${DATABASE_URL:?DATABASE_URL not set in environment}"
: "${POSTGRES_USER:?POSTGRES_USER not set in environment}"
: "${POSTGRES_PASSWORD:?POSTGRES_PASSWORD not set in environment}"
: "${SRC_POSTGRES_HOST:?SRC_POSTGRES_HOST not set in environment}"
: "${SRC_POSTGRES_PORT:?SRC_POSTGRES_POST not set in environment}"
: "${SRC_POSTGRES_DB:?SRC_POSTGRES_DB not set in environment}"
: "${SRC_POSTGRES_USER:?SRC_POSTGRES_USER not set in environment}"
: "${SRC_POSTGRES_PASSWORD:?SRC_POSTGRES_PASSWORD not set in environment}"

# pull apart some of those pieces stuck together in DATABASE_URL
POSTGRES_HOST=`echo ${DATABASE_URL} | sed -E 's/^.*\/{2}(.+):.*$/\1/'` # //<host>:
: "${POSTGRES_HOST:?Host not parsed}"

POSTGRES_PORT=`echo ${DATABASE_URL} | sed -E 's/^.*\:([0-9]+)\/.*$/\1/'` # :<port>/
: "${POSTGRES_PORT:?Port not parsed}"

POSTGRES_DB=`echo ${DATABASE_URL} | sed -E 's/^.*\/(.+)\?*$/\1/'` # /<db>?
: "${POSTGRES_DB:?DB not set}"

echo -e "\n\nReplacing database info of sink JSON files, then registering"
for f in /config/connect/sink-*.json
do
  echo -e "\n\nProcessing $f file..."
  mv $f temp.json
  jq -r --arg dburl "$DATABASE_URL" --arg dbuser "$POSTGRES_USER" --arg dbpassword "$POSTGRES_PASSWORD" '.config["connection.url"] |= $dburl | .config["connection.user"] |= $dbuser | .config["connection.password"] |= $dbpassword' temp.json > $f
  rm temp.json
  curl -s -X POST -H "Accept:application/json" -H  "Content-Type:application/json" http://connect:8083/connectors/ -d @$f
done

echo -e "\n\nReplacing database info of source JSON files, then registering"
for f in /config/connect/source-*.json
do
  echo -e "\n\nProcessing $f file..."
  mv $f temp.json
  jq -r --arg dbhost "$SRC_POSTGRES_HOST" --arg dbport "$SRC_POSTGRES_PORT" --arg dbname "$SRC_POSTGRES_DB" --arg dbuser "$SRC_POSTGRES_USER" --arg dbpassword "$SRC_POSTGRES_PASSWORD" '.config["database.hostname"] |= $dbhost | .config["database.port"] |= $dbport | .config["database.dbname"] |= $dbname | .config["database.user"] |= $dbuser | .config["database.password"] |= $dbpassword' temp.json > $f
  rm temp.json
  curl -s -X POST -H "Accept:application/json" -H  "Content-Type:application/json" http://connect:8083/connectors/ -d @$f
done

echo -e "\n\nRegistered all connectors!"
