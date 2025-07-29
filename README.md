Stardog Helm Charts
===================

[![License](https://img.shields.io/badge/License-Apache%202.0-blue.svg)](https://opensource.org/licenses/Apache-2.0)
[![stardog-union](https://circleci.com/gh/stardog-union/helm-charts.svg?style=shield)](https://app.circleci.com/pipelines/gh/stardog-union/helm-charts)

These charts install the Stardog Knowledge Graph platform on Kubernetes.

Stardog documentation: https://www.stardog.com/docs

Highlights
----------

As of version 2.0.0 of the Stardog Helm charts, ZooKeeper 3.5.7 is now deployed
with the [Bitnami](https://github.com/bitnami/charts/tree/master/bitnami/zookeeper)
ZooKeeper chart. Stardog 7.4.2 includes preview support for ZooKeeper 3.5.x so you
must be running that version of Stardog or later. Please see the Stardog chart
[README](https://github.com/stardog-union/helm-charts/blob/develop/charts/stardog/README.md)
for instructions on how to upgrade from version 1.x of the charts to version 2.

We strongly recommend that the charts request at least 2 CPUs or more for Stardog.
By default the Stardog chart requests 2 CPUs. This value can be configured in the
`values.yaml` file.

Prerequisites
-------------

- Stardog Cluster license file
- Helm v3
- Persistent volume support
- Load balancer service or Ingress controller
- Familiarity with Stardog Cluster
- Familiarity with Apache ZooKeeper

Installing
----------

```
$ kubectl -n <your-namespace> create secret generic stardog-license --from-file stardog-license-key.bin=/path/to/stardog-license-key.bin
$ helm repo add stardog https://stardog-union.github.io/helm-charts/
$ helm install <helm-release-name> --namespace <your-namespace> stardog/stardog
```

### Using Ingress

The charts now support using Ingress for exposing Stardog and Launchpad services. To enable this, you need to have an ingress controller installed, like the [NGINX Ingress Controller](https://docs.nginx.com/nginx-ingress-controller/).
You also need an SSL certificate, and its associated private key to be used by the controller, and you also need to be able
to point your DNS records to the Ingress object URL once created. Finally, you need to be able to create secrets in the namespace where this is deployed. To find the structure of this secret object, follow https://kubernetes.io/docs/concepts/services-networking/ingress/#tls.


Here's an example of how to configure the values needed for ingress to work:

```
# Ingress configuration for any component. Configure it accordingly for each <compoonent> required, like stardog, or launchpad.
ingress:
  enabled: true
  className: "nginx"
  hosts:
    # You must own example.com, and you need to be able to point your DNS records to the ingress URL.
    - host: acme-<component>.example.com
      paths:
        - path: /
          pathType: Prefix
  tls:
  - hosts: ["acme-<component>.example.com"]
    # You need to manually create this secret object
    secretName: stardog-tls
```


See the Stardog chart's [README](./charts/stardog/README.md)
for a list of configuration parameters.

See the Stardog Cache Target's chart's [README](./charts/cachetarget/README.md)
for instructions on how to deploy a cache target as well as a list of its configuration parameters.

See the Voicebox chart's [README](./charts/voicebox/README.md)
for instructions on how to deploy Voicebox and a list of its configuration parameters.

Deleting
--------

```
$ helm delete <helm-release-name> --namespace <your-namespace>
```

Running the tests locally
-------------------------

This assume you have Docker installed and running this on MacOs. For other systems, install their corresponding binaries.

## Install minikube
```
# Get the one from here https://github.com/kubernetes/minikube/releases For macos, this is the latest version
curl -Lo minikube https://github.com/kubernetes/minikube/releases/download/<minikube-version>/minikube-darwin-arm64
chmod +x minikube
sudo mv minikube /usr/local/bin/
```

## Start minikube
Your k8s version should be the same as your kubectl version. This will update your ~/.kube/config file and set minikube to the current context.
```
minikube start --driver=docker --kubernetes-version=v1.32.0
```

## Set up the Stardog license
Make sure you have a proper stardog license called `stardog-license-key.bin` located in the root directory of this project.
```
kubectl -n <your-namespace> create secret generic stardog-license --from-file stardog-license-key.bin=stardog-license-key.bin
```
## Replace the Stardog license
If your license is about to expire, you can replace you existing license with a new one using the following command.
```
kubectl -n <your-namespace> create secret generic stardog-license --from-file stardog-license-key.bin=/path/to/new/stardog-license-key.bin
```

## Install Stardog as a helm release
```
helm install stardog charts/stardog/ --wait --timeout 15m -f tests/minikube.yaml \
--set "cluster.enabled=false" \
--set "replicaCount=1" \
--set "zookeeper.enabled=false"
```

## Run the tests
`./tests/smoke.sh`
