"""
Superset config
"""
from flask_appbuilder.security.manager import AUTH_OAUTH

from superset_patchup.oauth import CustomSecurityManager

SQLALCHEMY_DATABASE_URI = 'postgresql+psycopg2://postgres:p@ssw0rd@db:5432/open_lmis_reporting'
SQLALCHEMY_TRACK_MODIFICATIONS = True
SECRET_KEY = 'thisISaSECRET_1234'

AUTH_TYPE = AUTH_OAUTH

OAUTH_PROVIDERS = [
    {   'name': 'openlmis',
        'icon': 'fa-sign-in',
        'token_key':'access_token',
        'remote_app': {
            'consumer_key': 'superset',
            'consumer_secret': 'changeme',
            'request_token_params': {
                'scope': 'read write'
            },
            'access_token_method': 'POST',
            'access_token_headers': {
                'Authorization':'Basic c3VwZXJzZXQ6Y2hhbmdlbWU='
            },
            'base_url': 'https://uat.openlmis.org/api/oauth',
            'access_token_url': 'https://uat.openlmis.org/api/oauth/token?grant_type=authorization_code',
            'authorize_url': 'https://uat.openlmis.org/api/oauth/authorize?'}
     }
]

# The default user self registration role
AUTH_USER_REGISTRATION_ROLE = "OLMIS_Gamma"

# Will allow user self registration
AUTH_USER_REGISTRATION = True

# Extract and use X-Forwarded-For/X-Forwarded-Proto headers?
ENABLE_PROXY_FIX = True

# Allow iFrame access from openLMIS running on localhost
HTTP_HEADERS = {'X-Frame-Options': 'allow-from https://uat.openlmis.org'}

# CSV Options: key/value pairs that will be passed as argument to DataFrame.to_csv method
# note: index option should not be overridden
CSV_EXPORT = {
    'encoding': 'utf-8',
}

# Custom security manager
CUSTOM_SECURITY_MANAGER = CustomSecurityManager

# Add custom roles
ADD_CUSTOM_ROLES = True
CUSTOM_ROLES = {'OLMIS_Gamma': {'all_datasource_access'}}
