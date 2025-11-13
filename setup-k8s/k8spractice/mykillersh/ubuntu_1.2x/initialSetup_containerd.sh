echo "[TASK 0] prep for k8s install"
swapoff -a

echo "[TASK 1] crio-related task 1"
modprobe overlay  
modprobe br_netfilter  
cat > /etc/sysctl.d/99-kubernetes-cri.conf <<EOF
net.bridge.bridge-nf-call-iptables  = 1
net.ipv4.ip_forward                 = 1
net.bridge.bridge-nf-call-ip6tables = 1
EOF
sysctl --system

cat > /etc/modules-load.d/k8s.conf << EOF2
br_netfilter
overlay
EOF2


echo "[TASK 2] prep repo"
export OS=xUbuntu_22.04
export K8S_VERSION=1.32

curl -fsSL https://download.opensuse.org/repositories/isv:/kubernetes:/core:/stable:/v${K8S_VERSION}/deb/Release.key |gpg --dearmor | sudo tee /etc/apt/keyrings/kubernetes.gpg > /dev/null
echo "deb [signed-by=/etc/apt/keyrings/kubernetes.gpg] https://download.opensuse.org/repositories/isv:/kubernetes:/core:/stable:/v${K8S_VERSION}:/build/deb/ ./" | sudo tee /etc/apt/sources.list.d/kubernetes.list


echo "[TASK 3] Install containerd"

# Install containerd
sudo apt update
sudo apt-get install -y containerd

# Configure containerd
sudo mkdir -p /etc/containerd
containerd config default | sudo tee /etc/containerd/config.toml >/dev/null 2>&1
sed -i 's/SystemdCgroup = false/SystemdCgroup = true/g' /etc/containerd/config.toml

# Restart and enable containerd service
systemctl restart containerd
systemctl enable containerd

# Verify containerd is running
systemctl status containerd --no-pager

# Install CNI plugins (Flannel example)
sudo mkdir -p /etc/cni/net.d /opt/cni/bin
curl -LO https://github.com/containernetworking/plugins/releases/download/v0.9.1/cni-plugins-linux-amd64-v0.9.1.tgz
sudo tar -xzvf cni-plugins-linux-amd64-v0.9.1.tgz -C /opt/cni/bin


echo "[TASK 5] Installing dependencies"
apt-get update
apt-get install -y apt-transport-https ca-certificates curl gpg -y


echo "[TASK 6] intall kubernetes apps"
apt-get update
apt-get install -y kubelet kubeadm kubectl
apt-mark hold containerd kubelet kubeadm kubectl
