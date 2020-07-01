#!/usr/bin/env bash

############################################################
# Initiates the settings.env file for reporting instance and
# automatically sets the necessary variables.
#
# Before running the script place it together with
# settings-sample.env file and appropriate OpenLMIS .env file.
#
# There are some values that a user is asked to insert.
############################################################

read -p "Provide a path to a source env file and press enter: " ENV
read -p "Provide a Virtual Host value for reporting (e.g. covid-ref-report.openlmis.org): " VIRTUAL_HOST_REPORTING
read -p "Provide username for OpenLMIS user with all possible permissions: " OL_ADMIN_USERNAME
read -p "Provide password for OpenLMIS user with all possible permissions: " OL_ADMIN_PASSWORD
read -p "Provide service-based client ID (leave blank if not used): " FHIR_ID
read -p "Provide service-based client secret (leave blank if not used): " FHIR_PASSWORD

source $ENV

SETTINGS_SAMPLE_FILE="settings-sample.env"
SETTINGS_FILE="settings.env"
cp $SETTINGS_SAMPLE_FILE $SETTINGS_FILE

generateBase64Password() {
  openssl rand -base64 29 | tr -d "/" | cut -c1-16
}

# Setting the variables with the inserted values
echo "Setting OL_ADMIN_USERNAME, OL_ADMIN_PASSWORD, VIRTUAL_HOST, FHIR_ID, FHIR_PASSWORD"
sed -i "s/\<OL_ADMIN_USERNAME\>=.*/OL_ADMIN_USERNAME=$OL_ADMIN_USERNAME/g" $SETTINGS_FILE 2>/dev/null || true
sed -i "s/\<OL_ADMIN_PASSWORD\>=.*/OL_ADMIN_PASSWORD=$OL_ADMIN_PASSWORD/g" $SETTINGS_FILE 2>/dev/null || true
sed -i "s/\<VIRTUAL_HOST\>=.*/VIRTUAL_HOST=$VIRTUAL_HOST_REPORTING/g" $SETTINGS_FILE 2>/dev/null || true
sed -i "s/\<FHIR_ID\>=.*/FHIR_ID=$FHIR_ID/g" $SETTINGS_FILE 2>/dev/null || true
sed -i "s/\<FHIR_PASSWORD\>=.*/FHIR_PASSWORD=$FHIR_PASSWORD/g" $SETTINGS_FILE 2>/dev/null || true

# Setting the variables with generated passwords
echo "Setting NGINX_BASIC_AUTH_PW, POSTGRES_PASSWORD, SUPERSET_POSTGRES_PASSWORD, SUPERSET_SECRET_KEY"
sed -i "s/\<NGINX_BASIC_AUTH_PW\>=.*/NGINX_BASIC_AUTH_PW=$(generateBase64Password)/g" $SETTINGS_FILE 2>/dev/null || true
sed -i "s/\<POSTGRES_PASSWORD\>=.*/POSTGRES_PASSWORD=$(generateBase64Password)/g" $SETTINGS_FILE 2>/dev/null || true
sed -i "s/\<SUPERSET_POSTGRES_PASSWORD\>=.*/SUPERSET_POSTGRES_PASSWORD=$(generateBase64Password)/g" $SETTINGS_FILE 2>/dev/null || true
sed -i "s/\<SUPERSET_SECRET_KEY\>=.*/SUPERSET_SECRET_KEY=$(generateBase64Password)/g" $SETTINGS_FILE 2>/dev/null || true

# Setting the variables based on the chosen env file
echo "Setting TRUSTED_HOSTNAME, OL_BASE_URL, AUTH_SERVER_CLIENT_ID, AUTH_SERVER_CLIENT_SECRET, OL_SUPERSET_PASSWORD, SRC_POSTGRES_PASSWORD"
sed -i "s/\<TRUSTED_HOSTNAME\>=.*/TRUSTED_HOSTNAME=${VIRTUAL_HOST}/g" $SETTINGS_FILE 2>/dev/null || true
sed -i "s/\<OL_BASE_URL\>=.*/OL_BASE_URL=https:\/\/${VIRTUAL_HOST}/g" $SETTINGS_FILE 2>/dev/null || true
sed -i "s/\<AUTH_SERVER_CLIENT_ID\>=.*/AUTH_SERVER_CLIENT_ID=${AUTH_SERVER_CLIENT_ID}/g" $SETTINGS_FILE 2>/dev/null || true
sed -i "s/\<AUTH_SERVER_CLIENT_SECRET\>=.*/AUTH_SERVER_CLIENT_SECRET=${AUTH_SERVER_CLIENT_SECRET}/g" $SETTINGS_FILE 2>/dev/null || true
sed -i "s/\<OL_SUPERSET_PASSWORD\>=.*/OL_SUPERSET_PASSWORD=${AUTH_SUPERSET_CLIENT_PASSWORD}/g" $SETTINGS_FILE 2>/dev/null || true
sed -i "s/\<SRC_POSTGRES_PASSWORD\>=.*/SRC_POSTGRES_PASSWORD=${POSTGRES_PASSWORD}/g" $SETTINGS_FILE 2>/dev/null || true
