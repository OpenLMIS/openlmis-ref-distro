#!/bin/bash

export NIFI_BASE_URL="http://nifi:8080"
export WORKING_DIR="/config/nifi/scripts/"
export REG_CLIENTS_DIR="$WORKING_DIR/preload/registries"
export IMPORTED_REG_CLIENTS_DIR="/tmp/nifi-preload/registries"
export PROC_GROUPS_DIR="$WORKING_DIR/preload/process-groups"
export IMPORTED_PROC_GROUPS_DIR="/tmp/nifi-preload/process-groups"
export NIFI_UP_RETRY_COUNT=240

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

getCliPath() {
  local nifiVersion=$1
  echo "/tmp/nifi-toolkit-${nifiVersion}/bin/cli.sh"
}

main "$@" &
exit $?
