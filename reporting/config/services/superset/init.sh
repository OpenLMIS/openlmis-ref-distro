#!/bin/bash

set -e

: ${SUPERSET_ADMIN_USERNAME:?"Need to set SUPERSET_ADMIN_USERNAME"}
: ${SUPERSET_ADMIN_PASSWORD:?"Need to set SUPERSET_ADMIN_PASSWORD"}
: ${SUPERSET_VERSION:?"Need to set SUPERSET_VERSION"}

APP_DIR="/usr/local/lib/python3.6/site-packages/superset"
CONFIG_DIR="/etc/superset"

# App initialization
fabmanager create-admin --app superset --username ${SUPERSET_ADMIN_USERNAME} --firstname Admin --lastname Admin --email noreply --password ${SUPERSET_ADMIN_PASSWORD}

superset db upgrade
superset import_datasources -p $CONFIG_DIR/datasources/database.yaml
superset import_dashboards -p $CONFIG_DIR/dashboards/openlmis_uat_dashboards.json
superset init

gunicorn -w 2 --timeout 60 -b 0.0.0.0:8088 --reload --limit-request-line 0 --limit-request-field_size 0 superset:app