# This is the custom security manager for the OpenLMIS version of Superset
# This file defines a CustomSecurityManager and AuthOAuthView
# which support fetching user credentials and supporting redirects to specific dashboards

from flask import flash, redirect, session, url_for, g, request
from flask_appbuilder.security.views import expose, AuthOAuthView
from superset.security import SupersetSecurityManager
import logging
class AuthOAuthView(AuthOAuthView):
    login_template = 'appbuilder/general/security/login_oauth.html'

    @expose('/login/')
    @expose('/login/<provider>')
    @expose('/login/<provider>/<register>')
    def login(self, provider=None, register=None):
        logging.debug('Provider: {0}'.format(provider))
        #Set the redirect_url
        redirect_url = self.appbuilder.get_url_for_index
        if request.args.get('redirect_url') is not None:
            redirect_url = request.args.get('redirect_url')

        if g.user is not None and g.user.is_authenticated and not g.user.is_anonymous():
            logging.debug("Already authenticated {0}".format(g.user))
            return redirect(redirect_url)
        if provider is None:
            return self.render_template(self.login_template,
                               providers = self.appbuilder.sm.oauth_providers,
                               title=self.title,
                               appbuilder=self.appbuilder)
        else:
            logging.debug("Going to call authorize for: {0}".format(provider))
            try:
                if register:
                    logging.debug('Login to Register')
                    session['register'] = True
                return self.appbuilder.sm.oauth_remotes[provider].authorize(callback=url_for('.oauth_authorized',provider=provider, _external=True))
            except Exception as e:
                logging.error("Error on OAuth authorize: {0}".format(e))
                flash(as_unicode(self.invalid_login_message), 'warning')
                return redirect(self.appbuilder.get_url_for_index)

class CustomSecurityManager(SupersetSecurityManager):

    authoauthview = AuthOAuthView
    def __init__(self, appbuilder):
        super(CustomSecurityManager, self).__init__(appbuilder)

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
