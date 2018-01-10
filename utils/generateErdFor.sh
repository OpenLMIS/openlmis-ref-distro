#!/bin/bash

docker pull openlmis/$1
#the image might be built on the jenkins slave, so we need to pull here to make sure it's using the latest

# prepare ERD folder on CI server
sudo mkdir -p /var/www/html/erd-$1
sudo chown -R $USER:$USER /var/www/html/erd-$1

# General steps:
# - Copy env file and remove demo data profiles (errors happen during startup when they are enabled)
# - Copy ERD generation docker-compose file and bring up service with db container and wait
# - Clean out existing ERD folder
# - Create output folder (SchemaSpy uses it to hold ERD files) and make sure it is writable by docker
# - Use SchemaSpy docker image to generate ERD files and send to output, wait
# - Bring down service and db container
# - Make sure output folder and its subfolders is owned by user (docker generated files/folders are owned by docker)
# - Move output to web folder
# - Clean out old zip file and re-generate it
# - Clean up files and folders
wget https://raw.githubusercontent.com/OpenLMIS/openlmis-ref-distro/master/settings-sample.env -O .env \
&& sed -i -e "s/^spring_profiles_active=demo-data,refresh-db/spring_profiles_active=/" .env \
&& wget https://raw.githubusercontent.com/OpenLMIS/openlmis-ref-distro/master/docker-compose.erd-generation.yml -O docker-compose.yml \
&& export OL_SERVICE_NAME=$1 \
&& (/usr/local/bin/docker-compose up &) \
&& sleep 90 \
&& sudo rm /var/www/html/erd-$1/* -rf \
&& mkdir output \
&& chmod 777 output \
&& (docker run --rm --network openlmis$1erdgeneration_default -v $WORKSPACE/output:/output schemaspy/schemaspy:snapshot -t pgsql -host db -port 5432 -db open_lmis -s $1 -u postgres -p $DBPASSWORD -I "(data_loaded)|(schema_version)|(jv_.*)" -norows -hq &) \
&& sleep 30 \
&& /usr/local/bin/docker-compose down --volumes \
&& sudo chown -R $USER:$USER output \
&& mv output/* /var/www/html/erd-$1 \
&& rm erd-$1.zip -f \
&& pushd /var/www/html/erd-$1 \
&& zip -r $WORKSPACE/erd-$1.zip . \
&& popd \
&& rmdir output \
&& rm .env \
&& rm docker-compose.yml