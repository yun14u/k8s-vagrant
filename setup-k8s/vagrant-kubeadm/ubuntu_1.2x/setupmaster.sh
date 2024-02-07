#!/bin/bash

echo "[TASK 1] Pull required containers"
kubeadm config images pull --kubernetes-version=1.27.10 >/dev/null 2>&1

echo "[TASK 2] Initialize Kubernetes Cluster"
#kubeadm init --apiserver-advertise-address=172.16.16.100 --pod-network-cidr=192.168.0.0/16 >> /root/kubeinit.log 2>/dev/null
#crio
kubeadm init --pod-network-cidr 10.244.0.0/16 --apiserver-advertise-address=192.168.56.2 --kubernetes-version=1.27.10 --cri-socket unix:///var/run/crio/crio.sock  >> /root/kubeinit.log

echo "[TASK 3] Setup kubectl"
mkdir -p $HOME/.kube
cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
chown $(id -u):$(id -g) $HOME/.kube/config

echo "[TASK 4] Deploy Calico network"
kubectl --kubeconfig=/etc/kubernetes/admin.conf create -f https://docs.projectcalico.org/v3.25/manifests/calico.yaml >/dev/null 2>&1

#echo "[TASK 4] Deploy Flannel network"
#curl -o kube-flannel.yml https://raw.githubusercontent.com/coreos/flannel/v0.9.1/Documentation/kube-flannel.yml
#sed -i.bak 's|"/opt/bin/flanneld",|"/opt/bin/flanneld", "--iface=enp0s8",|' kube-flannel.yml
#kubectl create -f kube-flannel.yml

echo "[TASK 5] Generate and save cluster join command to /joincluster.sh"
kubeadm token create --print-join-command > /joincluster.sh 2>/dev/null

echo "[TASK 6] Setup public key for workers to access master"
cp /var/tmp/keys/id_ecdsa.pub /root/.ssh/authorized_keys
chmod 600 ~/.ssh/authorized_keys
rm -rf /var/tmp/keys
