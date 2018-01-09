#!/bin/bash

docker pull openlmis/$1
#the image might be built on the jenkins slave, so we need to pull here to make sure it's using the latest

sudo mkdir -p /var/www/html/erd-$1
sudo chown -R $USER:$USER /var/www/html/erd-$1

wget https://raw.githubusercontent.com/OpenLMIS/openlmis-config/master/.env -O .env \
&& wget https://raw.githubusercontent.com/OpenLMIS/openlmis-$1/master/docker-compose.erd-generation.yml -O docker-compose.erd-generation.yml \
&& (/usr/local/bin/docker-compose -f docker-compose.erd-generation.yml up &) \
&& sleep 90 \
&& sudo rm /var/www/html/erd-$1/* -rf \
&& mkdir output \
&& chmod 777 output \
&& (docker run --rm --network openlmis$1erdgeneration_default -v $WORKSPACE/output:/output schemaspy/schemaspy:snapshot -t pgsql -host db -port 5432 -db open_lmis -s $1 -u postgres -p $DBPASSWORD -I "(data_loaded)|(schema_version)|(jv_.*)" -norows -hq &) \
&& sleep 30 \
&& /usr/local/bin/docker-compose -f docker-compose.erd-generation.yml down --volumes \
&& sudo chown -R $USER:$USER output \
&& mv output/* /var/www/html/erd-$1 \
&& rm erd-$1.zip -f \
&& pushd /var/www/html/erd-$1 \
&& zip -r $WORKSPACE/erd-$1.zip . \
&& popd \
&& rmdir output \
&& rm .env \
&& rm docker-compose.erd-generation.yml