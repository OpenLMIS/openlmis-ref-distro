#!/bin/bash

: ${NGINX_BASIC_AUTH_USER:?"Need to set NGINX_BASIC_AUTH_USER"}
: ${NGINX_BASIC_AUTH_PW:?"Need to set NGINX_BASIC_AUTH_PW"}

echo -n "$NGINX_BASIC_AUTH_USER:" >> /etc/nginx/.htpasswd && 
openssl passwd -apr1 $NGINX_BASIC_AUTH_PW >> /etc/nginx/.htpasswd
