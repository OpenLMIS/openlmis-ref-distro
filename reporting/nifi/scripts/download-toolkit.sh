#!/bin/bash

downloadNifiToolkit() {
  local nifiVersion=$1
  local downloadDir=/tmp/nifi-scripts/cache
  local archivePath=${downloadDir}/nifi-toolkit-${nifiVersion}.tar.gz
  mkdir -p ${downloadDir}
  if ! [[ -e $archivePath ]]; then
    echo "Downloading the NiFi Toolkit archive"
    curl -f -o $archivePath http://archive.apache.org/dist/nifi/${nifiVersion}/nifi-toolkit-${nifiVersion}-bin.tar.gz
    if [ $? -ne 0 ]; then
      return 1
    fi
  fi

  extractNifiToolkit "$nifiVersion" "$archivePath"
  
  return $?
}

extractNifiToolkit() {
  local nifiVersion=$1
  local archivePath=$2
  local destDir=/tmp
  echo "Extracting the NiFi Toolkit archive to $destDir/nifi-toolkit-$nifiVersion"
  rm -rf $destDir/nifi-toolkit-$nifiVersion
  tar -xf $archivePath -C $destDir

  return $?
}

downloadNifiToolkit "$1"
exit $?
