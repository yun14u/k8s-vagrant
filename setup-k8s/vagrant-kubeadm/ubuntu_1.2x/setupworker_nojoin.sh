#!/bin/bash

echo "[TASK 1] Prepare SSH key to Kubernetes Cluster"
cp /var/tmp/keys/id_ecdsa ~/.ssh/id_ecdsa
chmod 400 ~/.ssh/id_ecdsa
echo "@master: kubeadm kubeadm token create --print-join-command "

#echo "[TASK 2] Get script to join Cluster"
#scp -v -i ~/.ssh/id_ecdsa -o StrictHostKeyChecking=no root@192.168.56.2:/joincluster.sh /joincluster.sh

#echo "[Task 4] Join the cluster"
#bash /joincluster.sh
#echo "@master: kubectl label node $(hostname -s)  node-role.kubernetes.io/worker=worker"
