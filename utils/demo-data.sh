#!/bin/bash

UPDATE=false
OPENLMIS_HOME=$HOME/OpenLMIS

for arg in "$@"; do
  shift
  case "$arg" in
    "--update") 
    	UPDATE=true ;;
    "-u")	
	UPDATE=true ;;
  esac
done

if [ "$UPDATE" = true ] ; then
   git -c $OPENLMIS_HOME/openlmis-referencedata pull
   git -c $OPENLMIS_HOME/openlmis-requisition pull
   git -c $OPENLMIS_HOME/openlmis-auth pull

   sudo docker-compose -f $OPENLMIS_HOME/openlmis-referencedata/docker-compose.builder.yml run demo-data
   sudo docker-compose -f $OPENLMIS_HOME/openlmis-requisition/docker-compose.builder.yml run demo-data
   sudo docker-compose -f $OPENLMIS_HOME/openlmis-auth/docker-compose.builder.yml run demo-data
fi

sudo docker exec -i openlmisblue_db_1 psql -Upostgres open_lmis < $OPENLMIS_HOME/openlmis-referencedata/demo-data/input.sql
sudo docker exec -i openlmisblue_db_1 psql -Upostgres open_lmis < $OPENLMIS_HOME/openlmis-auth/demo-data/input.sql
sudo docker exec -i openlmisblue_db_1 psql -Upostgres open_lmis < $OPENLMIS_HOME/openlmis-requisition/demo-data/input.sql
