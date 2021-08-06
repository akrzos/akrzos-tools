#!/usr/bin/env bash

base_dir=`pwd`
log="$(pwd)/repeat-$(date -u +%Y%m%d-%H%M%S).log"

for iter in `seq 0 10 350`; do
  echo "------------------------------------------------" 2>&1 | tee -a $log
  echo "$(date -u +%Y%m%d-%H%M%S) Working on iteration ${iter}" 2>&1 | tee -a $log
  echo "------------------------------------------------" 2>&1 | tee -a $log

  pushd /root/akrzos/virtual-baremetal-sno-host-prep
  ansible-playbook -i inventory ansible/02-create-many-vms.yml -e "vm_index_offset=${iter}" 2>&1 | tee -a $log
  popd

  pushd /root/akrzos/assisted-installer-batch-deploy-tool
  ./create-manifests.sh  /root/bm/vm_inventory.csv /opt/registry/pull-secret-disconnected.txt /root/.ssh/id_rsa 2>&1 | tee -a $log
  ./apply-manifests.sh /root/akrzos/kubeconfig 1 60 /root/bm/vm_inventory.csv 1 5 2>&1 | tee -a $log
  popd

  echo "$(date -u +%Y%m%d-%H%M%S) sleeping 600s, waiting for provisioning to start" 2>&1 | tee -a $log
  sleep 600

  agentclusterinstall_readyforinstallation=$(oc get agentclusterinstall -A --no-headers -o custom-columns=READY:'.status.conditions[?(@.type=="Completed")].reason',name:'.metadata.name')
  provisioning=$(echo "$agentclusterinstall_readyforinstallation" | grep -c InstallationInProgress | tr -d " ")
  loops=0
  while [ $provisioning -gt 0 ]; do
    echo "$(date -u +%Y%m%d-%H%M%S) Waiting for agents to finish provisioning: ${provisioning}"  2>&1 | tee -a $log
    sleep 30
    agentclusterinstall_readyforinstallation=$(oc get agentclusterinstall -A --no-headers -o custom-columns=READY:'.status.conditions[?(@.type=="Completed")].reason',name:'.metadata.name')
    provisioning=$(echo "$agentclusterinstall_readyforinstallation" | grep -c InstallationInProgress | tr -d " ")
    loops=$((loops+1))
    if [ $loops -gt 240 ]; then
      echo "$(date -u +%Y%m%d-%H%M%S) Breaking loop due to time (240 loops ~= 2 hours)"  2>&1 | tee -a $log
      break
    fi
  done

  echo "------------------------------------------------" 2>&1 | tee -a $log
  echo "$(date -u +%Y%m%d-%H%M%S) Finished on iteration ${iter}" 2>&1 | tee -a $log
  echo "------------------------------------------------" 2>&1 | tee -a $log
  echo "$(date -u +%Y%m%d-%H%M%S) sleeping 600s" 2>&1 | tee -a $log
  sleep 600

  pushd /root/akrzos/virtual-baremetal-sno-host-prep
  ansible-playbook -i inventory ansible/03-cleanup-many-vms.yml -e "vm_index_offset=${iter}" 2>&1 | tee -a $log
  popd
done
