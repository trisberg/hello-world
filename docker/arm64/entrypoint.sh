#!/bin/bash

CRAC_FILES_DIR=`eval echo ${CRAC_FILES_DIR}`
mkdir -p ${CRAC_FILES_DIR}

cd /home/app
if [ -z "$(ls -A $CRAC_FILES_DIR)" ]; then
  echo "Save checkpoint to $CRAC_FILES_DIR"
  ( echo 128 > /proc/sys/kernel/ns_last_pid ) 2>/dev/null || while [ $(cat /proc/sys/kernel/ns_last_pid) -lt 128 ]; do :; done
  java -Dmanagement.endpoint.health.probes.add-additional-paths="true" -Dmanagement.health.probes.enabled="true" -XX:CRaCCheckpointTo=$CRAC_FILES_DIR org.springframework.boot.loader.JarLauncher &
  PID=$!
  sleep 10
  jcmd $PID JDK.checkpoint
  sleep 5
else
  echo "Restore checkpoint from $CRAC_FILES_DIR"
fi
exec java -Dmanagement.endpoint.health.probes.add-additional-paths="true" -Dmanagement.health.probes.enabled="true" -XX:CRaCRestoreFrom=$CRAC_FILES_DIR
