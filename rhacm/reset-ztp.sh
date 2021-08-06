#!/bin/bash
for bmh in `oc get bmh --all-namespaces -ojsonpath='{range .items[*]}{.metadata.name}{"\n"}' | grep "^sno"` ; do
  oc delete bmh $bmh -n $bmh --wait=false
done
sleep 30
for bmh in `oc get bmh --all-namespaces -ojsonpath='{range .items[*]}{.metadata.name}{"\n"}' | grep "^sno"` ; do
  oc patch bmh $bmh -n $bmh -p '{"metadata":{"finalizers":[]}}' --type=merge
done
for cd in `oc get clusterdeployment --all-namespaces -ojsonpath='{range .items[*]}{.metadata.name}{"\n"}' | grep "^sno"` ; do
  oc delete clusterdeployment $cd -n $cd  --wait=false
done
for mc in `oc get managedcluster -ojsonpath='{range .items[*]}{.metadata.name}{"\n"}' | grep "^sno"`; do
  oc patch managedcluster $mc -n $mc -p '{"metadata":{"finalizers":[]}}' --type=merge
  oc delete managedcluster $mc --wait=false
done
for cd in `oc get klusterletaddonconfigs --all-namespaces -ojsonpath='{range .items[*]}{.metadata.name}{"\n"}' | grep "^sno"` ; do
  oc patch klusterletaddonconfigs $cd -n $cd -p '{"metadata":{"finalizers":[]}}' --type=merge
done

for cd in `oc get manifestworks --all-namespaces -ojsonpath='{range .items[*]}{.metadata.namespace}{"\n"}' | grep "^sno"` ; do
  oc patch manifestwork ${cd}-klusterlet -n $cd -p '{"metadata":{"finalizers":[]}}' --type=merge
  oc patch manifestwork ${cd}-klusterlet-crds -n $cd -p '{"metadata":{"finalizers":[]}}' --type=merge
  oc patch manifestwork ${cd}-klusterlet-addon-crds -n $cd -p '{"metadata":{"finalizers":[]}}' --type=merge
  oc patch manifestwork ${cd}-klusterlet-addon-operator -n $cd -p '{"metadata":{"finalizers":[]}}' --type=merge
  oc patch manifestwork ${cd}-klusterlet-addon-workmgr -n $cd -p '{"metadata":{"finalizers":[]}}' --type=merge
  oc patch manifestwork ${cd}-klusterlet-addon-policyctrl -n $cd -p '{"metadata":{"finalizers":[]}}' --type=merge
done
sleep 30
for cd in `oc get clusterdeployment --all-namespaces -ojsonpath='{range .items[*]}{.metadata.name}{"\n"}' | grep "^sno"` ; do
  oc patch clusterdeployment $cd -n $cd -p '{"metadata":{"finalizers":[]}}' --type=merge
done
for cd in `oc get agentclusterinstall --all-namespaces -ojsonpath='{range .items[*]}{.metadata.name}{"\n"}' | grep "^sno"` ; do
  oc patch agentclusterinstall $cd -n $cd -p '{"metadata":{"finalizers":[]}}' --type=merge
done
for ns in `oc get ns -ojsonpath='{range .items[*]}{.metadata.name}{"\n"}' | grep "^sno"`; do
  oc delete ns $ns --wait=false
done
