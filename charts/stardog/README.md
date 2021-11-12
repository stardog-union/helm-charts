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
| `namespaceOverride`                          | The k8s namespace for the Stardog deployment (single node only) |
| `cluster.enabled`                            | Enable Stardog Cluster |
| `replicaCount`                               | The number of replicas in Stardog Cluster |
| `podManagementPolicy`                        | Set the pod startup policy - use `OrderedReady` (default) or `Parallel` |
| `admin.password`                             | Stardog admin password |
| `javaArgs`                                   | Java args for Stardog server |
| `serverStartArgs`                            | Additional arguments for Stardog server start |
| `image.registry`                             | The Docker registry containing the Stardog image |
| `image.repository`                           | The Docker image repository containing the Stardog image  |
| `image.pullPolicy`                           | The Docker image pullPolicy for Stardog |
| `image.tag`                                  | The Docker image tag for Stardog |
| `image.username`                             | The Docker registry username |
| `image.password`                             | The Docker registry password |
| `persistence.storageClass`                   | The storage class to use for Stardog home volumes |
| `persistence.size`                           | The size of volume for Stardog home |
| `ports.server`                               | The port to expose Stardog server |
| `ports.sql`                                  | The port to expose Stardog BI server |
| `tmpDir`                                     | The directory to use for Stardog tmp space. If you choose to place this in STARDOG_HOME (/var/opt/stardog) for performance reasons, ensure that it does not conflict with any possible database names. For example, a good choice might be /var/opt/stardog/tmp-4646E7B662A7. If the directory does not exist it will be created. |
| `log4jConfig.override`                       | Whether to override the default log4j config |
| `log4jConfig.content`                        | The new log4j configuration |
| `securityContext.runAsUser`                  | UID used by the Stardog container to run as non-root |
| `securityContext.runAsGroup`                 | GID used by the Stardog container to run as non-root |
| `securityContext.fsGroup`                    | GID for the volume mounts |
| `busybox.image.registry`                     | The Docker registry containing the busybox image (used as a part of Stardog initialization) |
| `busybox.image.repository`                   | The Docker image repository containing the busybox image (used as a part of Stardog initialization) |
| `busybox.image.pullPolicy`                   | The Docker image pullPolicy for the busybox image (used as a part of Stardog initialization) |
| `busybox.image.tag`                          | The Docker image tag for busybox image (used as a part of Stardog initialization) |
| `busybox.image.username`                     | The Docker registry username for busybox image registry (used as a part of Stardog initialization) |
| `busybox.image.password`                     | The Docker registry password for the busybox image registry (used as a part of Stardog initialization)  |
| `additionalStardogProperties`                | Allow adding additional settings to stardog.properties file |

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

### Upgrading from 1.x to 2.x

Version 2.x of the charts deploys ZooKeeper 3.5 instead of 3.4. Before upgrading the
charts make sure you have upgraded to Stardog 7.4.2 or later, which includes preview
support for ZooKeeper 3.5.

After upgrading Stardog you can upgrade the charts by taking down your full deployment
of Stardog and ZooKeeper pods (but do not delete the PVCs with Stardog home data) by
following this process:
- Stop all traffic and updates to your cluster or wait for them to end. You can ensure there
are no transactions running on a database with `stardog-admin db status <db name>`.
- Backup Stardog home and copy the backup out of the k8s environment. The
[Stardog documentation](https://www.stardog.com/docs/#_backing_up_and_restoring) includes
an overview of the various options for backing up Stardog. Only S3 backups will copy
data outside of the pods. If you use another backup method you will need to manually
copy the data off the volume or snapshot the volumes to ensure the data is stored in
a separate location.
- Shutdown all Stardog and ZooKeeper pods (e.g. using `helm delete`).
- Install the new 2.x charts with the same version of Stardog you were running previously.

Limitations
-----------

At this time namespaceOverride is currently only supported for single-node deploys
because the downstream ZooKeeper chart does not support namespaceOverride for ZooKeeper
3.5 deployments.

The chart does not currently support:
- cache targets
- rolling upgrades
- pinning chart version to Stardog versions, the chart tracks the latest available Stardog,
it's not guaranteed to work with any Stardog version
