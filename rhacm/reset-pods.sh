#!/bin/bash

oc delete po -n open-cluster-management -l app=assisted-service
oc delete po -n openshift-machine-api -l baremetal.openshift.io/cluster-baremetal-operator=metal3-state
oc delete po -n openshift-machine-api -l baremetal.openshift.io/cluster-baremetal-operator=metal3-image-cache
