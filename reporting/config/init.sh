#!/bin/sh

echo "Waiting for consul to be available"
while ! curl -f "http://consul:8500/v1/agent/self"; do
    sleep 10;
done

set -e

curl \
  -X PUT \
  -H "Content-Type: application/json" \
  --data "{\"name\": \"superset-service\", \"address\": \"superset\", \"id\": \"superset1\", \"port\": 8088, \"tags\": [\"openlmis-service\"], \"check\": { \"http\": \"http://superset:8088/health\", \"method\": \"GET\", \"interval\": \"30s\", \"timeout\": \"10s\"}}" \
  http://consul:8500/v1/agent/service/register

curl \
  -X PUT \
  --data "{ \"upstream\": \"superset-service\", \"enable_basic_auth\": false, \"behind_load_balancer\": ${SUPERSET_BEHIND_LOAD_BALANCER}, \"redirect_http_traffic\": ${SUPERSET_LOAD_BALANCER_REDIRECT_HTTP}, \"enable_ssl\": ${SUPERSET_ENABLE_SSL}, \"ssl_cert\": \"/config/nginx/tls/${SUPERSET_SSL_CERT}\", \"ssl_key\": \"/config/nginx/tls/${SUPERSET_SSL_KEY}\", \"ssl_cert_chain\": \"/config/nginx/tls/${SUPERSET_SSL_CERT_CHAIN}\"}" \
  http://consul:8500/v1/kv/resources/${SUPERSET_DOMAIN_NAME}

curl \
  -X PUT \
  -H "Content-Type: application/json" \
  --data "{\"name\": \"nifi-service\", \"address\": \"nifi\", \"id\": \"nifi1\", \"port\": 8080, \"tags\": [\"openlmis-service\"], \"check\": { \"http\": \"http://nifi:8080\", \"method\": \"GET\", \"interval\": \"30s\", \"timeout\": \"10s\"}}" \
  http://consul:8500/v1/agent/service/register

curl \
  -X PUT \
  --data "{ \"upstream\": \"nifi-service\", \"enable_basic_auth\": true, \"behind_load_balancer\": ${NIFI_BEHIND_LOAD_BALANCER}, \"redirect_http_traffic\": ${NIFI_LOAD_BALANCER_REDIRECT_HTTP}, \"enable_ssl\": ${NIFI_ENABLE_SSL}, \"ssl_cert\": \"/config/nginx/tls/${NIFI_SSL_CERT}\", \"ssl_key\": \"/config/nginx/tls/${NIFI_SSL_KEY}\", \"ssl_cert_chain\": \"/config/nginx/tls/${NIFI_SSL_CERT_CHAIN}\"}" \
  http://consul:8500/v1/kv/resources/${NIFI_DOMAIN_NAME}
