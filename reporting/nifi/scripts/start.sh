#!/bin/bash

chown -R nifi:nifi /tmp/nifi-libs/* &&
chmod -R 0640 /tmp/nifi-libs/* &&
cp /tmp/nifi-libs/* lib/ &&
/tmp/nifi-scripts/download-toolkit.sh $1 &&
/tmp/nifi-scripts/preload.sh init $1 &&
cd /opt/nifi/nifi-$1 &&
../scripts/start.sh
