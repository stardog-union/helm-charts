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
