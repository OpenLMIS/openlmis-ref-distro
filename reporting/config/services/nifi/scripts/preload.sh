#!/bin/bash

export NIFI_BASE_URL="http://nifi:8080"
export WORKING_DIR="/config/nifi/scripts/"
export REG_CLIENTS_DIR="$WORKING_DIR/preload/registries"
export IMPORTED_REG_CLIENTS_DIR="/tmp/nifi-preload/registries"
export PROC_GROUPS_DIR="$WORKING_DIR/preload/process-groups"
export IMPORTED_PROC_GROUPS_DIR="/tmp/nifi-preload/process-groups"
export NIFI_UP_RETRY_COUNT=240

: ${POSTGRES_PASSWORD:?"Need to set POSTGRES_PASSWORD"}
: ${AUTH_SERVER_CLIENT_ID:?"Need to set AUTH_SERVER_CLIENT_ID"}
: ${AUTH_SERVER_CLIENT_SECRET:?"Need to set AUTH_SERVER_CLIENT_SECRET"}
: ${TRUSTED_HOSTNAME:?"Need to set TRUSTED_HOSTNAME"}
: ${OL_ADMIN_USERNAME:?"Need to set OL_ADMIN_USERNAME"}
: ${OL_ADMIN_PASSWORD:?"Need to set OL_ADMIN_PASSWORD"}
: ${OL_BASE_URL:?"Need to set OL_BASE_URL"}

main() {
  if waitNifiAvailable ${NIFI_UP_RETRY_COUNT}; then
    local subCommand=$1

    if [ "$subCommand" == "init" ]; then
      initialize "${@:2}"
    else
      return 1
    fi
  else
    return 1
  fi

  return $?
}

waitNifiAvailable() {
  echo "Waiting for NiFi to be available"
  local maxTries=$1
  local retryCount=1

  while ! curl -f "$NIFI_BASE_URL/nifi"; do
    sleep 10
    retryCount=$((retryCount + 1))
    if [[ "$retryCount" -gt "$maxTries" ]]; then
      return 1
    fi
  done

  return 0
}

initialize() {
  createRegClients "$@"
  importProcessGroups "$@"
  restartFlows "$@"
}

createRegClients() {
  echo "Importing the Registry Clients"
  local nifiVersion=$1
  local cliPath=$(getCliPath "$nifiVersion")
  local returnCode=0

  mkdir -p $IMPORTED_REG_CLIENTS_DIR
  for propFile in $REG_CLIENTS_DIR/*.properties; do
    local filename=$(basename $propFile)
    if [ -e "$propFile" ] && [ ! -e "$IMPORTED_REG_CLIENTS_DIR/$filename" ]; then
      echo "Importing registry client defined in $IMPORTED_REG_CLIENTS_DIR/$filename"
      ${cliPath} nifi create-reg-client -u "${NIFI_BASE_URL}" -p $propFile

      if [ $? -eq 0 ]; then
        ln -s $propFile $IMPORTED_REG_CLIENTS_DIR/$filename
      else
        returnCode=2
      fi
    fi
  done

  return $returnCode
}

importProcessGroups() {
  echo "Importing the Process Groups"
  local nifiVersion=$1
  local cliPath=$(getCliPath "$nifiVersion")
  local returnCode=0

  # Get the list of registries and their IDs from NiFi
  local listCmdOutput=$(${cliPath} nifi list-reg-clients -u "${NIFI_BASE_URL}" | sed '1,3d')

  if [ $? -eq 0 ]; then
    # Use sed (with a regex) to extract the registry client names and IDs
    # Example text for regex:
    #
    #      1   Some Registry Name   13f84457-0165-1000-23cc-300c3ad387bb   http://some.name:18080
    #          (capture group 1)               (capture group 2)
    #
    local registryNames=($(echo "$listCmdOutput" | sed -r -E "s/^[0-9]+\s+(.*)\s+([0-9a-zA-Z\-]+)\s+.*$/\1/g"))
    local registryIds=($(echo "$listCmdOutput" | sed -r -E "s/^[0-9]+\s+(.*)\s+([0-9a-zA-Z\-]+)\s+.*$/\2/g"))
    curRegistryIndex=0
    while [ ${curRegistryIndex} -lt ${#registryIds[@]} ]; do
      local registryName="${registryNames[${curRegistryIndex}]}"
      local registryId="${registryIds[${curRegistryIndex}]}"
      curRegistryIndex=$[$curRegistryIndex+1]

      if [ -d ${PROC_GROUPS_DIR}/${registryName} ] && [ ! -z "$registryName" ] && [ ! -z "$registryId" ]; then
        mkdir -p ${IMPORTED_PROC_GROUPS_DIR}/${registryName}

        for propFile in ${PROC_GROUPS_DIR}/${registryName}/*.properties; do
          local filename=$(basename ${propFile})
          if [ -e "${propFile}" ] && [ ! -e "${IMPORTED_PROC_GROUPS_DIR}/${registryName}/${filename}" ]; then
            echo "Importing process group defined in ${IMPORTED_PROC_GROUPS_DIR}/${registryName}/${filename}"
            ${cliPath} nifi pg-import -u "${NIFI_BASE_URL}" -rcid ${registryId} -p ${propFile}

            if [ $? -eq 0 ]; then
              ln -s $propFile ${IMPORTED_PROC_GROUPS_DIR}/${registryName}/${filename}
            else
              returnCode=2
            fi
          fi
        done
      fi
    done
  else
    returnCode=1
  fi

  return $returnCode
}

restartFlows() {
  echo "Starting Flows"
  
  curl -s -X GET $NIFI_BASE_URL/nifi-api/process-groups/root/process-groups | jq '.[]|keys[]' | while read key ; 
  do
    processorGroupId=$(curl -s -X GET $NIFI_BASE_URL/nifi-api/process-groups/root/process-groups | jq -r ".[][$key].component.id")
    # Get process group version number
    processGroupVersionNumber=$(curl -s -X GET -H 'Content-Type: application/json' $NIFI_BASE_URL/nifi-api/process-groups/${processorGroupId}/variable-registry | jq -r '.processGroupRevision.version')
    # Set the global variables
    curl -X PUT -H 'Content-Type: application/json' $NIFI_BASE_URL/nifi-api/process-groups/${processorGroupId}/variable-registry -d '{"processGroupRevision":{"version":"'"${processGroupVersionNumber}"'"},"variableRegistry":{"variables":[{"variable":{"name":"baseUrl","value":"'$OL_BASE_URL'","processGroupId":"'"${processorGroupId}"'"},"canWrite":true},{"variable":{"name":"username","value":"'$OL_ADMIN_USERNAME'","processGroupId":"'"${processorGroupId}"'"},"canWrite":true},{"variable":{"name":"password","value":"'$OL_ADMIN_PASSWORD'","processGroupId":"'"${processorGroupId}"'"},"canWrite":true}],"processGroupId":"'"${processorGroupId}"'"}}'

    # Enter sensitive values
    curl -s -X GET $NIFI_BASE_URL/nifi-api/flow/process-groups/${processorGroupId}/controller-services | jq '.controllerServices|keys[]' | while read key ;
    do
      controllerServiceId=$(curl -s -X GET $NIFI_BASE_URL/nifi-api/flow/process-groups/${processorGroupId}/controller-services | jq -r ".controllerServices[$key].component.id")
      controllerServiceName=$(curl -s -X GET $NIFI_BASE_URL/nifi-api/flow/process-groups/${processorGroupId}/controller-services | jq -r ".controllerServices[$key].component.name")

      if [ "$controllerServiceName" == "DBCPConnectionPool" ];
      then
        curl -i -X PUT -H 'Content-Type: application/json' -d '{"revision":{"clientId":"random", "version":"0"},"component":{"id":"'"${controllerServiceId}"'","properties":{"Password":"'"$POSTGRES_PASSWORD"'"}}}' $NIFI_BASE_URL/nifi-api/controller-services/${controllerServiceId}
      else
        continue
      fi
    done

    # Enable connector service
    curl -s -X GET $NIFI_BASE_URL/nifi-api/flow/process-groups/${processorGroupId}/controller-services | jq '.controllerServices|keys[]' | while read key ;
    do
      controllerServiceId=$(curl -s -X GET $NIFI_BASE_URL/nifi-api/flow/process-groups/${processorGroupId}/controller-services | jq -r ".controllerServices[$key].component.id")
      curl -i -X PUT -H 'Content-Type: application/json' -d '{"revision":{"clientId":"random", "version":"1"},"component":{"id":"'"${controllerServiceId}"'","state":"ENABLED"}}' $NIFI_BASE_URL/nifi-api/controller-services/${controllerServiceId}
    done

    # find invokehttp processors and update password
    curl -s -X GET $NIFI_BASE_URL/nifi-api/process-groups/${processorGroupId}/process-groups | jq '.[]|keys[]' | while read key ;
    do
      searchKey=$(curl -s -X GET $NIFI_BASE_URL/nifi-api/process-groups/${processorGroupId}/process-groups | jq -r ".processGroups[$key].component.name")
      if [ "$searchKey" == "Create Token" ] || [ "$searchKey" == "Create token" ];
      then
        createTokenId=$(curl -s -X GET $NIFI_BASE_URL/nifi-api/process-groups/${processorGroupId}/process-groups | jq -r ".processGroups[$key].component.id")
        curl -s -X GET $NIFI_BASE_URL/nifi-api/process-groups/${createTokenId}/processors | jq '.[]|keys[]' | while read key ;
        do
          processorName=$(curl -s -X GET $NIFI_BASE_URL/nifi-api/process-groups/${createTokenId}/processors | jq -r ".processors[$key].component.name")
          if [ "$processorName" == "Get Access token" ] ;
          then
            invokeHttpId=$(curl -s -X GET $NIFI_BASE_URL/nifi-api/process-groups/${createTokenId}/processors | jq -r ".processors[$key].component.id")
            versionNumber=$(curl -s -X GET $NIFI_BASE_URL/nifi-api/processors/${invokeHttpId} | jq -r ".revision.version")
            curl -i -X PUT -H 'Content-Type: application/json' -d '{"revision":{"clientId":"randomId","version":"'"${versionNumber}"'"},"component":{"id":"'"${invokeHttpId}"'","config":{"properties":{"Basic Authentication Username":"'"$AUTH_SERVER_CLIENT_ID"'","Basic Authentication Password":"'"$AUTH_SERVER_CLIENT_SECRET"'"}}}}}' $NIFI_BASE_URL/nifi-api/processors/${invokeHttpId}
            break  
          fi
        done
      elif [ "$searchKey" == "Get Measures" ];
      then
        checkMeasureId=$(curl -s -X GET $NIFI_BASE_URL/nifi-api/process-groups/${processorGroupId}/process-groups | jq -r ".processGroups[$key].component.id")
        curl -s -X GET $NIFI_BASE_URL/nifi-api/process-groups/${checkMeasureId}/processors | jq '.[]|keys[]' | while read key ;
        do
          processorName=$(curl -s -X GET $NIFI_BASE_URL/nifi-api/process-groups/${checkMeasureId}/processors | jq -r ".processors[$key].component.name")
          if [ "$processorName" == "Invoke FHIR token" ] ;
          then
            invokeHttpId=$(curl -s -X GET $NIFI_BASE_URL/nifi-api/process-groups/${checkMeasureId}/processors | jq -r ".processors[$key].component.id")
            versionNumber=$(curl -s -X GET $NIFI_BASE_URL/nifi-api/processors/${invokeHttpId} | jq -r ".revision.version")
            curl -i -X PUT -H 'Content-Type: application/json' -d '{"revision":{"clientId":"randomId","version":"'"${versionNumber}"'"},"component":{"id":"'"${invokeHttpId}"'","config":{"properties":{"Basic Authentication Username":"'"$FHIR_ID"'","Basic Authentication Password":"'"$FHIR_PASSWORD"'"}}}}}' $NIFI_BASE_URL/nifi-api/processors/${invokeHttpId}
            break
          fi
        done
      elif [ "$searchKey" == "Check MeasureReports" ];
      then
        checkMeasureId=$(curl -s -X GET $NIFI_BASE_URL/nifi-api/process-groups/${processorGroupId}/process-groups | jq -r ".processGroups[$key].component.id")
        curl -s -X GET $NIFI_BASE_URL/nifi-api/process-groups/${checkMeasureId}/processors | jq '.[]|keys[]' | while read key ;
        do
          processorName=$(curl -s -X GET $NIFI_BASE_URL/nifi-api/process-groups/${checkMeasureId}/processors | jq -r ".processors[$key].component.name")
          if [ "$processorName" == "Invoke FHIR token" ] ;
          then
            invokeHttpId=$(curl -s -X GET $NIFI_BASE_URL/nifi-api/process-groups/${checkMeasureId}/processors | jq -r ".processors[$key].component.id")
            versionNumber=$(curl -s -X GET $NIFI_BASE_URL/nifi-api/processors/${invokeHttpId} | jq -r ".revision.version")
            curl -i -X PUT -H 'Content-Type: application/json' -d '{"revision":{"clientId":"randomId","version":"'"${versionNumber}"'"},"component":{"id":"'"${invokeHttpId}"'","config":{"properties":{"Basic Authentication Username":"'"$FHIR_ID"'","Basic Authentication Password":"'"$FHIR_PASSWORD"'"}}}}}' $NIFI_BASE_URL/nifi-api/processors/${invokeHttpId}
            break  
          fi
        done
      elif [ "$searchKey" == "Generate products and measure list" ];
      then
        curl -s -X GET $NIFI_BASE_URL/nifi-api/flow/process-groups/${processorGroupId}/controller-services | jq '.controllerServices|keys[]' | while read key ;
        do
          controllerServiceId=$(curl -s -X GET $NIFI_BASE_URL/nifi-api/flow/process-groups/${processorGroupId}/controller-services | jq -r ".controllerServices[$key].component.id")
          # Enable connector service
          curl -i -X PUT -H 'Content-Type: application/json' -d '{"revision":{"clientId":"random", "version":"0"},"component":{"id":"'"${controllerServiceId}"'","state":"ENABLED"}}' $NIFI_BASE_URL/nifi-api/controller-services/${controllerServiceId}
        done

        generateProductMeasuresId=$(curl -s -X GET $NIFI_BASE_URL/nifi-api/process-groups/${processorGroupId}/process-groups | jq -r ".processGroups[$key].component.id")
        curl -s -X GET $NIFI_BASE_URL/nifi-api/process-groups/${generateProductMeasuresId}/process-groups | jq '.[]|keys[]' | while read key ;
        do
          searchKey=$(curl -s -X GET $NIFI_BASE_URL/nifi-api/process-groups/${generateProductMeasuresId}/process-groups | jq -r ".processGroups[$key].component.name")
          if [ "$searchKey" == "Get products" ];
          then
            getProductsId=$(curl -s -X GET $NIFI_BASE_URL/nifi-api/process-groups/${generateProductMeasuresId}/process-groups | jq -r ".processGroups[$key].component.id")
            curl -s -X GET $NIFI_BASE_URL/nifi-api/process-groups/${getProductsId}/processors | jq '.[]|keys[]' | while read key ;
            do
              processorName=$(curl -s -X GET $NIFI_BASE_URL/nifi-api/process-groups/${getProductsId}/processors | jq -r ".processors[$key].component.name")
              if [ "$processorName" == "Get access token" ] ;
              then
                getAccessTokenId=$(curl -s -X GET $NIFI_BASE_URL/nifi-api/process-groups/${getProductsId}/processors | jq -r ".processors[$key].component.id")
                versionNumber=$(curl -s -X GET $NIFI_BASE_URL/nifi-api/processors/${getAccessTokenId} | jq -r ".revision.version")
                curl -i -X PUT -H 'Content-Type: application/json' -d '{"revision":{"clientId":"randomId","version":"'"${versionNumber}"'"},"component":{"id":"'"${getAccessTokenId}"'","config":{"properties":{"Basic Authentication Username":"'"$AUTH_SERVER_CLIENT_ID"'","Basic Authentication Password":"'"$AUTH_SERVER_CLIENT_SECRET"'"}}}}}' $NIFI_BASE_URL/nifi-api/processors/${getAccessTokenId}
                break
              fi
            done
          fi
        done
      else
        continue
      fi
    done

    # Restart flows
    sleep 5 # necessary to ensure all changes have taken effect

    # Start all processor groups except 'materialized view' process group. 
    # Save its id for reference to start it after 3 mins when data has been loaded into the table
    processorGroupName=$(curl -s -X GET $NIFI_BASE_URL/nifi-api/process-groups/root/process-groups | jq -r ".[][$key].component.name")
    if [ "$processorGroupName" == "Materialized Views" ];
    then
      echo ${processorGroupId} > tempFileforMatViewId.txt
    else
      curl -s -X PUT -H 'Content-Type: application/json' -d '{"id":"'"${processorGroupId}"'","state":"RUNNING"}' $NIFI_BASE_URL/nifi-api/flow/process-groups/${processorGroupId}
    fi
  done

  sleep 180
  materializedViewProcessorGroupId=$(<tempFileforMatViewId.txt)
  echo ${materializedViewProcessorGroupId}
  curl -s -X PUT -H 'Content-Type: application/json' -d '{"id":"'"${materializedViewProcessorGroupId}"'","state":"RUNNING"}' $NIFI_BASE_URL/nifi-api/flow/process-groups/${materializedViewProcessorGroupId}
  rm tempFileforMatViewId.txt
}

getCliPath() {
  local nifiVersion=$1
  echo "/tmp/nifi-toolkit-${nifiVersion}/bin/cli.sh"
}

main "$@" &
exit $?
