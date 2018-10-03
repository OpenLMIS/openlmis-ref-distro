from flask_appbuilder.security.manager import AUTH_OID, AUTH_REMOTE_USER, AUTH_DB, AUTH_LDAP, AUTH_OAUTH
SQLALCHEMY_DATABASE_URI = \
    'postgresql+psycopg2://superset:superset123@db:5432/superset'
SQLALCHEMY_TRACK_MODIFICATIONS = True
SECRET_KEY = 'thisISaSECRET_1234'

AUTH_TYPE = AUTH_OAUTH

OAUTH_PROVIDERS = [
    {'name': 'openlmis', 'icon': 'fa-google', 'token_key': 'access_token',
        'remote_app': {
            'consumer_key': 'tableau-wdc',
            'consumer_secret': 'changeme',
            'base_url': 'https://uat.openlmis.org/api/oauth',
            'access_token_url': 'https://uat.openlmis.org/api/oauth/token',
            'authorize_url': 'https://uat.openlmis.org/api/oauth/authorize?response_type=token&redirect_uri=http://localhost:8088/superset/welcome'}
     }
]

# The default user self registration role
AUTH_USER_REGISTRATION_ROLE = "Admin"

# Will allow user self registration
AUTH_USER_REGISTRATION = True
