# hello-world on CRaC

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

## Build image and create CRaC checkpoint

### Build the image

> NOTE: This build can be run on X86-64 as well as ARM-64 based systems but the target cluster must be x86-64 based.

To build the image run the `build.sh` script.

```bash
./build.sh
```

Then push the image to Docker Hub (this sample is using a `springdeveloper` account. If you need to change this, then there are several references in other files that need to get modified as well).

```bash
docker push springdeveloper/hello-world:amd64
```

### Create the NFS server for the checkpoint files

To create a PVC and an NFS server for storing the checkpoint files, run:

```bash
kapp deploy -a nfs -y -f crac-nfs
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

To scale the deployment to zero use:

```
kubectl scale deployment/hello-world --replicas=0
```

To scale the deployment up use:

```
kubectl scale deployment/hello-world --replicas=1
```

#### Accessing the app deployed to your cluster

You can create a local port forwarding for the service by running:

```bash
kubectl port-forward svc/hello-world 8080:80
```

To access the deployed app open another terminal window and run:

```bash
curl localhost:8080
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

To create the Knative service that will restore from the checkpoint, run the following:

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
export URL=<Knative-service-URL>
```

Then, use `curl` or some other utility to access the URL:

```bash
curl ${URL}
```

### Deploying as a TAP workload

> Not working yet

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
export URL=<Knative-service-URL>
```

Then, use `curl` or some other utility to access the URL:

```bash
curl ${URL}
```

## Updating the App message

To modify the message you can change the `APP_MESSAGE` environment variable in the `kubernetes/checkpoint-job.yaml` file. To apply the change, create a new job using:

```bash
kubectl create kubernetes/checkpoint-job.yaml
```

After the job completes, the next time the pod for the service gets restarted it will pick up the change.

### Force restart for Kubernetes deployment

You can force a new pod to get started by deleting the latest one. Get the pod name by running:

```bash
kubectl get pods -l=app.kubernetes.io/name=hello-world
```

Then delete it using the following (adjusted for the name of the latest pod):

```bash
kubectl delete pod/hello-world-6968dbffdc-pdvgf
```

### Force restart for Knative service

You can force a new pod to get started by deleting the latest revision. Get the revision name by running:

```bash
kn revision list -s hello-world
```

Then delete it using the following (adjusted for the name of the latest revision):

```bash
kn revision delete hello-world-00001
```

### Force restart for TAP workload

> TBD