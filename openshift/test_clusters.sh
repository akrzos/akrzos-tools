#!/usr/bin/env bash

total_ready_nodes=0
total_not_ready_nodes=0

date -u

echo "------------- vlan608"
ready_nodes=$(oc --kubeconfig=/home/stack/ocp_clusters/vlan608/auth/kubeconfig get --no-headers no | grep 'Ready' -i -c)
not_ready_nodes=$(oc --kubeconfig=/home/stack/ocp_clusters/vlan608/auth/kubeconfig get --no-headers no | grep 'NotReady' -i -c)
echo "Nodes Ready:: Not_ready: ${ready_nodes} :: ${not_ready_nodes}"

echo "Pods:"
oc --kubeconfig=/home/stack/ocp_clusters/vlan608/auth/kubeconfig get po --all-namespaces --no-headers | awk '{print $4}' | sort | uniq -c
oc --kubeconfig=/home/stack/ocp_clusters/vlan608/auth/kubeconfig get po --all-namespaces --no-headers | egrep -v -i 'Running|Completed'

#for i in $(seq -f "%04g" 0 56) ; do
for i in $(seq -f "%04g" 0 56) ; do
  echo "------------- shiftstack${i}"

  ready_nodes=$(oc --kubeconfig=/home/stack/ocp_clusters/shiftstack${i}/auth/kubeconfig get --no-headers no | grep 'Ready' -i -c)
  not_ready_nodes=$(oc --kubeconfig=/home/stack/ocp_clusters/shiftstack${i}/auth/kubeconfig get --no-headers no | grep 'NotReady' -i -c)
  total_ready_nodes=$(($ready_nodes + $total_ready_nodes))
  total_not_ready_nodes=$(($not_ready_nodes + $total_not_ready_nodes))
  echo "Nodes Ready:: Not_ready: ${ready_nodes} :: ${not_ready_nodes}"

  echo "Pods:"
  oc --kubeconfig=/home/stack/ocp_clusters/shiftstack${i}/auth/kubeconfig get po --all-namespaces --no-headers | awk '{print $4}' | sort | uniq -c
  oc --kubeconfig=/home/stack/ocp_clusters/shiftstack${i}/auth/kubeconfig get po --all-namespaces --no-headers | egrep -v -i 'Running|Completed'
  #oc --kubeconfig=/home/stack/ocp_clusters/shiftstack${i}/auth/kubeconfig get clusteroperators
  #oc --kubeconfig=/home/stack/ocp_clusters/shiftstack${i}/auth/kubeconfig get clusteroperators | grep monitoring
done
date -u
echo "------------- Total"
echo "Nodes Ready :: Not_ready: ${total_ready_nodes} :: ${total_not_ready_nodes}"
