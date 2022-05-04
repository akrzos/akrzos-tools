#!/usr/bin/env bash

export KUBECONFIG=/root/bm/kubeconfig

echo "Patching ACM multiclusterhub-operator memory limits to 16Gi"
oc get csv -n open-cluster-management advanced-cluster-management.v2.5.0 -o json |  jq '.spec.install.spec.deployments[] | select(.name=="multiclusterhub-operator").spec.template.spec.containers[] | select(.name=="multiclusterhub-operator").resources.limits.memory'
oc get deploy -n open-cluster-management multiclusterhub-operator -o json| jq '.spec.template.spec.containers[0].resources.limits.memory'
oc get csv -n open-cluster-management advanced-cluster-management.v2.5.0 -o json |  jq '.spec.install.spec.deployments[] |= (select(.name=="multiclusterhub-operator").spec.template.spec.containers[] |= (select(.name=="multiclusterhub-operator").resources.limits.memory = "16Gi"))' | oc apply -f -
oc get csv -n open-cluster-management advanced-cluster-management.v2.5.0 -o json |  jq '.spec.install.spec.deployments[] | select(.name=="multiclusterhub-operator").spec.template.spec.containers[] | select(.name=="multiclusterhub-operator").resources.limits.memory'
oc get deploy -n open-cluster-management multiclusterhub-operator -o json| jq '.spec.template.spec.containers[0].resources.limits.memory'
echo "Sleep 45"
sleep 45

echo "Patching ACM multicluster-operators-application multicluster-operators-placementrule memory limits to 2Gi"
oc get csv -n open-cluster-management advanced-cluster-management.v2.5.0 -o json |  jq '.spec.install.spec.deployments[] | select(.name=="multicluster-operators-application").spec.template.spec.containers[] | select(.name=="multicluster-operators-placementrule").resources.limits.memory'
oc get csv -n open-cluster-management advanced-cluster-management.v2.5.0 -o json |  jq '.spec.install.spec.deployments[] |= (select(.name=="multicluster-operators-application").spec.template.spec.containers[] |= (select(.name=="multicluster-operators-placementrule").resources.limits.memory = "2Gi"))' | oc apply -f -
oc get csv -n open-cluster-management advanced-cluster-management.v2.5.0 -o json |  jq '.spec.install.spec.deployments[] | select(.name=="multicluster-operators-application").spec.template.spec.containers[] | select(.name=="multicluster-operators-placementrule").resources.limits.memory'
echo "Sleep 45"
sleep 45

echo "Patching ACM search-collector memory limits to 16Gi"
oc get deploy -n open-cluster-management -l component=search-collector -o json | jq '.items[0].spec.template.spec.containers[0].resources.limits.memory'
oc annotate mch -n open-cluster-management multiclusterhub pause=true
oc get deploy -n open-cluster-management -l component=search-collector -o json | jq '.items[0].spec.template.spec.containers[0].resources.limits.memory = "16Gi"' | oc apply -f -
oc get deploy -n open-cluster-management -l component=search-collector -o json | jq '.items[0].spec.template.spec.containers[0].resources.limits.memory'
echo "Sleep 45"
sleep 45

echo "Patching multicluster-engine ocm-controller memory limits to 16Gi"
oc get deploy -n multicluster-engine ocm-controller -o json |  jq '.spec.template.spec.containers[0].resources.limits.memory'
oc annotate multiclusterengine multiclusterengine pause=true
oc get deploy -n multicluster-engine ocm-controller -o json |  jq '.spec.template.spec.containers[0].resources.limits.memory = "16Gi"' | oc apply -f -
oc get deploy -n multicluster-engine ocm-controller -o json |  jq '.spec.template.spec.containers[0].resources.limits.memory'
echo "Done Patching"
