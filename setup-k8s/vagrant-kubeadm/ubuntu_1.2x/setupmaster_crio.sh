#!/bin/bash
VERSION=1.29.15
echo "[TASK 1] Pull required containers"
kubeadm config images pull --kubernetes-version=${VERSION} >/dev/null 2>&1

echo "[TASK 2] Initialize Kubernetes Cluster"
#crio
kubeadm init --pod-network-cidr 10.244.0.0/16 --apiserver-advertise-address=192.168.56.2 --kubernetes-version=${VERSION} --cri-socket unix:///var/run/crio/crio.sock  >> /root/kubeinit.log

echo "[TASK 3] Setup kubectl"
mkdir -p $HOME/.kube
cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
chown $(id -u):$(id -g) $HOME/.kube/config

echo "[TASK 4] Deploy Flannel network"
kubectl create -f /var/tmp/flannel/kube-flannel.yml

echo "[TASK 5] Generate and save cluster join command to /joincluster.sh"
kubeadm token create --print-join-command > /joincluster.sh 2>/dev/null

echo "[TASK 6] Setup public key for workers to access master"
cp /var/tmp/keys/id_ecdsa.pub /root/.ssh/authorized_keys
chmod 600 ~/.ssh/authorized_keys
rm -rf /var/tmp/keys
