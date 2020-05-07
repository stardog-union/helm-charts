Stardog Helm Chart
==================

[![License](https://img.shields.io/badge/License-Apache%202.0-blue.svg)](https://opensource.org/licenses/Apache-2.0)
[![<ORG_NAME>](https://circleci.com/gh/stardog-union/helm-charts.svg?style=shield&circle-token=213cf9bca0acf5d3945dfd5d746b48f1c2d436e0)](https://app.circleci.com/pipelines/gh/stardog-union/helm-charts)

This chart installs Stardog Cluster and a ZooKeeper ensemble, which is required for
the cluster. The chart pulls the latest version of Stardog from Docker Hub and does
not support rolling upgrades.

Stardog documentation: https://www.stardog.com/docs

Prerequisites
-------------

- Stardog Cluster license file
- Helm v3
- Persistent volume support
- Load balancer service
- Familiarity with Stardog Cluster
- Familiarity with Apache ZooKeeper

Chart Details
-------------

This chart does the following:

- Creates a ZooKeeper ensemble from the incubated ZooKeeper Helm chart
- Creates a Stardog Cluster StatefulSet configured with readiness and liveness probes
- Creates a load balanced service for Stardog Cluster
- Optionally specify the anti-affinity for the pods
- Optionally tune resource requests and limits for the pods
- Optionally tune JVM resources for Stardog

Installing
----------

```
$ kubectl -n <your-namespace> create secret generic stardog-license --from-file stardog-license-key.bin=/path/to/stardog-license-key.bin
$ cd charts/stardog && helm dependencies update && cd ..
$ helm install <helm-release-name> charts/stardog --namespace <your-namespace>
```

To install from Helm repository:

```
$ kubectl -n <your-namespace> create secret generic stardog-license --from-file stardog-license-key.bin=/path/to/stardog-license-key.bin
$ helm repo add stardog https://stardog-union.github.io/helm-charts/
$ helm install <helm-release-name> --namespace <your-namespace> stardog/stardog
```

Configuration Parameters
------------------------

| Parameter                                    | Description |
| ---                                          | --- |
| `replicaCount`                               | The number of replicas in Stardog Cluster |
| `admin.password`                             | Stardog admin password |
| `javaArgs`                                   | Java args for Stardog server |
| `image.registry`                             | The Docker registry containing the Stardog image |
| `image.repository`                           | The Docker image repostory containing the Stardog image  |
| `image.tag`                                  | The Docker image tag for Stardog |
| `image.username`                             | The Docker registry username |
| `image.password`                             | The Docker registry password |
| `persistence.storageClass`                   | The storage class to use for Stardog home volumes |
| `persistence.size`                           | The size of volume for Stardog home |
| `ports.server`                               | The port to expose Stardog server |
| `ports.sql`                                  | The port to expose Stardog BI server |
| `tmpDir`                                     | The directory to use for Stardog tmp space |

The default values are specified in `charts/stardog/values.yaml` as well as the required values for the ZooKeeper chart.

Deleting
--------

```
$ helm delete <helm-release-name> --namespace <your-namespace>
```

Upgrades
--------

Stardog Cluster does not currently support rolling upgrades. To upgrade Stardog on k8s,
make sure there are no running transactions and then delete the Stardog pods and
redeploy them with the new Stardog version. If there are manual
steps required as part of the upgrade process k8s jobs will need to be used
to run the steps on the Stardog home directories in the PVCs.

Stardog documentation for upgrading the cluster: https://www.stardog.com/docs/#_upgrading_the_cluster

Limitations
-----------

The chart does not currently support:
- cache targets
- rolling upgrades
- pinning chart version to Stardog versions, the chart tracks the latest available Stardog,
it's not guaranteed to work with any Stardog version
