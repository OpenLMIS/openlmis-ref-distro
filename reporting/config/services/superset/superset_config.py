"""
Superset config
"""
import os

from flask_appbuilder.const import AUTH_OAUTH, AUTH_DB

# What is `ona_config`, you ask?
# It is a module that we create to hold code that makes it possible to make
# this module (superset_config.py) configurable.  As you can see we are doing
# an absolute import to get it - this is because for some reason relative
# imports just will not work.  The name `ona_config` was chosen in hopes that
# it is a unique enough name that will not conflict with anything else already
# on the Python path / Python module registry.
from ona_config.oauth import PROVIDERS, CustomSecurityManager
from ona_config.utils import get_complex_env_var


SQLALCHEMY_DATABASE_URI = os.getenv(
    "SUPERSET_SQLALCHEMY_DATABASE_URI",
    "postgresql+psycopg2://superset:superset123@db:5432/superset",
)

SQLALCHEMY_TRACK_MODIFICATIONS = get_complex_env_var(
    "SUPERSET_SQLALCHEMY_TRACK_MODIFICATIONS", True)

SECRET_KEY = os.getenv("SUPERSET_SECRET_KEY", "thisISaSECRET_1234")

# Get the Auth type
SUPERSET_AUTH_TYPE = os.getenv("SUPERSET_AUTH_TYPE", "AUTH_DB")
if SUPERSET_AUTH_TYPE == 'AUTH_OAUTH':
    AUTH_TYPE = AUTH_OAUTH
else:
    AUTH_TYPE = AUTH_DB

# Get the Oauth Providers
selected_oauth_providers = get_complex_env_var("SUPERSET_OAUTH_PROVIDERS", [])
if selected_oauth_providers:
    OAUTH_PROVIDERS = [PROVIDERS[_] for _ in selected_oauth_providers]
    CUSTOM_SECURITY_MANAGER = CustomSecurityManager

# The default user self registration role
AUTH_USER_REGISTRATION_ROLE = os.getenv(
    "SUPERSET_AUTH_USER_REGISTRATION_ROLE", "Public"
)

# Will allow user self registration
AUTH_USER_REGISTRATION = get_complex_env_var(
    "SUPERSET_AUTH_USER_REGISTRATION", True)

# Extract and use X-Forwarded-For/X-Forwarded-Proto headers?
ENABLE_PROXY_FIX = get_complex_env_var("SUPERSET_ENABLE_PROXY_FIX", True)

# Allow iFrame access from openLMIS running on localhost
HTTP_HEADERS = get_complex_env_var(
    "SUPERSET_HTTP_HEADERS",
    {"X-Frame-Options": "allow-from https://uat.openlmis.org"})

# CSV Options: key/value pairs that will be passed as argument to
# DataFrame.to_csv method
# note: index option should not be overridden
CSV_EXPORT = get_complex_env_var("SUPERSET_CSV_EXPORT", {"encoding": "utf-8"})
