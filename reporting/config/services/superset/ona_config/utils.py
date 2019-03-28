"""
Utilities
"""
import ast
import os

from flask import request
from future.standard_library import hooks

# python 3 and python 2 compatible way of importing urllib
with hooks():
    from urllib.parse import urlparse, urljoin


def get_complex_env_var(env_var, default):
    """
    Gets the value of a "complex" environment variable

    we would like to support complex env vars such as Python dictionaries
    and we use `ast.literal_eval` to "parse" them.  They are a bit .. involving
    because we cannot naively rely on the default option on `os.getenv`
    """
    # we aren't using the default option of os.getenv so that we can be able to
    # later on use ast.literal_eval (it won't work on non-strings)
    the_var = os.getenv(env_var)
    if the_var:
        try:
            return ast.literal_eval(the_var)
        except ValueError:
            # in this case we didn't get a value that ast.literal_eval could
            # handle.  This could be any non-string value e.g. None
            pass
    return default


def is_safe_url(target_url):
    """
    Check if the target_url is safe to redirect to

    See http://flask.pocoo.org/snippets/62/ for an example.
    """
    ref_url = urlparse(request.host_url)
    test_url = urlparse(urljoin(request.host_url, target_url))
    return test_url.scheme in (
        "http", "https") and ref_url.netloc == test_url.netloc
