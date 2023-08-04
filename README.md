# hello-world JVM Checkpoint/Restore demo for SpringOne at VMware Explore 2023

This repo provides a simple Hello World sample project for Spring Boot.

It can be deployed locally or to a Kubernetes cluster utilizing Coordinated Restore at Checkpoint (CRaC) as provided by the Azul Zulu builds of OpenJDK with CRaC support.

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

> NOTE: This build can be run on X86-64 as well as ARM-64 based systems and you can specify the target architecture to use as `amd64` for X86-64 based Kubernetes clusters or as `arm64` for ARM based ones.

To specify the target architecture of the Kubernetes cluster set the `TARGET_ARCH` environment variable. For x64_64 based systems set:

```bash
export TARGET_ARCH=amd64
```

and, for ARM based system set:

```bash
export TARGET_ARCH=arm64
```

### Build the image

To build the image run the `build.sh` script.

```bash
./build.sh
```

This will build and push the image to Docker Hub (this sample is using a `springdeveloper` account. If you need to change this, then there are a few references in other files that need to get modified as well).

## Running locally using Docker

This will create a `cracvol` volume where the checkpoint files will be written.

To start the container run:

> Note: This requires a few additional capabilities beyond the ones you automatically get from Docker.

```
docker run -it --rm -p 8080:8080 -e CRAC_FILES_DIR=/crac/hello-world --name hello-world \
  --mount source=cracvol,target=/crac \
  --cap-add CHECKPOINT_RESTORE --cap-add NET_ADMIN --cap-add SYS_PTRACE --cap-add SYS_ADMIN \
  docker.io/springdeveloper/hello-world:${TARGET_ARCH}-$(cat VERSION)
```

If you kill the `hello-world` container you will notice that the next time you start it, it will restore the files from the attached `cracvol` volume.

## Running in a Kubernetes cluster

### Create the NFS server for the checkpoint files

> Note: different providers use different storage class names. Use one that is available on your cluste, typically "default" or "standard".

To create a PVC and an NFS server for storing the checkpoint files, run:

```bash
ytt -f crac-nfs \
  --data-value=storage_class_name=standard | \
kubectl apply -f -
```

## Use a Kubernetes Deployment and Service

### Running as a Kubernetes deployment and service

#### Deploying the app

To create the deployment that will restore from the checkpoint and the service, run the following:

```bash
ytt -f kubernetes \
  --data-value=arch=$TARGET_ARCH \
  --data-value=version=$(cat VERSION) \
  --data-value=nfs_server_ip=$(kubectl get service nfs-server -o jsonpath='{.spec.clusterIP}') | \
kapp deploy -a hello-world -y -f -
```

#### Accessing the app deployed to your cluster

The service is configured for a NodePort so you can use port forward to access the app:

```bash
kubectl port-forward svc/hello-world 8080:80
```

Then, in a different terminal run:

```bash
APP_URL=http://localhost:8080
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

#### Deploy Knative service

To create the Knative service that will checkpoint and then restore from the checkpoint, run the following:

```bash
ytt -f knative \
  --data-value=arch=$TARGET_ARCH \
  --data-value=version=$(cat VERSION) \
  --data-value=nfs_server_ip=$(kubectl get service nfs-server -o jsonpath='{.spec.clusterIP}') | \
kubectl create -f -
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
