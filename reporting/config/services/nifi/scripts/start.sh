#!/bin/bash

/config/nifi/scripts/hideUsernameWithinNifi.sh $1 &

cp /config/nifi/libs/* lib/ &&
cp /config/nifi/conf/* conf &&
/config/nifi/scripts/download-toolkit.sh $1 &&
/config/nifi/scripts/preload.sh init $1 &&
cd /opt/nifi/nifi-$1 &&
../scripts/start.sh
