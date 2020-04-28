#!/bin/bash

set +x

HELM_RELEASE_NAME="stardog-helm-tests"
NAMESPACE="stardog"
NUM_STARDOGS="3"
NUM_ZKS="3"

STARDOG_ADMIN=
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
	echo "sudo minikube tunnel" > ~/start-minikube-tunnel.sh
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
	popd
}

function helm_install_stardog_cluster() {
	echo "Installing Stardog Cluster"

	echo "Creating stardog namespace"
	kubectl create ns stardog

	echo "Adding license"
	kubectl -n ${NAMESPACE} create secret generic stardog-license --from-file stardog-license-key.bin=${HOME}/stardog-license-key.bin

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
	             --set "zookeeper.replicaCount=${NUM_ZKS}"
	rc=$?

	if [ ${rc} -ne 0 ]; then
		echo "Helm install for Stardog Cluster failed, exiting"
		exit ${rc}
	fi

	echo "Stardog Cluster installed."
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
	echo "Checking if there are the expected number of Stardog pods (${NUM_STARDOGS})"

	FOUND_STARDOGS=$(kubectl -n ${NAMESPACE} get pods -o wide | grep "${HELM_RELEASE_NAME}-stardog-" | wc -l)
	if [ ${FOUND_STARDOGS} -ne ${NUM_STARDOGS} ]; then
		echo "Found ${FOUND_STARDOGS} but expected ${NUM_STARDOGS} Stardog pods, exiting"
		exit 1
	fi

	echo "Found the correct number of Stardog pods."
}

function check_expected_num_zk_pods() {
	echo "Checking if there are the expected number of ZooKeeper pods (${NUM_ZKS})"

	FOUND_ZKS=$(kubectl -n ${NAMESPACE} get pods -o wide | grep "${HELM_RELEASE_NAME}-zookeeper-" | wc -l)
	if [ ${FOUND_ZKS} -ne ${NUM_ZKS} ]; then
		echo "Found ${FOUND_ZKS} but expected ${NUM_ZKS} ZooKeeper pods, exiting"
		exit 1
	fi

	echo "Found the correct number of ZooKeeper pods."
}

function set_stardog_ip() {
	export STARDOG_IP=$(kubectl -n ${NAMESPACE} get svc | grep "${HELM_RELEASE_NAME}-stardog" | awk '{print $4}')
}

function create_and_drop_db() {
	echo "Creating database on Stardog server ${STARDOG_IP}"
	${STARDOG_ADMIN} --server http://${STARDOG_IP}:5820 db create -n testdb
	rc=$?
	if [ ${rc} -ne 0 ]; then
		echo "Failed to create Stardog db on ${STARDOG_IP}, exiting"
		exit ${rc}
	fi
	echo "Successfully created database."


	echo "Dropping database on Stardog server ${STARDOG_IP}"
	${STARDOG_ADMIN} --server http://${STARDOG_IP}:5820 db drop testdb
	rc=$?
	if [ ${rc} -ne 0 ]; then
		echo "Failed to drop Stardog db on ${STARDOG_IP}, exiting"
		exit ${rc}
	fi
	echo "Successfully dropped database."
}

function helm_delete_stardog_cluster() {
	echo "Deleting Stardog Cluster"

	helm delete ${HELM_RELEASE_NAME} --namespace ${NAMESPACE}
	rc=$?

	if [ ${rc} -ne 0 ]; then
		echo "Helm failed to delete Stardog Cluster, exiting"
		exit ${rc}
	fi

	echo "Stardog Cluster deleted."
}

echo "Starting the Helm smoke tests"
dependency_checks
minikube_start_tunnel
install_stardog
helm_install_stardog_cluster
check_helm_release_exists
check_expected_num_stardog_pods
check_expected_num_zk_pods
set_stardog_ip

echo "Running Stardog tests"
create_and_drop_db

echo "Cleaning up Helm deployment"
helm_delete_stardog_cluster
check_helm_release_deleted

echo "Helm smoke tests completed."
