"""
Superset config
"""
from flask_appbuilder.security.manager import AUTH_OAUTH

SQLALCHEMY_DATABASE_URI = \
    'postgresql+psycopg2://superset:superset123@db:5432/superset'
SQLALCHEMY_TRACK_MODIFICATIONS = True
SECRET_KEY = 'thisISaSECRET_1234'

AUTH_TYPE = AUTH_OAUTH

OAUTH_PROVIDERS = [
    {   'name': 'openlmis',
        'icon': 'fa-google',
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
AUTH_USER_REGISTRATION_ROLE = "Public"

# Will allow user self registration
AUTH_USER_REGISTRATION = True

# Allow iFrame access from openLMIS running on localhost
HTTP_HEADERS = {'X-Frame-Options': 'allow-from https://uat.openlmis.org'}

from superset.security import SupersetSecurityManager
import logging
class CustomSecurityManager(SupersetSecurityManager):

    def oauth_user_info(self, provider, response=None):
        logging.debug("Oauth2 provider: {0}.".format(provider))
        if provider == 'openlmis':
            # get access token
            my_token = self.oauth_tokengetter()[0]
            # get referenceDataUserId
            reference_user_id = self.appbuilder.sm.oauth_remotes[provider].get('oauth/check_token', data={'token': my_token})
            reference_data_user_id = reference_user_id.data['referenceDataUserId']
            # get user details
            endpoint = 'users/{}'.format(reference_data_user_id)
            user_info = self.appbuilder.sm.oauth_remotes[provider].get(endpoint)
            me = user_info.data
            # get email
            email_endpoint = 'userContactDetails/{}'.format(reference_data_user_id)
            email = self.appbuilder.sm.oauth_remotes[provider].get(email_endpoint)
            return {'name': me['username'], 'email': email.data['emailDetails']['email'], 'id': me['id'], 'username': me['username'], 'first_name': me['firstName'], 'last_name': me['lastName']}

CUSTOM_SECURITY_MANAGER = CustomSecurityManager