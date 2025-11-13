#!/bin/bash
VERSION=1.32.9
echo "[TASK 1] Pull required containers"
kubeadm config images pull --kubernetes-version=${VERSION} >/dev/null 2>&1

echo "[TASK 2] Initialize Kubernetes Cluster -> 192.168.68.x"
#crio
#kubeadm init --pod-network-cidr 10.244.0.0/16 --apiserver-advertise-address=192.168.56.52 --kubernetes-version=${VERSION} --cri-socket unix:///var/run/crio/crio.sock  >> /root/kubeinit.log
#containerd
# private subnet (192.68.56.x)
#kubeadm init --pod-network-cidr 10.244.0.0/16 --apiserver-advertise-address=192.168.56.52 --kubernetes-version=${VERSION} --cri-socket unix:///run/containerd/containerd.sock >> /root/kubeinit.log
# private subnet (192.68.68.x)
kubeadm init --pod-network-cidr 10.244.0.0/16 --apiserver-advertise-address=192.168.68.241 --kubernetes-version=${VERSION} --cri-socket unix:///run/containerd/containerd.sock >> /root/kubeinit.log
echo "[TASK 3] Setup kubectl"
mkdir -p $HOME/.kube
cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
chown $(id -u):$(id -g) $HOME/.kube/config

#echo "[TASK 4a] Deploy Flannel CNI"
#kubectl create -f /var/tmp/flannel/kube-flannel.yml

echo "[TASK 4b] Deploy Calico CNI"
kubectl create -f /var/tmp/calico/tigera-operator.yaml
sleep 90
kubectl create -f /var/tmp/calico/custom-resources.yaml
kubectl get tigerastatus
sleep 180
kubectl get tigerastatus

echo "[TASK 5] Generate and save cluster join command to /joincluster.sh"
kubeadm token create --print-join-command > /joincluster.sh 2>/dev/null

echo "[TASK 6] Setup public key for workers to access master"
cp /var/tmp/keys/id_ecdsa.pub /root/.ssh/authorized_keys
chmod 600 ~/.ssh/authorized_keys
rm -rf /var/tmp/keys
echo "get /var/tmp/kubeconfig (if 192.168.68.241 as master)"
echo "[TASK 7] provide kubeconfig"
cp /root/.kube/config /var/tmp/kubeconfig
chmod 444 /var/tmp/kubeconfig
echo "export KUBECONFIG=./mykube"
