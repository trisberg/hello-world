#!/bin/bash

CRAC_FILES_DIR=`eval echo ${CRAC_FILES_DIR}`
mkdir -p ${CRAC_FILES_DIR}

cd /home/app
if [ -z "$(ls -A $CRAC_FILES_DIR)" ]; then
  echo 128 > /proc/sys/kernel/ns_last_pid; java -Dmanagement.endpoint.health.probes.add-additional-paths="true" -Dmanagement.health.probes.enabled="true" -XX:CRaCCheckpointTo=$CRAC_FILES_DIR org.springframework.boot.loader.JarLauncher &
  sleep 10
  jcmd org.springframework.boot.loader.JarLauncher JDK.checkpoint
  sleep 5
fi
java -Dmanagement.endpoint.health.probes.add-additional-paths="true" -Dmanagement.health.probes.enabled="true" -XX:CRaCRestoreFrom=$CRAC_FILES_DIR
