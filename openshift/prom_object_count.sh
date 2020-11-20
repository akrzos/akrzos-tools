#!/bin/bash

for i in $(seq -f "%04g" 0 56); do
  echo "------------- shiftstack${i}"
  KUBECONFIG="--kubeconfig=/home/stack/ocp_clusters/shiftstack${i}/auth/kubeconfig"
  MASTER0_IP=$(oc ${KUBECONFIG} get no -l node-role.kubernetes.io/master= -o json | jq -r '.items[0].status.addresses[0].address')
  MASTER1_IP=$(oc ${KUBECONFIG} get no -l node-role.kubernetes.io/master= -o json | jq -r '.items[1].status.addresses[0].address')
  MASTER2_IP=$(oc ${KUBECONFIG} get no -l node-role.kubernetes.io/master= -o json | jq -r '.items[2].status.addresses[0].address')
  ROUTE=$(oc ${KUBECONFIG} -n openshift-monitoring get route thanos-querier -o jsonpath="{.spec.host}")
  ENDPOINT="https://${ROUTE}"
  PROM_TOKEN_NAME=$(oc ${KUBECONFIG}  -n openshift-monitoring get serviceaccount prometheus-k8s -o jsonpath='{range .secrets[*]} {.name} {"\n"} {end}' | grep prometheus-k8s-token)
  TOKEN=$(oc ${KUBECONFIG} -n openshift-monitoring get secret ${PROM_TOKEN_NAME} -o go-template='{{.data.token | base64decode}}')

  # sum(etcd_object_counts{instance="10.196.0.224:6443"})
  master0_counts=$(curl -sLk -H "Authorization: Bearer ${TOKEN}" "${ENDPOINT}/api/v1/query?query=sum(etcd_object_counts%7Binstance%3D%22${MASTER0_IP}%3A6443%22%7D)")
  master1_counts=$(curl -sLk -H "Authorization: Bearer ${TOKEN}" "${ENDPOINT}/api/v1/query?query=sum(etcd_object_counts%7Binstance%3D%22${MASTER1_IP}%3A6443%22%7D)")
  master2_counts=$(curl -sLk -H "Authorization: Bearer ${TOKEN}" "${ENDPOINT}/api/v1/query?query=sum(etcd_object_counts%7Binstance%3D%22${MASTER2_IP}%3A6443%22%7D)")

  # etcd_object_counts{resource="deployments.apps"}
  #deployment_count=$(curl -sLk -H "Authorization: Bearer ${TOKEN}" "${ENDPOINT}/api/v1/query?query=etcd_object_counts%7Bresource%3D%22deployments.apps%22%7D")
  #echo "${deployment_count}" | jq -r '.data.result[0].value[1]'



  master0_counts_value=$(echo "${master0_counts}" | jq -r '.data.result[0].value[1]')
  master1_counts_value=$(echo "${master1_counts}" | jq -r '.data.result[0].value[1]')
  master2_counts_value=$(echo "${master2_counts}" | jq -r '.data.result[0].value[1]')
  echo "${MASTER0_IP}  ${master0_counts_value}"
  #echo "${master0_counts}" | jq -r '.data.result[0].value[1]'
  echo "${MASTER1_IP}  ${master1_counts_value}"
  #echo "${master1_counts}" | jq -r '.data.result[0].value[1]'
  echo "${MASTER2_IP}  ${master2_counts_value}"
  #echo "${master2_counts}" | jq -r '.data.result[0].value[1]'
done
date -u
