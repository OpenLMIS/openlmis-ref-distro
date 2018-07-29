#!/bin/bash
set -e

psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" --dbname "$POSTGRES_DB" <<-EOSQL
    CREATE DATABASE open_lmis_reporting;
    GRANT ALL PRIVILEGES ON DATABASE open_lmis_reporting TO $POSTGRES_USER;
EOSQL
