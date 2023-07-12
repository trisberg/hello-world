#!/bin/bash
set -x

CRAC_FILES_DIR=`eval echo ${CRAC_FILES_DIR}`
mkdir -p $CRAC_FILES_DIR

cd /home/app
if [ ! -z "$CRAC_CHECKPOINT" ]; then
  rm -rf $CRAC_FILES_DIR/*
  echo 128 > /proc/sys/kernel/ns_last_pid; java -Dmanagement.endpoint.health.probes.add-additional-paths="true" -Dmanagement.health.probes.enabled="true" -XX:CRaCCheckpointTo=$CRAC_FILES_DIR org.springframework.boot.loader.JarLauncher &
  PID=$!
  sleep 5
  jcmd $PID JDK.checkpoint
  sleep 10
  echo "true" > $CRAC_FILES_DIR/READY
else
  if [ -f "$CRAC_FILES_DIR/READY" ]; then
    java -Dmanagement.endpoint.health.probes.add-additional-paths="true" -Dmanagement.health.probes.enabled="true" -XX:CRaCRestoreFrom=$CRAC_FILES_DIR &
    PID=$!
    trap "kill $PID" SIGINT SIGTERM
    wait $PID
  else
    echo "ERROR: CRaC Checkpoint files are not available!"
    exit -1
  fi
fi
