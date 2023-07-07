#!/bin/bash
set -x

CRAC_FILES_DIR=`eval echo ${CRAC_FILES_DIR}`
mkdir -p $CRAC_FILES_DIR

if [ ! -z "$CRAC_CHECKPOINT" ]; then
  rm -rf $CRAC_FILES_DIR/*
  echo 128 > /proc/sys/kernel/ns_last_pid; java -Dmanagement.endpoint.health.probes.add-additional-paths="true" -Dmanagement.health.probes.enabled="true" -XX:CRaCCheckpointTo=$CRAC_FILES_DIR -jar  /home/app/hello-world.jar &
  sleep 5
  jcmd /home/app/hello-world.jar JDK.checkpoint
  sleep 30
else
  java -Dmanagement.endpoint.health.probes.add-additional-paths="true" -Dmanagement.health.probes.enabled="true" -XX:CRaCRestoreFrom=$CRAC_FILES_DIR&
  PID=$!
  trap "kill $PID" SIGINT SIGTERM
  wait $PID
fi
