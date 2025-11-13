#!/bin/bash

echo "[TASK 1] Prepare SSH key to Kubernetes Cluster"
cp /var/tmp/keys/id_ecdsa.pub /root/.ssh/authorized_keys
chmod 400 ~/.ssh/authorized_keys
cp /var/tmp/keys/id_ecdsa /root/.ssh
chmod 400 /root/.ssh/id_ecdsa

echo "[TASK 2] Get script to join Cluster"
#scp -v -i ~/.ssh/id_ecdsa -o StrictHostKeyChecking=no root@192.168.56.52:/joincluster.sh /joincluster.sh
scp -v -i ~/.ssh/id_ecdsa -o StrictHostKeyChecking=no root@192.168.68.241:/joincluster.sh /joincluster.sh

echo "[Task 4] Join the cluster"
bash /joincluster.sh
echo "@master: kubectl label node $(hostname -s)  node-role.kubernetes.io/worker=worker"
