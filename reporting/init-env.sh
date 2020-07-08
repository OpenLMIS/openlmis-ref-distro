#!/usr/bin/env bash

############################################################
# Initiates the settings.env file for reporting instance.
#
# Before running the script place it together with
# settings-sample.env file and appropriate OpenLMIS .env file.
#
# The script automatically sets the necessary variables in
# both reporting and OpenLMIS env files.
#
# There are some values that a user is asked to insert.
############################################################

generateBase64Password() {
  openssl rand -base64 29 | cut -c1-16
}

read -p "Provide a path to an OpenLMIS source env file and press enter: " ENV
read -p "Provide a Virtual Host value for reporting (e.g. covid-ref-report.openlmis.org): " VIRTUAL_HOST_REPORTING
read -p "Provide username for an existing OpenLMIS user with all possible permissions: " OL_ADMIN_USERNAME
read -p "Provide password for an existing OpenLMIS user with all possible permissions: " OL_ADMIN_PASSWORD
read -p "Provide service-based client ID (leave blank if not used): " FHIR_ID
read -p "Provide service-based client secret (leave blank if not used): " FHIR_PASSWORD

if [[ $(grep -L "^AUTH_SERVER_CLIENT_ID" $ENV) ]]; then
    read -p "Provide auth-ui client ID: " AUTH_SERVER_CLIENT_ID
    read -p "Provide auth-ui client secret: " AUTH_SERVER_CLIENT_SECRET
fi

if [[ $(grep -L "^SUPERSET_CLIENT_ID" $ENV) ]]; then
    echo -e '\n# Superset needs an OpenLMIS user which allows to sign-in via OAUTH \nSUPERSET_CLIENT_ID= \nSUPERSET_CLIENT_SECRET= \nSUPERSET_REDIRECT_URI=' >> $ENV
    read -p "Provide username for OpenLMIS superset user which will allow to sign-in via OAUTH: " SUPERSET_CLIENT_ID
    SUPERSET_CLIENT_SECRET=$(generateBase64Password)
    sed -i '' -e "s#^SUPERSET_CLIENT_ID.*#SUPERSET_CLIENT_ID=$SUPERSET_CLIENT_ID#" $ENV 2>/dev/null || true
    sed -i '' -e "s#^SUPERSET_CLIENT_SECRET.*#SUPERSET_CLIENT_SECRET=${SUPERSET_CLIENT_SECRET}#" $ENV 2>/dev/null || true
fi

source $ENV

SETTINGS_SAMPLE_FILE="settings-sample.env"
SETTINGS_FILE="settings.env"
cp $SETTINGS_SAMPLE_FILE $SETTINGS_FILE

# Setting SUPERSET_REDIRECT_URI in OpenLMIS env file
echo "Setting SUPERSET_REDIRECT_URI"
SUPERSET_REDIRECT_URI=https://$VIRTUAL_HOST_REPORTING:8088/oauth-authorized/openlmis
sed -i '' -e "s#^SUPERSET_REDIRECT_URI.*#SUPERSET_REDIRECT_URI=$SUPERSET_REDIRECT_URI#" $ENV 2>/dev/null || true

# Setting SUPERSET_URL in OpenLMIS env file
echo "Setting SUPERSET_URL"
if [[ $(grep -L "^SUPERSET_URL" $ENV) ]]; then
  echo -e '\n# Set the URL to Superset instance \nSUPERSET_URL=' >> $ENV
fi
sed -i '' -e "s#^SUPERSET_URL.*#SUPERSET_URL=https://$VIRTUAL_HOST_REPORTING:8088#" $ENV 2>/dev/null || true

# Setting the variables with the inserted values
echo "Setting OL_ADMIN_USERNAME, OL_ADMIN_PASSWORD, VIRTUAL_HOST, FHIR_ID, FHIR_PASSWORD"
sed -i '' -e "s#^OL_ADMIN_USERNAME.*#OL_ADMIN_USERNAME=$OL_ADMIN_USERNAME#" $SETTINGS_FILE 2>/dev/null || true
sed -i '' -e "s#^OL_ADMIN_PASSWORD.*#OL_ADMIN_PASSWORD=$OL_ADMIN_PASSWORD#" $SETTINGS_FILE 2>/dev/null || true
sed -i '' -e "s#^VIRTUAL_HOST.*#VIRTUAL_HOST=$VIRTUAL_HOST_REPORTING#" $SETTINGS_FILE 2>/dev/null || true
sed -i '' -e "s#^FHIR_ID.*#FHIR_ID=$FHIR_ID#" $SETTINGS_FILE 2>/dev/null || true
sed -i '' -e "s#^FHIR_PASSWORD.*#FHIR_PASSWORD=$FHIR_PASSWORD#" $SETTINGS_FILE 2>/dev/null || true

# Setting the variables with generated passwords
echo "Setting NGINX_BASIC_AUTH_PW, POSTGRES_PASSWORD, SUPERSET_POSTGRES_PASSWORD, SUPERSET_SECRET_KEY"
sed -i '' -e "s#^NGINX_BASIC_AUTH_PW.*#NGINX_BASIC_AUTH_PW=$(generateBase64Password)#" $SETTINGS_FILE 2>/dev/null || true
sed -i '' -e "s#^POSTGRES_PASSWORD.*#POSTGRES_PASSWORD=$(generateBase64Password)#" $SETTINGS_FILE 2>/dev/null || true
sed -i '' -e "s#^SUPERSET_POSTGRES_PASSWORD.*#SUPERSET_POSTGRES_PASSWORD=$(generateBase64Password)#" $SETTINGS_FILE 2>/dev/null || true
sed -i '' -e "s#^SUPERSET_SECRET_KEY.*#SUPERSET_SECRET_KEY=$(generateBase64Password)#" $SETTINGS_FILE 2>/dev/null || true

# Setting the variables based on the chosen env file
echo "Setting TRUSTED_HOSTNAME, OL_BASE_URL, AUTH_SERVER_CLIENT_ID, AUTH_SERVER_CLIENT_SECRET, OL_SUPERSET_PASSWORD, SRC_POSTGRES_USER, SRC_POSTGRES_PASSWORD, SCALYR_API_KEY, OL_SUPERSET_USER, OL_SUPERSET_PASSWORD"
sed -i '' -e "s#^TRUSTED_HOSTNAME.*#TRUSTED_HOSTNAME=${VIRTUAL_HOST}#" $SETTINGS_FILE 2>/dev/null || true
sed -i '' -e "s#^OL_BASE_URL.*#OL_BASE_URL=${BASE_URL}#" $SETTINGS_FILE 2>/dev/null || true
sed -i '' -e "s#^AUTH_SERVER_CLIENT_ID.*#AUTH_SERVER_CLIENT_ID=${AUTH_SERVER_CLIENT_ID}#" $SETTINGS_FILE 2>/dev/null || true
sed -i '' -e "s#^AUTH_SERVER_CLIENT_SECRET.*#AUTH_SERVER_CLIENT_SECRET=${AUTH_SERVER_CLIENT_SECRET}#" $SETTINGS_FILE 2>/dev/null || true
sed -i '' -e "s#^SRC_POSTGRES_USER.*#SRC_POSTGRES_USER=${POSTGRES_USER}#" $SETTINGS_FILE 2>/dev/null || true
sed -i '' -e "s#^SRC_POSTGRES_PASSWORD.*#SRC_POSTGRES_PASSWORD=${POSTGRES_PASSWORD}#" $SETTINGS_FILE 2>/dev/null || true
sed -i '' -e "s#^SCALYR_API_KEY.*#SCALYR_API_KEY=${SCALYR_API_KEY}#" $SETTINGS_FILE 2>/dev/null || true
sed -i '' -e "s#^OL_SUPERSET_USER.*#OL_SUPERSET_USER=${SUPERSET_CLIENT_ID}#" $SETTINGS_FILE 2>/dev/null || true
sed -i '' -e "s#^OL_SUPERSET_PASSWORD.*#OL_SUPERSET_PASSWORD=${SUPERSET_CLIENT_SECRET}#" $SETTINGS_FILE 2>/dev/null || true