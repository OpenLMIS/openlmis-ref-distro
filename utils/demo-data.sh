#!/bin/bash

UPDATE=false
OPENLMIS_HOME=${OPENLMIS_HOME:-$HOME/OpenLMIS}

for arg in "$@"; do
  shift
  case "$arg" in
    "--update") 
        UPDATE=true ;;
    "-u")	
        UPDATE=true ;;
    "--home")
        OPENLMIS_HOME=`readlink -f $@` ;;
    "-h")
        OPENLMIS_HOME=`readlink -f $@` ;;
  esac
done

if [ "$UPDATE" = true ] ; then
   cd $OPENLMIS_HOME/openlmis-referencedata
   git pull
   cd $OPENLMIS_HOME/openlmis-requisition
   git pull
   cd $OPENLMIS_HOME/openlmis-fulfillment
   git pull
   cd $OPENLMIS_HOME/openlmis-auth
   git pull

   sudo docker-compose -f $OPENLMIS_HOME/openlmis-referencedata/docker-compose.builder.yml run demo-data
   sudo docker-compose -f $OPENLMIS_HOME/openlmis-requisition/docker-compose.builder.yml run demo-data
   sudo docker-compose -f $OPENLMIS_HOME/openlmis-fulfillment/docker-compose.builder.yml run demo-data
   sudo docker-compose -f $OPENLMIS_HOME/openlmis-auth/docker-compose.builder.yml run demo-data
fi

sudo docker exec -i openlmisrefdistro_db_1 psql -Upostgres open_lmis < $OPENLMIS_HOME/openlmis-referencedata/build/demo-data/data.sql
sudo docker exec -i openlmisrefdistro_db_1 psql -Upostgres open_lmis < $OPENLMIS_HOME/openlmis-auth/build/demo-data/data.sql
sudo docker exec -i openlmisrefdistro_db_1 psql -Upostgres open_lmis < $OPENLMIS_HOME/openlmis-requisition/build/demo-data/data.sql
sudo docker exec -i openlmisrefdistro_db_1 psql -Upostgres open_lmis < $OPENLMIS_HOME/openlmis-fulfillment/build/demo-data/data.sql
