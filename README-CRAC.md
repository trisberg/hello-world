# hello-world on CRaC

This repo provides a simple Hello World sample project for Spring Boot.

It can be deployed as a Knative service utilizing Coordinated Restore at Checkpoint (CRaC).

## Deployment

### Deploying to Knative Serving

#### Build the image

> NOTE: This build can be run on X86-64 as well as ARM-64 based systems but the target cluster must be x86-64 based.

To build the image run the `build.sh` script.

```bash
./build.sh
```

Then push the image to Docker Hub (this sample is using a `springdeveloper` account. If you need to change this, then there are several references in other files that need to get modified as well).

```bash
docker push springdeveloper/hello-world:amd64
```

#### Create the first checkpoint

To create a PVC that will store the checkpoint files and run a job to create them, run:

```bash
kubectl create -f kubernetes/checkpoint-pvc.yaml
kubectl create -f kubernetes/checkpoint-job.yaml
```

#### Deploy Knative service that restores from the checkpoint

To create the Knative service that will restore from the checkpoint, run the following:

```bash
kubectl create -f knative/service.yaml
```

## Accessing the app deployed to your cluster

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

## Updating the App message

To modify the message you can change the `APP_MESSAGE` environment variable in the `kubernetes/checkpoint-job.yaml` file. To apply the change, create a new job using:

```bash
kubectl create kubernetes/checkpoint-job.yaml
```

After the job completes, the next time the pod for the service gets restarted it will pick up the change.

You can force a new pod to get started by deleting the latest revision. Get the revision name by running:

```bash
kn revision list -s hello-world
```

Then delete it using the following (adjusted for the name of the latest revision):

```bash
kn revision delete hello-world-00001
```
