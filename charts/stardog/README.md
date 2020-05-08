Stardog Helm Chart
==================

This chart installs Stardog Cluster and a ZooKeeper ensemble, which is required for
the cluster. The chart pulls the latest version of Stardog from Docker Hub and does
not support rolling upgrades.

Chart Details
-------------

This chart does the following:

- Creates a ZooKeeper ensemble from the incubated ZooKeeper Helm chart
- Creates a Stardog Cluster StatefulSet configured with readiness and liveness probes
- Creates a load balanced service for Stardog Cluster
- Optionally specify the anti-affinity for the pods
- Optionally tune resource requests and limits for the pods
- Optionally tune JVM resources for Stardog

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
