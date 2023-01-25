#!/usr/bin/env bash

export KUBECONFIG=/root/bm/kubeconfig

echo "Patching MCE managedcluster-import-controller-v2 memory limits to 16Gi"
oc get deploy -n multicluster-engine managedcluster-import-controller-v2 -o json | jq '.spec.template.spec.containers[0].resources.limits.memory'
oc annotate multiclusterengine multiclusterengine pause=true
oc get deploy -n multicluster-engine managedcluster-import-controller-v2 -o json |  jq '.spec.template.spec.containers[0].resources.limits.memory = "16Gi"' | oc replace -f -
oc get deploy -n multicluster-engine managedcluster-import-controller-v2 -o json | jq '.spec.template.spec.containers[0].resources.limits.memory'
echo "Sleep 45"
sleep 45

echo "Patching MCE ocm-webhook memory limits to 4Gi"
oc get deploy -n multicluster-engine ocm-webhook -o json | jq '.spec.template.spec.containers[0].resources.limits.memory'
oc get deploy -n multicluster-engine ocm-webhook -o json |  jq '.spec.template.spec.containers[0].resources.limits.memory = "4Gi"' | oc replace -f -
oc get deploy -n multicluster-engine ocm-webhook -o json | jq '.spec.template.spec.containers[0].resources.limits.memory'
echo "Sleep 45"
sleep 45

#echo "Patching ACM multicluster-operators-application multicluster-operators-placementrule memory limits to 4Gi"
#oc annotate mch -n open-cluster-management multiclusterhub mch-pause=True
#oc get deploy -n open-cluster-management multicluster-operators-application -o json |  jq '.spec.template.spec.containers[] | select(.name=="multicluster-operators-placementrule").resources.limits.memory'
#oc get deploy -n open-cluster-management multicluster-operators-application -o json |  jq '.spec.template.spec.containers[] |= (select(.name=="multicluster-operators-placementrule").resources.limits.memory = "4Gi")' | oc replace -f -
#oc get deploy -n open-cluster-management multicluster-operators-application -o json |  jq '.spec.template.spec.containers[] | select(.name=="multicluster-operators-placementrule").resources.limits.memory'
#echo "Sleep 45"
#sleep 45

# Method when placement rules container is in the CSV
echo "Patching ACM multicluster-operators-application multicluster-operators-placementrule memory limits to 2Gi"
oc get csv -n open-cluster-management advanced-cluster-management.v2.6.3 -o json |  jq '.spec.install.spec.deployments[] | select(.name=="multicluster-operators-application").spec.template.spec.containers[] | select(.name=="multicluster-operators-placementrule").resources.limits.memory'
oc get deploy -n open-cluster-management multicluster-operators-application -o json |  jq '.spec.template.spec.containers[] | select(.name=="multicluster-operators-placementrule").resources.limits.memory'
oc get csv -n open-cluster-management advanced-cluster-management.v2.6.3 -o json |  jq '.spec.install.spec.deployments[] |= (select(.name=="multicluster-operators-application").spec.template.spec.containers[] |= (select(.name=="multicluster-operators-placementrule").resources.limits.memory = "2Gi"))' | oc replace -f -
oc get csv -n open-cluster-management advanced-cluster-management.v2.6.3 -o json |  jq '.spec.install.spec.deployments[] | select(.name=="multicluster-operators-application").spec.template.spec.containers[] | select(.name=="multicluster-operators-placementrule").resources.limits.memory'
oc get deploy -n open-cluster-management multicluster-operators-application -o json |  jq '.spec.template.spec.containers[] | select(.name=="multicluster-operators-placementrule").resources.limits.memory'
echo "Sleep 45"
sleep 45

echo "Done Patching"
