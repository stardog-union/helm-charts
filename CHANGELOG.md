# 2.1.1 (2024-09-19)

* Remove preStop hook that issues server stop to the Stardog pod and rely on SIGTERM from k8s (#111)

# 2.1.0 (2024-09-03)

* Use environment variables for passwords instead of mounting as a file (#106)
* Add support for cache targets (#108)
* Allow image pull secrets for docker images (#109)

# 2.0.10 (2023-09-25)

* Add startupProbe (#97)

# 2.0.9 (2023-06-06)

* added option to add a passwordSecretRef for the database setup (#95)

# 2.0.8 (2023-04-27)

* Change Occurences of sh to bash (#92)
* Bump Bitnami ZooKeeper Chart, ZooKeeper upgraded to 3.7.1 from 3.5.7, and Update Docs for Upgrading ZooKeeper (#93)

# 2.0.7 (2023-02-14)

* Make imagePullSecrets optional (#77)
* Ignores image pull secret if not passed (#89) 
* Add data load and query to smoke tests (#84) 

# 2.0.6 (2022-09-02)

* Change Docker URLs to use v2 of the API (#86)

# 2.0.5 (2022-06-07)

* Patch the zookeeper dependency in stardog chart a result of change in the bitnami retention policy (#71)

# 2.0.4 (2021-12-07)

* Added the ability to add additional settings to the configmap of the stardog configmap (#50). 
* Add Stardog server start arguments to the values file (#66)
* Provide parameters for setting the origin of the busybox image which is used
  as a part of the Stardog pod initialization (#60)
* Create the tmpDir used by Stardog if it doesn't already exist. This can be useful when
  placing the tmpDir onto the same volume as STARDOG_HOME (/var/opt/stardog). Note 
  that it's critical not to choose a path within STARDOG_HOME that could conflict with a
  database name. See the [values.yaml](charts/stardog/values.yaml) for details. (#62)

# 2.0.3 (2021-09-16)

* Use Java G1 gc by default (#56)
* Set JVM active processor count to k8s cpu requests, default to 2 (#51)
* Remove admin password from post-install job standard out (#48)

# 2.0.2 (2021-06-09)

Features:
* Allow user to set annotations and loadBalancerIP property of service (#46)
* Supports tolerations for tainted nodes (#44)
* Tune chart values and settings to improve startup time (#41)
* Make podManagementPolicy configurable for Stardog statefulset (#39)

# 2.0.1 (2020-12-14)

Features:
* Installing to a namespace with an existing PVC, post-install fails because password was already changed (#35)
* Allow namespace to be specified in values file (#30)

# 2.0.0 (2020-11-17)

Features:
* Migrates to Bitnami ZK chart with ZK 3.5.x (#21)

# 1.0.4 (2020-09-11)

Features:
* Use the security context on the post install job pod (#25)
* Allow service type to be configurable (#24)

# 1.0.3 (2020-08-21)

Features:
* Add option for delay seconds in the post install job (#22)
* Add paramaterization to K8S liveness and readiness probes (#19)
* Use templated fullname in post install job (#17)

# 1.0.2 (2020-06-24)

Features:
* Don't include a specific storage class if it's not specified (#13)
* Only deploy init container if cluster is enabled (#12)
* Allow override of log4j config (#11)
* Allow non-root containers to be deployed (#10)

# 1.0.1 (2020-06-02)

Features:
* Adds flag to disable Stardog Cluster and ZooKeeper (#7)
* Change default Stardog password via Helm post install hook (#5)
* Allow user to set the termination grace period for Stardog pods (#1)

Initial release
---------------

Features:
* Helm chart to launch Stardog Cluster and ZooKeeper in Kubernetes
* Create persistent volume claims for Stardog Home directories
* Monitor health and readiness via liveness and readiness probes
* Publish Stardog chart to Helm Hub
