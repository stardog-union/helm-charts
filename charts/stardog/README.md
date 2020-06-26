Stardog Helm Chart
==================

This chart installs Stardog, either single node or a cluster with a ZooKeeper ensemble,
which is required for the cluster. The chart pulls the latest version of Stardog from
Docker Hub and does not support rolling upgrades.

Chart Details
-------------

This chart does the following:

- Creates a ZooKeeper ensemble from the incubated ZooKeeper Helm chart
- Creates a Stardog Cluster StatefulSet configured with readiness and liveness probes
- Deploys a single node Stardog if the cluster is disabled
- Creates a load balanced service for Stardog
- Optionally specify the anti-affinity for the pods
- Optionally tune resource requests and limits for the pods
- Optionally tune JVM resources for Stardog

Configuration Parameters
------------------------

| Parameter                                    | Description |
| ---                                          | --- |
| `fullnameOverride`                           | The k8s name for the Stardog deployment |
| `cluster.enabled`                            | Enable Stardog Cluster |
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
| `log4jConfig.override`                       | Whether to override the default log4j config |
| `log4jConfig.content`                        | The new log4j configuration |
| `securityContext.runAsUser`                  | UID used by the Stardog container to run as non-root |
| `securityContext.runAsGroup`                 | GID used by the Stardog container to run as non-root |
| `securityContext.fsGroup`                    | GID for the volume mounts |

The default values are specified in `values.yaml` as well as the required values for the ZooKeeper chart.

Upgrades
--------

Stardog Cluster does not currently support rolling upgrades. To upgrade Stardog on k8s,
make sure there are no running transactions and then delete the Stardog pods and
redeploy them with the new Stardog version. If there are manual
steps required as part of the upgrade process k8s jobs will need to be used
to run the steps on the Stardog home directories in the PVCs.

See the [Stardog documentation](https://www.stardog.com/docs/#_upgrading_the_cluster)
for instructuions on how to upgrade Stardog Cluster.

Limitations
-----------

The chart does not currently support:
- cache targets
- rolling upgrades
- pinning chart version to Stardog versions, the chart tracks the latest available Stardog,
it's not guaranteed to work with any Stardog version
