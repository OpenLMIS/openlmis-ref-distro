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
    {'name': 'openlmis', 'icon': 'fa-google', 
     'remote_app': {
         'consumer_key': 'tableau-wdc',
         'consumer_secret': 'changeme',
         'base_url': 'https://uat.openlmis.org/api/oauth',
         'access_token_url': 'https://uat.openlmis.org/api/oauth/token',
         'authorize_url': 'https://uat.openlmis.org/api/oauth/authorize?response_type=token'}
     }
]

# The default user self registration role
AUTH_USER_REGISTRATION_ROLE = "Admin"

# Will allow user self registration
AUTH_USER_REGISTRATION = True

from superset.security import SupersetSecurityManager
import logging
class CustomSecurityManager(SupersetSecurityManager):
    # def __init__(self, appbuilder):
    #     super(CustomSecurityManager, self).__init__(appbuilder)
    #     logging.info('testing init')
    #     self.oauth_user_info = self.soauth_user_info
    #     # self.oauth_user_info = self.oauth_user_info(self, provider=None, response=None)
    
    def oauth_user_info(self, provider, response=None):
        if provider == 'openlmis':
            me = self.appbuilder.sm.oauth_remotes[provider].get(
                'userDetails').data
            logging.info(me)
            logging.debug("user_data: {0}".format(me))
            return {'name': me['user_name'], 'email': 'test@openlmis.org', 'id': me['username'], 'username': me['user_name'], 'first_name': '', 'last_name': ''}


CUSTOM_SECURITY_MANAGER = CustomSecurityManager
