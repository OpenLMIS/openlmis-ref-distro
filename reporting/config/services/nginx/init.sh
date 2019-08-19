#!/bin/sh

set -e

openssl dhparam -dsaparam -out /etc/ssl/certs/dhparam.pem 4096

cp -r /config/nginx/consul-template/* /etc/consul-template/

echo -n "${NGINX_BASIC_AUTH_USER}:" >> /etc/nginx/.htpasswd
openssl passwd -apr1 ${NGINX_BASIC_AUTH_PW} >> /etc/nginx/.htpasswd

echo "Waiting for consul to be available"
sleep 240;

/home/run.sh