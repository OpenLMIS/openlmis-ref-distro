#!/usr/bin/env bash

set -e

# ensure some environment variables are set
: "${DATABASE_URL:?DATABASE_URL not set in environment}"
: "${POSTGRES_USER:?POSTGRES_USER not set in environment}"
: "${POSTGRES_PASSWORD:?POSTGRES_PASSWORD not set in environment}"

# pull apart some of those pieces stuck together in DATABASE_URL

URL=`echo ${DATABASE_URL} | sed -E 's/^jdbc\:(.+)/\1/'` # jdbc:<url>
: "${URL:?URL not parsed}"

HOST=`echo ${DATABASE_URL} | sed -E 's/^.*\/{2}(.+):.*$/\1/'` # //<host>:
: "${HOST:?HOST not parsed}"

PORT=`echo ${DATABASE_URL} | sed -E 's/^.*\:([0-9]+)\/.*$/\1/'` # :<port>/
: "${PORT:?Port not parsed}"

DB=`echo ${DATABASE_URL} | sed -E 's/^.*\/(.+)\?*$/\1/'` # /<db>?
: "${DB:?DB not set}"

# pgpassfile makes it easy and safe to login
echo "${HOST}:${PORT}:${DB}:${POSTGRES_USER}:${POSTGRES_PASSWORD}" > pgpassfile
chmod 600 pgpassfile

#PGPASSFILE=/pgpassfile psql "${URL}" -U "${POSTGRES_USER}" -f sql/start.sql
export PGPASSFILE=/pgpassfile
export PGHOST=$HOST
export PGPORT=$PORT
export PGDATABASE=$DB
export PGUSER=$POSTGRES_USER

exec "$@"
