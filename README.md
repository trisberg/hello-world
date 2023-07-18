# hello-world CRaC demo for SpringOne@Explore 2023

This repo provides a simple Hello World sample project for Spring Boot.

It can be deployed to a Kubernetes cluster utilizing Coordinated Restore at Checkpoint (CRaC).

## Local run

To run the app locally using the embedded Tomcat server you can run this command:

```bash
./mvnw spring-boot:run
```

You can modify the default message "World" using an application property of `app.message`:

```bash
/mvnw spring-boot:run -Dspring-boot.run.arguments="--app.message=Test"
```

## Build image and push to Docker Hub

### Build the image

> NOTE: This build can be run on X86-64 as well as ARM-64 based systems but the target cluster must be x86-64 based.

To build the image run the `build.sh` script.

```bash
./build.sh
```

This will build and push the image to Docker Hub (this sample is using a `springdeveloper` account. If you need to change this, then there are several references in other files that need to get modified as well).

### Create the NFS server for the checkpoint files

To create a PVC and an NFS server for storing the checkpoint files, run:

```bash
kubectl apply -f crac-nfs
```

## Deployment

### Deploying as a Kubernetes deployment and service

#### Deploy Kubernetes deployment and service

To create the deployment that will restore from the checkpoint and the service, run the following:

```bash
ytt -f kubernetes \
  --data-value=version=$(cat VERSION) \
  --data-value=nfs_server_ip=$(kubectl get service nfs-server -o jsonpath='{.spec.clusterIP}') | \
kapp deploy -a hello-world -y -f -
```

#### Accessing the app deployed to your cluster

The service is configured for a LoadBalancer so you can retrieve the assigned IP address using:

```bash
APP_URL=http://$(kubectl get service hello-world -o jsonpath='{.status.loadBalancer.ingress[0].ip}')
```

To access the deployed app run:

```bash
curl $APP_URL
```

#### Scaling the deployment replicas

To scale the deployment replicas to zero use:

```bash
kubectl scale deployment/hello-world --replicas=0
```

To scale the deployment back up use:

```bash
kubectl scale deployment/hello-world --replicas=1
```

### Deploying as a Knative service

#### Configure Knative

Update the Knative configuration with the following features enabled:

```
  kubernetes.podspec-securitycontext: Enabled
  kubernetes.containerspec-addcapabilities: Enabled
  kubernetes.podspec-persistent-volume-claim: Enabled
  kubernetes.podspec-persistent-volume-write: Enabled
  kubernetes.podspec-fieldref: Enabled
```

Use this command to edit the config:

```
kubectl edit configmap/config-features -n knative-serving
```

You also need to deploy a webhook that will allow Knative services to use containers that run in priveleged mode.

> TBD

#### Deploy Knative service

To create the Knative service that will checkpoint and then restore from the checkpoint, run the following:

```bash
kubectl create -f knative/service.yaml
```

#### Accessing the app deployed to your cluster

Determine the URL to use for the accessing the app by running:

```bash
kn service list
```

or, using kubectl:

```bash
kubectl get service.serving.knative.dev
```

To access the deployed app use the URL shown under "Workload Knative Services".

```bash
APP_URL=<Knative-service-URL>
```

Then, use `curl` or some other utility to access the URL:

```bash
curl $APP_URL
```

### Deploying as a TAP workload

> TBD, not working yet

#### Deploy TAP workload from the image

To create the TAP workload that will restore from the checkpoint, run the following:

```bash
tanzu apps workload create -f config/workload.yaml
```

#### Accessing the app deployed to your cluster

Determine the URL to use for the accessing the app by running:

```bash
tanzu apps workload get hello-world
```

To access the deployed app use the URL shown under "Knative Services".

```bash
export APP_URL=<Knative-service-URL>
```

Then, use `curl` or some other utility to access the URL:

```bash
curl APP_URL
```
