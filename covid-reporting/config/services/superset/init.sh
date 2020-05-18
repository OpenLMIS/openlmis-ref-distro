#!/bin/bash

: ${SUPERSET_ADMIN_USERNAME:?"Need to set SUPERSET_ADMIN_USERNAME"}
: ${SUPERSET_ADMIN_PASSWORD:?"Need to set SUPERSET_ADMIN_PASSWORD"}
: ${SUPERSET_VERSION:?"Need to set SUPERSET_VERSION"}

APP_DIR="/usr/local/lib/python3.6/site-packages/superset"
CONFIG_DIR="/etc/superset"

# Custom code
cp -rf $CONFIG_DIR/app-customizations/$SUPERSET_VERSION/* $APP_DIR &&

# Custom translation - creating .mo and .json files (from .po)
cd $APP_DIR && fabmanager babel-compile --target $APP_DIR/translations &&
cd $APP_DIR/translations/pt/LC_MESSAGES &&
    po2json -d superset -f jed1.x messages.po messages.json &&
    sed -i -e 's/null,//g' messages.json &&

# UI build
$APP_DIR/assets/js_build.sh &&

# wait for postgres
until PGPASSWORD=$POSTGRES_PASSWORD psql -h "db" -p "5432" -U "$POSTGRES_USER" -d "open_lmis_reporting" -c '\q'; do
  >&2 echo "Postgres is unavailable - sleeping"
  sleep 5
done

>&2 echo "Postgres is up"

# App initialization
sed -i "s/OLMIS_DATABASE_USER/$OLMIS_DATABASE_USER/g" $CONFIG_DIR/datasources/database.yaml
sed -i "s/OLMIS_DATABASE_URL/$OLMIS_DATABASE_URL/g" $CONFIG_DIR/datasources/database.yaml
sed -i "s/OLMIS_DATABASE_NAME/$OLMIS_DATABASE_NAME/g" $CONFIG_DIR/datasources/database.yaml
fabmanager create-admin --app superset --username ${SUPERSET_ADMIN_USERNAME} --firstname Admin --lastname Admin --email noreply --password ${SUPERSET_ADMIN_PASSWORD} &&
superset db upgrade &&
superset import_datasources -p $CONFIG_DIR/datasources/database.yaml &&
superset import_dashboards -p $CONFIG_DIR/dashboards/openlmis_uat_dashboards.json &&
superset init && gunicorn -w 2 --timeout 60 -b 0.0.0.0:8088 --reload --limit-request-line 0 --limit-request-field_size 0 superset:app
