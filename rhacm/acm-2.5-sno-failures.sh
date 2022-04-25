#!/bin/bash

set -euxo pipefail

SCRIPT_DIR=$(dirname "$(readlink -f "$0")")

export KUBECONFIG=/root/bm/kubeconfig

mkdir /root/omer/manifests -p

cd /root/omer

# Dump kubeconfigs
ls /root/omer/manifests/ | xargs -I % sh -c "echo %; oc get secret %-admin-kubeconfig -n % -o json | jq -r '.data.kubeconfig' | base64 -d > /root/omer/manifests/%/kubeconfig"

# List failures
oc get aci -A -ojson | jq '.items[] | select((.status.conditions[] | select(.type == "Failed")).status == "True") | .metadata.name' -r > faillist

# Crashes
for cluster in $(cat faillist); do
	export KUBECONFIG=manifests/$cluster/kubeconfig
    if ! oc get pods 2>/dev/null >/dev/null; then
        if ssh core@$cluster sudo crictl logs $(ssh core@$cluster sudo crictl ps -a --name '^kube-apiserver$' -q 2>/dev/null | head -1) 2>&1 | grep "ca-bundle.crt: no such file or directory" -q; then
            echo Bz2017860 $cluster
            continue
        fi

        echo Offline $cluster
        continue
    fi
    if oc get pods -A | grep -E '(openshift-apiserver|openshift-authentication|openshift-oauth-apiserver)' | grep -q Crash; then
        echo BadOVN $cluster
        continue
    fi
	if oc get pods -A | grep openshift-authentication | grep -q Crash; then
        echo BadOVN $cluster
        continue
    fi
    if oc get pods -n openshift-authentication 2>/dev/null | grep -q ContainerCreating; then
        echo BadOVN $cluster
        continue
    fi
    if oc get co monitoring -ojson  | jq '.status.conditions[] | select(.type == "Degraded").message' -r | grep 'Grafna Deployment failed' -q; then
        echo BadOVN $cluster
        continue
    fi
	if oc get co machine-config  -ojson | jq '.status.conditions[] | select(.type=="Degraded").message' | grep -q "waitForControllerConfigToBeCompleted"; then
        echo WeirdMCO $cluster
        continue
    fi
	if oc get co machine-config  -ojson | jq '.status.conditions[] | select(.type=="Degraded").message' | grep -q "waitForDeploymentRollout"; then
        echo WeirdMCO2 $cluster
        continue
    fi
    if [[ $(oc get co -ojson | jq -r '[.items[] | select((.status.conditions[]? | select(.type == "Available").status) == "False").metadata.name] | length') == "1" && $(oc get co -ojson | jq -r '.items[] | select((.status.conditions[]? | select(.type == "Available").status) == "False").metadata.name') == "console" ]]; then
        echo BadConsole $cluster
        continue
    fi
    if ! oc logs -n openshift-kube-controller-manager kube-controller-manager-$cluster kube-controller-manager 2>/dev/null 1>/dev/null; then
        echo DeadKubeControllerManager $cluster
        continue
    fi
    if [[ $(oc get pods -A -ojson | jq '[.items[] | select(.status.phase == "Pending").metadata.name] | length') > 10 ]]; then
        echo BadOVNMaybe-LotsOfPending $cluster
        continue
    fi
    if [[ $(oc get co -ojson | jq -r '[.items[] | select((.status.conditions[]? | select(.type == "Available").status) == "False").metadata.name] | length') == "0" ]]; then
        echo EventuallyOkay $cluster
        continue
    fi
    echo Else $cluster
done
