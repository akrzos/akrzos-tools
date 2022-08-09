#!/usr/bin/env bash

export KUBECONFIG=/root/bm/kubeconfig

echo "Check ACM multicluster-observability-operator"
oc get csv -n open-cluster-management advanced-cluster-management.v2.6.0 -o json |  jq '.spec.install.spec.deployments[] | select(.name=="multicluster-observability-operator").spec.template.spec.containers[] | select(.name=="multicluster-observability-operator").resources.limits.memory'
oc get deploy -n open-cluster-management multicluster-observability-operator -o json | jq '.spec.template.spec.containers[0].resources.limits.memory'

echo "Done"
