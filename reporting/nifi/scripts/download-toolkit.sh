#!/bin/bash
export NIFI_TOOLKIT_DOWNLOAD_MAX_RETRIES=3

downloadNifiToolkit() {
  local nifiVersion=$1
  local retryCount=$2
  local downloadDir=/tmp/nifi-scripts/cache
  local archivePath=${downloadDir}/nifi-toolkit-${nifiVersion}.tar.gz

  if [ "$retryCount" -gt "$NIFI_TOOLKIT_DOWNLOAD_MAX_RETRIES" ]; then
    echo "Failed to download NiFi Toolkit $NIFI_TOOLKIT_DOWNLOAD_MAX_RETRIES times. Exiting!"
    return 2
  fi

  mkdir -p ${downloadDir}
  if ! [[ -e $archivePath ]]; then
    echo "Downloading the NiFi Toolkit archive (${retryCount})."
    curl -f -o $archivePath http://archive.apache.org/dist/nifi/${nifiVersion}/nifi-toolkit-${nifiVersion}-bin.tar.gz
    if [ $? -ne 0 ]; then
      return 1
    fi
  fi

  extractNifiToolkit "$nifiVersion" "$archivePath" "$retryCount"
  
  return $?
}

extractNifiToolkit() {
  local nifiVersion=$1
  local archivePath=$2
  local retryCount=$3
  local destDir=/tmp
  echo "Extracting the NiFi Toolkit archive to $destDir/nifi-toolkit-$nifiVersion."
  rm -rf $destDir/nifi-toolkit-$nifiVersion
  tar -xf $archivePath -C $destDir

  if [ $? -ne 0 ]; then
    rm $archivePath
    echo "Could not extract NiFi Toolkit. Restarting the download."
    retryCount=$((retryCount + 1))
    downloadNifiToolkit "$nifiVersion" "$retryCount"

    return $?
  fi

  return 0
}

downloadNifiToolkit "$1" 0
exit $?
