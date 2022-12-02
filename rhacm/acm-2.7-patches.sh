#!/usr/bin/env bash

export KUBECONFIG=/root/bm/kubeconfig

echo "Patching MCE managedcluster-import-controller-v2 memory limits to 16Gi"
oc get deploy -n multicluster-engine managedcluster-import-controller-v2 -o json | jq '.spec.template.spec.containers[0].resources.limits.memory'
oc annotate multiclusterengine multiclusterengine pause=true
oc get deploy -n multicluster-engine managedcluster-import-controller-v2 -o json |  jq '.spec.template.spec.containers[0].resources.limits.memory = "16Gi"' | oc replace -f -
oc get deploy -n multicluster-engine managedcluster-import-controller-v2 -o json | jq '.spec.template.spec.containers[0].resources.limits.memory'
echo "Done Patching"

echo "Patching MCE ocm-webhook memory limits to 4Gi"
oc get deploy -n multicluster-engine ocm-webhook -o json | jq '.spec.template.spec.containers[0].resources.limits.memory'
oc get deploy -n multicluster-engine ocm-webhook -o json |  jq '.spec.template.spec.containers[0].resources.limits.memory = "4Gi"' | oc replace -f -
oc get deploy -n multicluster-engine ocm-webhook -o json | jq '.spec.template.spec.containers[0].resources.limits.memory'
echo "Done Patching"
