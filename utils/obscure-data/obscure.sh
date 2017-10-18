#!/usr/bin/env bash

# user's details
: ${ENCODED_USER_PASSWORD:?"Need to set ENCODED_USER_PASSWORD"}

# these are the credentials the UI uses
: ${OLD_UI_CLIENT_ID:?"Need to set OLD_UI_CLIENT_ID"}
: ${NEW_UI_CLIENT_ID:?"Need to set NEW_UI_CLIENT_ID"}
: ${UI_CLIENT_SECRET:?"Need to set UI_CLIENT_SECRET"}

# these are the credentials the services use
: ${OLD_SERVICE_CLIENT_ID}:?"Need to set OLD_SERVICE_CLIENT_ID"}
: ${NEW_SERVICE_CLIENT_ID}:?"Need to set NEW_SERVICE_CLIENT_ID"}
: ${SERVICE_CLIENT_SECRET:?"Need to set SERVICE_CLIENT_SECRET"}

sql=$(cat <<EOF
BEGIN;
UPDATE referencedata.users SET email = null;
UPDATE auth.auth_users SET password = '${ENCODED_USER_PASSWORD}';
UPDATE auth.oauth_client_details SET clientid = '${NEW_SERVICE_CLIENT_ID}',
                                     clientsecret = '${SERVICE_CLIENT_SECRET}'
  WHERE clientid = '${OLD_SERVICE_CLIENT_ID}';
UPDATE auth.oauth_client_details SET clientid = '${NEW_UI_CLIENT_ID}',
                                     clientsecret = '${UI_CLIENT_SECRET}'
  WHERE clientid = '${OLD_UI_CLIENT_ID}';
COMMIT;
EOF
)

psql -c "$sql"
