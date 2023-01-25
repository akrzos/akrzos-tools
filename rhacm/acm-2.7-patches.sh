#!/usr/bin/env bash

export KUBECONFIG=/root/bm/kubeconfig

# Fixed - https://issues.redhat.com/browse/ACM-2275
# echo "Patching MCE managedcluster-import-controller-v2 memory limits to 16Gi"
# oc get deploy -n multicluster-engine managedcluster-import-controller-v2 -o json | jq '.spec.template.spec.containers[0].resources.limits.memory'
# oc annotate multiclusterengine multiclusterengine pause=true
# oc get deploy -n multicluster-engine managedcluster-import-controller-v2 -o json |  jq '.spec.template.spec.containers[0].resources.limits.memory = "16Gi"' | oc replace -f -
# oc get deploy -n multicluster-engine managedcluster-import-controller-v2 -o json | jq '.spec.template.spec.containers[0].resources.limits.memory'
# echo "Sleep 45"
# sleep 45

# Fixed - https://issues.redhat.com/browse/ACM-2305
# echo "Patching MCE ocm-webhook memory limits to 4Gi"
# oc get deploy -n multicluster-engine ocm-webhook -o json | jq '.spec.template.spec.containers[0].resources.limits.memory'
# oc get deploy -n multicluster-engine ocm-webhook -o json |  jq '.spec.template.spec.containers[0].resources.limits.memory = "4Gi"' | oc replace -f -
# oc get deploy -n multicluster-engine ocm-webhook -o json | jq '.spec.template.spec.containers[0].resources.limits.memory'
# echo "Sleep 45"
# sleep 45

echo "Applying ACM search-v2-operator collector resources bump"
oc patch search -n open-cluster-management search-v2-operator --type json -p '[{"op": "add", "path": "/spec/deployments/collector/resources", "value": {"limits": {"memory": "16Gi", "cpu": "2"}, "requests": {"memory": "32Mi", "cpu": "25m"}}}]'
echo "Sleep 10"
sleep 10
echo "Applying ACM search-v2-operator indexer resources bump"
oc patch search -n open-cluster-management search-v2-operator --type json -p '[{"op": "add", "path": "/spec/deployments/indexer/resources", "value": {"limits": {"memory": "16Gi"}, "requests": {"memory": "32Mi", "cpu": "25m"}}}]'
echo "Sleep 10"
sleep 10

# https://issues.redhat.com/browse/ACM-2774
echo "Patching ACM grc-policy-propagator image"
oc annotate mch -n open-cluster-management multiclusterhub mch-pause=True
oc get deploy -n open-cluster-management grc-policy-propagator -o json |  jq '.spec.template.spec.containers[] | select(.name=="governance-policy-propagator").image'
oc get deploy -n open-cluster-management grc-policy-propagator -o json |  jq '.spec.template.spec.containers[] |= (select(.name=="governance-policy-propagator").image = "e27-h01-000-r650.rdu2.scalelab.redhat.com:5000/stolostron/governance-policy-propagator:perf_fix_1")' | oc replace -f -
oc get deploy -n open-cluster-management grc-policy-propagator -o json |  jq '.spec.template.spec.containers[] | select(.name=="governance-policy-propagator").image'
# echo "Sleep 45"

# Fixed - https://issues.redhat.com/browse/ACM-2336
# echo "Patching ACM multicluster-operators-application multicluster-operators-placementrule memory limits to 4Gi"
# oc annotate mch -n open-cluster-management multiclusterhub mch-pause=True
# oc get deploy -n open-cluster-management multicluster-operators-application -o json |  jq '.spec.template.spec.containers[] | select(.name=="multicluster-operators-placementrule").resources.limits.memory'
# oc get deploy -n open-cluster-management multicluster-operators-application -o json |  jq '.spec.template.spec.containers[] |= (select(.name=="multicluster-operators-placementrule").resources.limits.memory = "4Gi")' | oc replace -f -
# oc get deploy -n open-cluster-management multicluster-operators-application -o json |  jq '.spec.template.spec.containers[] | select(.name=="multicluster-operators-placementrule").resources.limits.memory'
# echo "Sleep 45"
# sleep 45

# Method when placement rules container is in the CSV
# echo "Patching ACM multicluster-operators-application multicluster-operators-placementrule memory limits to 2Gi"
# oc get csv -n open-cluster-management advanced-cluster-management.v2.7.0 -o json |  jq '.spec.install.spec.deployments[] | select(.name=="multicluster-operators-application").spec.template.spec.containers[] | select(.name=="multicluster-operators-placementrule").resources.limits.memory'
# oc get deploy -n open-cluster-management multicluster-operators-application -o json |  jq '.spec.template.spec.containers[] | select(.name=="multicluster-operators-placementrule").resources.limits.memory'
# oc get csv -n open-cluster-management advanced-cluster-management.v2.7.0 -o json |  jq '.spec.install.spec.deployments[] |= (select(.name=="multicluster-operators-application").spec.template.spec.containers[] |= (select(.name=="multicluster-operators-placementrule").resources.limits.memory = "2Gi"))' | oc replace -f -
# oc get csv -n open-cluster-management advanced-cluster-management.v2.7.0 -o json |  jq '.spec.install.spec.deployments[] | select(.name=="multicluster-operators-application").spec.template.spec.containers[] | select(.name=="multicluster-operators-placementrule").resources.limits.memory'
# oc get deploy -n open-cluster-management multicluster-operators-application -o json |  jq '.spec.template.spec.containers[] | select(.name=="multicluster-operators-placementrule").resources.limits.memory'
# echo "Sleep 45"
# sleep 45

echo "Done Patching"
