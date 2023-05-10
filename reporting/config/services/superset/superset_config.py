"""
Superset config
"""
import os
import base64
from flask_appbuilder.security.manager import AUTH_OAUTH
from superset_patchup.oauth import CustomSecurityManager


def stringToBase64(s):
    return base64.b64encode(s.encode('utf-8')).decode('utf-8')


def lookup_password(url):
    return os.environ['POSTGRES_PASSWORD']


SQLALCHEMY_DATABASE_URI = 'postgresql+psycopg2://{}:{}@db:5432/open_lmis_reporting'.format(
    os.environ['POSTGRES_USER'],
    os.environ['POSTGRES_PASSWORD'])

SQLALCHEMY_CUSTOM_PASSWORD_STORE = lookup_password

SQLALCHEMY_TRACK_MODIFICATIONS = True
SECRET_KEY = os.environ['SUPERSET_SECRET_KEY']

OL_SUPERSET_USER = os.environ['OL_SUPERSET_USER']
OL_SUPERSET_PASSWORD = os.environ['OL_SUPERSET_PASSWORD']
AUTHORIZATION_HEADER_TOKEN = stringToBase64(
    '%s:%s' % (OL_SUPERSET_USER, OL_SUPERSET_PASSWORD))

AUTH_TYPE = AUTH_OAUTH
OAUTH_PROVIDERS = [
    {
        'name': 'openlmis',
        'icon': 'fa-sign-in',
        'token_key': 'access_token',
        'remote_app': {
            'client_id': OL_SUPERSET_USER,
            'client_secret': OL_SUPERSET_PASSWORD,
            'client_kwargs': {
                'scope': 'read write'
            },
            'access_token_method': 'POST',
            'access_token_headers': {
                'Authorization': 'Basic %s' % AUTHORIZATION_HEADER_TOKEN
            },
            'api_base_url': '%s/api/oauth' % os.environ['OL_BASE_URL'],
            'access_token_url': '%s/api/oauth/token?grant_type=authorization_code' % os.environ['OL_BASE_URL'],
            'authorize_url': '%s/api/oauth/authorize?' % os.environ['OL_BASE_URL'],
            'custom_redirect_url': '%s/oauth-authorized/openlmis?' % os.environ['SUPERSET_URL']
        }
    }
]

# Set URL scheme for superset-patchup redirect URLs
PREFERRED_URL_SCHEME = "https"

# The default user self registration role
AUTH_USER_REGISTRATION_ROLE = "OLMIS_Gamma"

# Will allow user self registration
AUTH_USER_REGISTRATION = True

# Extract and use X-Forwarded-For/X-Forwarded-Proto headers?
ENABLE_PROXY_FIX = True

# Allow iFrame access from openLMIS running on localhost
HTTP_HEADERS = {'X-Frame-Options': 'allow-from %s' % os.environ['OL_BASE_URL']}

# CSV Options: key/value pairs that will be passed as argument to DataFrame.to_csv method
# note: index option should not be overridden
CSV_EXPORT = {
    'encoding': 'utf-8',
}

# Custom security manager
CUSTOM_SECURITY_MANAGER = CustomSecurityManager
ENABLE_CORS = True
CORS_OPTIONS = {
    'origins': [os.environ['OL_BASE_URL']],
    'supports_credentials': True
}

# Add custom roles
ADD_CUSTOM_ROLES = True
CUSTOM_ROLES = {'OLMIS_Gamma': {'all_datasource_access'}}

# Enable template processing in SQL - among others for {{current_username()}} macro
FEATURE_FLAGS = {
    "ENABLE_TEMPLATE_PROCESSING": True,
    "VERSIONED_EXPORT": True
}
