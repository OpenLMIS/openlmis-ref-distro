#!/bin/bash

: ${RENEWAL_CHECK_PERIOD:?"Need to set RENEWAL_CHECK_PERIOD"}

while true; do echo "$(date -Iseconds) Certificates reloading with certbot..." && certbot renew; sleep $RENEWAL_CHECK_PERIOD; done;
