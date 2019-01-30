# This is the custom security manager for the OpenLMIS version of Superset
# This file defines a CustomSecurityManager and AuthOAuthView
# which support fetching user credentials and supporting redirects to specific dashboards

from flask import flash, redirect, session, url_for, g, request
from flask_appbuilder.security.views import expose, AuthOAuthView
from superset.security import SupersetSecurityManager
from flask_login import login_user
import logging
class AuthOAuthView(AuthOAuthView):
    login_template = 'appbuilder/general/security/login_oauth.html'

    @expose('/login/')
    @expose('/login/<provider>')
    @expose('/login/<provider>/<register>')
    def login(self, provider=None, register=None):
        logging.debug('Provider: {0}'.format(provider))
        #Set the redirect_url
        redirect_url = request.args.get('redirect_url')
        if redirect_url is None:
        	redirect_url = self.appbuilder.get_url_for_index

        #logging.debug("redirect_url: "+ redirect_url)

        if g.user is not None and g.user.is_authenticated and not g.user.is_anonymous:
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
                return self.appbuilder.sm.oauth_remotes[provider].authorize(callback=url_for('.oauth_authorized',provider=provider, _external=True, redirect_url=redirect_url))
            except Exception as e:
                logging.error("Error on OAuth authorize: {0}".format(e))
                flash(as_unicode(self.invalid_login_message), 'warning')
                return redirect(self.appbuilder.get_url_for_index)

    @expose('/oauth-authorized/<provider>')
    def oauth_authorized(self, provider):
        logging.debug("Authorized init")
        resp = self.appbuilder.sm.oauth_remotes[provider].authorized_response()
        redirect_url = request.args.get('redirect_url')
        if 'custom_api_token' in request.headers:
            resp = {'access_token': request.headers['custom_api_token']}
        if resp is None:
            flash(u'You denied the request to sign in.', 'warning')
            return redirect('login')
        logging.debug('OAUTH Authorized resp: {0}'.format(resp))
        # Retrieves specific user info from the provider
        try:
            self.appbuilder.sm.set_oauth_session(provider, resp)
            userinfo = self.appbuilder.sm.oauth_user_info(provider, resp)
        except Exception as e:
            logging.error("Error returning OAuth user info: {0}".format(e))
            user = None
        else:
            logging.debug("User info retrieved from {0}: {1}".format(provider, userinfo))
            # User email is not whitelisted
            if provider in self.appbuilder.sm.oauth_whitelists:
                whitelist = self.appbuilder.sm.oauth_whitelists[provider]
                allow = False
                for e in whitelist:
                    if re.search(e, userinfo['email']):
                        allow = True
                        break
                if not allow:
                    flash(u'You are not authorized.', 'warning')
                    return redirect('login')
            else:
                logging.debug('No whitelist for OAuth provider')
            user = self.appbuilder.sm.auth_user_oauth(userinfo)

        if user is None:
            flash(as_unicode(self.invalid_login_message), 'warning')
            return redirect('login')
        else:
            login_user(user)
            return redirect(redirect_url)

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
