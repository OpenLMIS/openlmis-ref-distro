#!/bin/bash

cp /config/nifi/libs/* lib/ &&
/config/nifi/scripts/download-toolkit.sh $1 &&
/config/nifi/scripts/preload.sh init $1 &&
cd /opt/nifi/nifi-$1 &&
../scripts/start.sh
