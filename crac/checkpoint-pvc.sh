#!/bin/bash

NFS_SERVER_IP=$(kubectl get service nfs-server -o jsonpath='{.spec.clusterIP}')
cat <<EOF | kubectl apply -f -
---
apiVersion: v1
kind: PersistentVolume
metadata:
  annotations:
    kapp.k14s.io/update-strategy: skip
  name: hello-world
spec:
  capacity:
    storage: 500Mi
  accessModes:
    - ReadWriteMany
  nfs:
    server: $NFS_SERVER_IP
    path: "/"
  storageClassName: "nfs"
---
kind: PersistentVolumeClaim
apiVersion: v1
metadata:
  name: hello-world
spec:
  accessModes:
    - ReadWriteMany
  storageClassName: "nfs"
  resources:
    requests:
      storage: 500Mi
EOF
