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
