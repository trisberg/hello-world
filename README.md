# hello-world
Sample project for Tanzu Platform

## install tanzu cli

Instructions at: https://github.com/vmware-tanzu/tanzu-cli/blob/main/docs/quickstart/install.md

On a Mac:

```shell
brew tap vmware-tanzu/tanzu
brew install tanzu-cli
```

## install cli plugins

```shell
tanzu plugin install --group vmware-tanzu/app-developer:v1.0.0
```

## log in to the platform

> You need to have an environment available

Using your default org:

```shell
tanzu login
``` 

Using specific endpoint:

```shell
tanzu login --endpoint <provided endpoint>
``` 

For a staging environment:

```shell
tanzu login --staging --endpoint <provided endpoint>
```

## select a project to use

```shell
tanzu project use
```

## create a space

> Use the provided `spring-dev-space.yml` to create a space

```shell
tanzu deploy --only spring-dev-space.yml
```

> use the new space

```shell
tanzu space use spring-dev-space
```
 
## initialize the app

```shell
tanzu app init
```

> we need java 21 and 1 instance to start with

```shell
tanzu app config build non-secret-env set BP_JVM_VERSION=21
tanzu app config scale set instances=1
```

## build the app

### configure for local daemon builds

> you need a registry that is accessible from the platform environment.

For DockerHub:

```shell
tanzu build config --build-engine daemon
tanzu build config --containerapp-registry docker.io/<docker-id>/{name}
```
> The `{name}` part is a placeholder that will be resolved to match your app at build time, so leave that as is.

### configure for platform builds

```shell
tanzu build config --build-engine platform
```

## deploy the app

```shell
tanzu deploy
```

## scale the app

```shell
tanzu app scale hello-world --instances=2
```

## access the app

> Use port-forward

```shell
tanzu app port-forward hello-world --port 8080
```

> use curl to get some feedback

```shell
curl localhost:8080
``` 

