Stardog Cache Target Helm Chart
===============================

This chart installs a Stardog Cache Target. You must deploy a Stardog cluster
before deploying the cache target.

Chart Details
-------------

This chart deploys a cache target node in k8s and registers the cache target
with a Stardog Cluster deployment in the same namespace.

Configuration Parameters
------------------------

| Parameter                                    | Description |
| ---                                          | --- |
| `fullnameOverride`                           | The k8s name for the Stardog deployment |
| `namespaceOverride`                          | The k8s namespace for the Stardog deployment (single node only) |
| `admin.password`                             | Stardog admin password |
| `admin.passwordSecretRef`                    | A reference to an external Stardog admin password secret (if set, `admin.password` will be ignored) |
| `javaArgs`                                   | Java args for Stardog server |
| `image.registry`                             | The Docker registry containing the Stardog image |
| `image.repository`                           | The Docker image repository containing the Stardog image  |
| `image.pullPolicy`                           | The Docker image pullPolicy for Stardog |
| `image.tag`                                  | The Docker image tag for Stardog |
| `image.username`                             | The Docker registry username |
| `image.password`                             | The Docker registry password |
| `persistence.storageClass`                   | The storage class to use for Stardog home volumes |
| `persistence.size`                           | The size of volume for Stardog home |
| `ports.server`                               | The port to expose Stardog server |
| `tmpDir`                                     | The directory to use for Stardog tmp space. If you choose to place this in STARDOG_HOME (/var/opt/stardog) for performance reasons, ensure that it does not conflict with any possible database names. For example, a good choice might be /var/opt/stardog/tmp-4646E7B662A7. If the directory does not exist it will be created. |
| `log4jConfig.override`                       | Whether to override the default log4j config |
| `log4jConfig.content`                        | The new log4j configuration |
| `securityContext.runAsUser`                  | UID used by the Stardog container to run as non-root |
| `securityContext.runAsGroup`                 | GID used by the Stardog container to run as non-root |
| `securityContext.fsGroup`                    | GID for the volume mounts |
| `additionalStardogProperties`                | Allow adding additional settings to stardog.properties file |
| `cluster.name`                               | The name of the Stardog Cluster to register the target with (in the same namespace) |
| `cluster.port`                               | The port of the Stardog Cluster to register the target with (in the same namespace) |

The default values are specified in `values.yaml`.
