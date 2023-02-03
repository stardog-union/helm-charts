#!/bin/bash

set +x

HELM_RELEASE_NAME="stardog-helm-tests"
NAMESPACE="stardog"
NUM_STARDOGS="3"
NUM_ZKS="3"

STARDOG_ADMIN=
STARDOG_CLI=
STARDOG_IP=


function dependency_checks() {
	echo "Checking for dependencies"
	helm version >/dev/null 2>&1 || { echo >&2 "The helm tests require helm but it's not installed, exiting."; exit 1; }
	kubectl version >/dev/null 2>&1 || { echo >&2 "The helm tests require kubectl but it's not installed, exiting."; exit 1; }
	echo "Dependency check passed."
}

function minikube_start_tunnel() {
	pushd ~
	echo "Starting minikube tunnel"
	echo "sudo -E minikube tunnel" > ~/start-minikube-tunnel.sh
	chmod u+x ~/start-minikube-tunnel.sh
	nohup ~/start-minikube-tunnel.sh > ~/minikube_tunnel.log 2> ~/minikube_tunnel.err < /dev/null &
	echo "Minikube tunnel started in the background"
	popd
}

function install_stardog() {
	mkdir -p ~/stardog-binaries/
	pushd ~/stardog-binaries/
	curl -Lo stardog-latest.zip https://downloads.stardog.com/stardog/stardog-latest.zip
	unzip stardog-latest.zip
	export STARDOG_ADMIN="$(ls ${HOME}/stardog-binaries/stardog-*/bin/stardog-admin)"
	export STARDOG_CLI="$(ls ${HOME}/stardog-binaries/stardog-*/bin/stardog)"
	popd
}

function helm_setup_cluster() {
	echo "Creating stardog namespace"
	kubectl create ns stardog

	echo "Adding license"
	kubectl -n ${NAMESPACE} create secret generic stardog-license --from-file stardog-license-key.bin=${HOME}/stardog-license-key.bin
}

function helm_install_stardog_cluster_with_zookeeper() {
	echo "Installing Stardog Cluster"

	echo "Running helm install for ${HELM_RELEASE_NAME}"

	pushd charts/stardog/
	helm dependencies update
	popd

	helm install ${HELM_RELEASE_NAME} charts/stardog \
	             --namespace ${NAMESPACE} \
	             --wait \
	             --timeout 15m0s \
	             -f ./tests/minikube.yaml \
	             --set "replicaCount=${NUM_STARDOGS}" \
	             --set "zookeeper.replicaCount=${NUM_ZKS}" \
				 --debug
	rc=$?

	if [ ${rc} -ne 0 ]; then
		echo "Helm install for Stardog Cluster failed, exiting"
		echo "Listing pods"
		kubectl -n ${NAMESPACE} get pods
		echo "Listing services"
		kubectl -n ${NAMESPACE} get svc
		echo "Logs:"
		kubectl logs -n ${NAMESPACE} stardog-helm-tests-stardog-0
		echo "Previous logs:"
		kubectl logs -n ${NAMESPACE} stardog-helm-tests-stardog-0 --previous
		echo "Describe pod:"
		kubectl describe pod stardog-helm-tests-stardog-0 -n ${NAMESPACE}
		echo "Get jobs:"
		kubectl get jobs -n ${NAMESPACE}
		echo "helm list --all:"
		helm list --all -n ${NAMESPACE}
		exit ${rc}
	fi

	echo "Stardog Cluster installed."
}

function helm_install_single_node_stardog() {
	echo "Installing single node Stardog"

	echo "Running helm install for ${HELM_RELEASE_NAME}"

	pushd charts/stardog/
	helm dependencies update
	popd

	helm install ${HELM_RELEASE_NAME} charts/stardog \
	             --namespace ${NAMESPACE} \
	             --wait \
	             --timeout 15m0s \
	             -f ./tests/minikube.yaml \
	             --set "cluster.enabled=false" \
	             --set "replicaCount=1" \
	             --set "zookeeper.enabled=false"
	rc=$?

	if [ ${rc} -ne 0 ]; then
		echo "Helm install for Stardog Cluster failed, exiting"
		exit ${rc}
	fi

	echo "Single node Stardog installed."
}

function check_helm_release_exists() {
	echo "Checking if the Helm release exists"

	helm ls --namespace ${NAMESPACE} | grep ${HELM_RELEASE_NAME}
	rc=$?
	if [ ${rc} -ne 0 ]; then
		echo "The helm release ${HELM_RELEASE_NAME} is missing, exiting"
		exit ${rc}
	fi

	echo "The helm release exists."
}

function check_helm_release_deleted() {
	echo "Checking if the Helm release has been deleted"

	helm ls --namespace ${NAMESPACE} | grep ${HELM_RELEASE_NAME}
	rc=$?
	if [ ${rc} -eq 0 ]; then
		echo "The helm release ${HELM_RELEASE_NAME} wasn't deleted as expected, exiting"
		exit 1
	fi

	echo "The helm release has been deleted."
}

function check_expected_num_stardog_pods() {
  local -r num_stardogs=$1
	echo "Checking if there are the expected number of Stardog pods (${num_stardogs})"

	FOUND_STARDOGS=$(kubectl -n ${NAMESPACE} get pods -o wide | grep "${HELM_RELEASE_NAME}-stardog-" | wc -l)
	# the post install pod for stardog will match here too, but it may disappear before this check runs,
	# so either ${num_stardogs} or ${num_stardogs} + 1 is fine here
	if [[ ${FOUND_STARDOGS} -lt ${num_stardogs} || ${FOUND_STARDOGS} -gt $((num_stardogs+1)) ]]; then
		echo "Found ${FOUND_STARDOGS} but expected ${num_stardogs} Stardog pods, exiting"
		exit 1
	fi

	echo "Found the correct number of Stardog pods."
}

function check_expected_num_zk_pods() {
  local -r num_zookeepers=$1
	echo "Checking if there are the expected number of ZooKeeper pods (${num_zookeepers})"

	FOUND_ZKS=$(kubectl -n ${NAMESPACE} get pods -o wide | grep "${HELM_RELEASE_NAME}-zookeeper-" | wc -l)
	if [ ${FOUND_ZKS} -ne ${num_zookeepers} ]; then
		echo "Found ${FOUND_ZKS} but expected ${num_zookeepers} ZooKeeper pods, exiting"
		exit 1
	fi

	echo "Found the correct number of ZooKeeper pods."
}

function set_stardog_ip() {
	export STARDOG_IP=$(kubectl -n ${NAMESPACE} get svc | grep "${HELM_RELEASE_NAME}-stardog" | awk '{print $4}')
}

function download_db_data() {
	echo "Downloading sample data"
	mkdir -p ~/sample-data/
	pushd ~/sample-data/
	curl -fLo data.ttl https://raw.githubusercontent.com/stardog-union/stardog-tutorials/master/music/beatles.ttl
	rc=$?
	if [ ${rc} -ne 0 ]; then
		echo "Failed to download the sample data for loading. Ensure there is a file at the URL"
		exit ${rc}
	fi
	chmod +rx data.ttl
	popd
	echo "Sample data downloaded"
}

function create_db() {
	echo "Creating database on Stardog server ${STARDOG_IP}"
	${STARDOG_ADMIN} --server http://${STARDOG_IP}:5820 db create -n testdb --copy-server-side -- ~/sample-data/data.ttl
	rc=$?
	if [ ${rc} -ne 0 ]; then
		echo "Failed to create Stardog db on ${STARDOG_IP}, exiting"
		echo "Tunnel logs:"
		cat ~/minikube_tunnel.log
		echo "Tunnel error logs:"
		cat ~/minikube_tunnel.err
		exit ${rc}
	fi
	echo "Successfully created database."
}

function query_db() {
	echo "Executing SELECT * { ?s ?p ?o } on database testdb"
	${STARDOG_CLI} query execute http://${STARDOG_IP}:5820/testdb -f csv "SELECT * { ?s ?p ?o } ORDER BY ?s ?p ?o" > query_result
	pwd
	ls
	diff query_result /home/circleci/project/tests/valid_query_output.csv
	rc=$?
	if [ ${rc} -ne 0 ]; then
		echo "Query results did not match expected output, exiting"
		exit ${rc}
	fi
	echo "Successfully executed query"
}

function drop_db() {
	echo "Dropping database on Stardog server ${STARDOG_IP}"
	${STARDOG_ADMIN} --server http://${STARDOG_IP}:5820 db drop testdb
	rc=$?
	if [ ${rc} -ne 0 ]; then
		echo "Failed to drop Stardog db on ${STARDOG_IP}, exiting"
		exit ${rc}
	fi
	echo "Successfully dropped database."
}

function image_pull_secret_should_not_be_set_by_default() {
	statefulset_name=$(kubectl -n ${NAMESPACE} get sts --no-headers | grep stardog | awk '{print $1}')
	command_output=$(kubectl -n ${NAMESPACE} get sts -o yaml ${statefulset_name}) &&  echo ${command_output} | grep imagePullSecret
	rc=$?
	if [ ${rc} -ne 1 ]; then
		echo "imagePullSecret option was set, but should not be set on default settings."
		exit ${rc}
	fi
	echo "Success: imagePullSecret should not be set by default"
}

function helm_delete_stardog_release() {
	echo "Deleting Stardog release"

	helm delete ${HELM_RELEASE_NAME} --namespace ${NAMESPACE}
	rc=$?

	if [ ${rc} -ne 0 ]; then
		echo "Helm failed to delete Stardog release, exiting"
		exit ${rc}
	fi

	echo "Stardog release deleted."
}

function validate_helm_chart() {
	echo "Validating the helm chart"
	helm lint charts/stardog >/dev/null 2>&1 || { echo >&2 "The helm chart is not valid, exiting."; exit 1; }
	echo "Helm chart valid."
}

echo "Starting the Helm smoke tests"
validate_helm_chart
dependency_checks
minikube_start_tunnel
install_stardog
helm_setup_cluster

echo "Test: Stardog 3 node cluster with ZooKeeper"
helm_install_stardog_cluster_with_zookeeper
check_helm_release_exists
check_expected_num_stardog_pods ${NUM_STARDOGS}
check_expected_num_zk_pods ${NUM_ZKS}
set_stardog_ip
download_db_data
create_db
query_db
drop_db

echo "Testing chart configurations"
image_pull_secret_should_not_be_set_by_default

echo "Cleaning up Helm deployment"
helm_delete_stardog_release
check_helm_release_deleted

echo "Test: single node Stardog without ZooKeeper"
helm_install_single_node_stardog
check_helm_release_exists
check_expected_num_stardog_pods 1
check_expected_num_zk_pods 0

echo "Cleaning up Helm deployment"
helm_delete_stardog_release
check_helm_release_deleted

echo "Helm smoke tests completed."
