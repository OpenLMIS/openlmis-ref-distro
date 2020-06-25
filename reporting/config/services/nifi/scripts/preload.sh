#!/bin/bash

export NIFI_BASE_URL="http://nifi:8080"
export WORKING_DIR="/config/nifi/scripts"
export TEMPLATES_DIR="$WORKING_DIR/templates"
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
  echo "PRELOAD Waiting for NiFi to be available"
  local maxTries=$1
  local retryCount=1

  while ! curl -s -f "$NIFI_BASE_URL/nifi"; do
    sleep 10
    retryCount=$((retryCount + 1))
    if [[ "$retryCount" -gt "$maxTries" ]]; then
      echo "PRELOAD ERROR, too many retries waiting for NiFi to be available"
      return 1
    fi
  done

  return 0
}

initialize() {
  uploadAndImportTemplates "$@"
  restartFlows "$@"
}

uploadAndImportTemplates() {
  echo "PRELOAD Uploading and importing templates"
  local returnCode=0
  local templateCount=0

  for templateFile in ${TEMPLATES_DIR}/*.xml; do
    local filename=$(basename ${templateFile})
    if [ -e "${templateFile}" ]; then
      echo "PRELOAD Uploading template defined in ${templateFile}"
      templateId=$(curl -s $NIFI_BASE_URL/nifi-api/process-groups/root/templates/upload -F template=@${templateFile} | xmlstarlet sel -t -v '/templateEntity/template/id')
      #echo "PRELOAD templateId = ${templateId}"

      if [ ! "$templateId" == "" ]; then
        echo "PRELOAD Creating process group by importing template defined in ${templateFile}"
        local processGroupOffsetY=$((templateCount * 200 + 50))
        curl -s -X POST -H 'Content-Type: application/json' $NIFI_BASE_URL/nifi-api/process-groups/root/template-instance -d '{"templateId":"'"${templateId}"'","originX":400.0,"originY":"'"${processGroupOffsetY}"'"}' > /dev/null
        templateCount=$((templateCount + 1))
      else
        echo "PRELOAD ERROR Uploading template was not successful"
        returnCode=2
      fi
    fi
  done

  return $returnCode
}

restartFlows() {
  echo "PRELOAD Starting Flows"

  curl -s -X GET $NIFI_BASE_URL/nifi-api/process-groups/root/process-groups | jq '.[]|keys[]' | while read key ;
  do
    processorGroupId=$(curl -s -X GET $NIFI_BASE_URL/nifi-api/process-groups/root/process-groups | jq -r ".[][$key].component.id")
    # Get process group version number
    processGroupVersionNumber=$(curl -s -X GET -H 'Content-Type: application/json' $NIFI_BASE_URL/nifi-api/process-groups/${processorGroupId}/variable-registry | jq -r '.processGroupRevision.version')
    # Set the global variables
    curl --trace-ascii /dev/stdout -X PUT -H 'Content-Type: application/json' -d '{"processGroupRevision":{"version":"'"${processGroupVersionNumber}"'"},"variableRegistry":{"variables":[{"variable":{"name":"baseUrl","value":"'$OL_BASE_URL'","processGroupId":"'"${processorGroupId}"'"},"canWrite":true},{"variable":{"name":"username","value":"'$OL_ADMIN_USERNAME'","processGroupId":"'"${processorGroupId}"'"},"canWrite":true},{"variable":{"name":"password","value":"'$OL_ADMIN_PASSWORD'","processGroupId":"'"${processorGroupId}"'"},"canWrite":true}],"processGroupId":"'"${processorGroupId}"'"}}' $NIFI_BASE_URL/nifi-api/process-groups/${processorGroupId}/variable-registry

    # Enter sensitive values
    curl -s -X GET $NIFI_BASE_URL/nifi-api/flow/process-groups/${processorGroupId}/controller-services | jq '.controllerServices|keys[]' | while read key ;
    do
      controllerServiceId=$(curl -s -X GET $NIFI_BASE_URL/nifi-api/flow/process-groups/${processorGroupId}/controller-services | jq -r ".controllerServices[$key].component.id")
      controllerServiceName=$(curl -s -X GET $NIFI_BASE_URL/nifi-api/flow/process-groups/${processorGroupId}/controller-services | jq -r ".controllerServices[$key].component.name")

      if [ "$controllerServiceName" == "DBCPConnectionPool" ];
      then
        curl --trace-ascii /dev/stdout -X PUT -H 'Content-Type: application/json' -d '{"revision":{"clientId":"random", "version":"0"},"component":{"id":"'"${controllerServiceId}"'","properties":{"Password":"'"$POSTGRES_PASSWORD"'"}}}' $NIFI_BASE_URL/nifi-api/controller-services/${controllerServiceId}
      else
        continue
      fi
    done

    # Enable connector service
    curl -s -X GET $NIFI_BASE_URL/nifi-api/flow/process-groups/${processorGroupId}/controller-services | jq '.controllerServices|keys[]' | while read key ;
    do
      controllerServiceId=$(curl -s -X GET $NIFI_BASE_URL/nifi-api/flow/process-groups/${processorGroupId}/controller-services | jq -r ".controllerServices[$key].component.id")
      curl --trace-ascii /dev/stdout -X PUT -H 'Content-Type: application/json' -d '{"revision":{"clientId":"random", "version":"1"},"component":{"id":"'"${controllerServiceId}"'","state":"ENABLED"}}' $NIFI_BASE_URL/nifi-api/controller-services/${controllerServiceId}
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
            curl --trace-ascii /dev/stdout -X PUT -H 'Content-Type: application/json' -d '{"revision":{"clientId":"randomId","version":"'"${versionNumber}"'"},"component":{"id":"'"${invokeHttpId}"'","config":{"properties":{"Basic Authentication Username":"'"$AUTH_SERVER_CLIENT_ID"'","Basic Authentication Password":"'"$AUTH_SERVER_CLIENT_SECRET"'"}}}}}' $NIFI_BASE_URL/nifi-api/processors/${invokeHttpId}
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
            curl --trace-ascii /dev/stdout -X PUT -H 'Content-Type: application/json' -d '{"revision":{"clientId":"randomId","version":"'"${versionNumber}"'"},"component":{"id":"'"${invokeHttpId}"'","config":{"properties":{"Basic Authentication Username":"'"$FHIR_ID"'","Basic Authentication Password":"'"$FHIR_PASSWORD"'"}}}}}' $NIFI_BASE_URL/nifi-api/processors/${invokeHttpId}
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
            curl --trace-ascii /dev/stdout -X PUT -H 'Content-Type: application/json' -d '{"revision":{"clientId":"randomId","version":"'"${versionNumber}"'"},"component":{"id":"'"${invokeHttpId}"'","config":{"properties":{"Basic Authentication Username":"'"$FHIR_ID"'","Basic Authentication Password":"'"$FHIR_PASSWORD"'"}}}}}' $NIFI_BASE_URL/nifi-api/processors/${invokeHttpId}
            break
          fi
        done
      elif [ "$searchKey" == "Generate products and measure list" ];
      then
        curl -s -X GET $NIFI_BASE_URL/nifi-api/flow/process-groups/${processorGroupId}/controller-services | jq '.controllerServices|keys[]' | while read key ;
        do
          controllerServiceId=$(curl -s -X GET $NIFI_BASE_URL/nifi-api/flow/process-groups/${processorGroupId}/controller-services | jq -r ".controllerServices[$key].component.id")
          # Enable connector service
          curl --trace-ascii /dev/stdout -X PUT -H 'Content-Type: application/json' -d '{"revision":{"clientId":"random", "version":"0"},"component":{"id":"'"${controllerServiceId}"'","state":"ENABLED"}}' $NIFI_BASE_URL/nifi-api/controller-services/${controllerServiceId}
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
                curl --trace-ascii /dev/stdout -X PUT -H 'Content-Type: application/json' -d '{"revision":{"clientId":"randomId","version":"'"${versionNumber}"'"},"component":{"id":"'"${getAccessTokenId}"'","config":{"properties":{"Basic Authentication Username":"'"$AUTH_SERVER_CLIENT_ID"'","Basic Authentication Password":"'"$AUTH_SERVER_CLIENT_SECRET"'"}}}}}' $NIFI_BASE_URL/nifi-api/processors/${getAccessTokenId}
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

main "$@" &
exit $?
