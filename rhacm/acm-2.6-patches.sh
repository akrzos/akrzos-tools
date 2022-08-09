#!/usr/bin/env bash

export KUBECONFIG=/root/bm/kubeconfig

echo "Patching ACM multicluster-observability-operator memory limits from 1Gi to 2Gi"
oc get csv -n open-cluster-management advanced-cluster-management.v2.6.0 -o json |  jq '.spec.install.spec.deployments[] | select(.name=="multicluster-observability-operator").spec.template.spec.containers[] | select(.name=="multicluster-observability-operator").resources.limits.memory'
oc get deploy -n open-cluster-management multicluster-observability-operator -o json | jq '.spec.template.spec.containers[0].resources.limits.memory'
oc get csv -n open-cluster-management advanced-cluster-management.v2.6.0 -o json |  jq '.spec.install.spec.deployments[] |= (select(.name=="multicluster-observability-operator").spec.template.spec.containers[] |= (select(.name=="multicluster-observability-operator").resources.limits.memory = "2Gi"))' | oc replace -f -
echo "Sleep 45"
sleep 45
oc get csv -n open-cluster-management advanced-cluster-management.v2.6.0 -o json |  jq '.spec.install.spec.deployments[] | select(.name=="multicluster-observability-operator").spec.template.spec.containers[] | select(.name=="multicluster-observability-operator").resources.limits.memory'
oc get deploy -n open-cluster-management multicluster-observability-operator -o json | jq '.spec.template.spec.containers[0].resources.limits.memory'
echo "Patched ACM multicluster-observability-operator memory limits"

echo "Done Patching"

# echo "Patching ACM search-redisgraph memory limits from 4Gi to 16Gi"
# oc get sts -n open-cluster-management search-redisgraph -o json | jq '.spec.template.spec.containers[0].resources.limits.memory'
# oc annotate mch -n open-cluster-management multiclusterhub mch-pause=true
# sleep 15
# oc annotate mce multiclusterengine pause=true
# oc annotate mch -n open-cluster-management multiclusterhub pause=true
# oc annotate mce multiclusterengine pause=true
# oc get sts -n open-cluster-management search-redisgraph -o json | jq '.spec.template.spec.containers[0].resources.limits.memory = "16Gi"' | oc replace -f -
# oc get sts -n open-cluster-management search-redisgraph -o json | jq '.spec.template.spec.containers[0].resources.limits.memory'
