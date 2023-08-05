# Notes for KEDA

KEDA is a project that provides Kubernetes Event-driven Autoscaling. More info at [keda.sh/](https://keda.sh/).

## Install

Add KEDA Helm repo:

```sh
helm repo add kedacore https://kedacore.github.io/charts
helm repo update
```

Install KEDA in cluster-global mode:

```sh
helm install --create-namespace -n keda keda kedacore/keda
```

Install the KEDA [HTTP add-on](https://github.com/kedacore/http-add-on):

```sh
helm install -n keda http-add-on kedacore/keda-add-ons-http
```

We can now deploy the following `HTTPScaledObject` resource:

```yaml
apiVersion: http.keda.sh/v1alpha1
kind: HTTPScaledObject
metadata:
  name: hello-world
spec:
  hosts:
  - hello-world.springdeveloper.dev
  targetPendingRequests: 10
  scaledownPeriod: 30
  scaleTargetRef:
    deployment: hello-world
    service: hello-world-k8s
    port: 80
  replicas:
    min: 0
    max: 10
```

Once this is in place, port-forward the KEDA interceptor proxy:

```sh
kubectl port-forward svc/keda-add-ons-http-interceptor-proxy -n keda 8080:8080
```

In a separate terminal we can now excercise the auto-scaling.

Using `curl`:

```sh
curl -H 'host: hello-world.springdeveloper.dev' http://localhost:8080
```

Or, using `siege`:

```sh
siege -c 200 -r 10000 -H 'host: hello-world.springdeveloper.dev' -b http://localhost:8080
```
