echo "[TASK 0] prep"
swapoff -a
echo "[TASK 1] configure persistent loading of modules"
# Configure persistent loading of modules
tee /etc/modules-load.d/containerd.conf <<EOF
overlay
br_netfilter
EOF

echo "[TASK 2] load overlay and br_netfilter"
# Load at runtime
modprobe overlay
modprobe br_netfilter

echo "[TASK 3] ensure sysctl params set"
# Ensure sysctl params are set
tee /etc/sysctl.d/kubernetes.conf<<EOF
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1
net.ipv4.ip_forward = 1
EOF

# Reload configs
sysctl --system

echo "[TASK 4] install required packages"
# Install required packages
apt install -y curl gnupg2 software-properties-common apt-transport-https ca-certificates

echo "[TASK 5] add docker repo"
# Add Docker repo
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"

echo "[TASK 6] install containerd"
# Install containerd
sudo apt update
sudo apt install -y containerd.io

containerd config default | sudo tee /etc/containerd/config.toml >/dev/null 2>&1
sed -i 's/SystemdCgroup \= false/SystemdCgroup \= true/g' /etc/containerd/config.toml

systemctl restart containerd
systemctl enable containerd

echo "[TASK 7] Installing dependencies"
apt-get update
apt-get install -y apt-transport-https ca-certificates curl -y

echo "[TASK 8] Add apt repo for kubernetes"
curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key add - >/dev/null 2>&1
apt-add-repository "deb http://apt.kubernetes.io/ kubernetes-xenial main" >/dev/null 2>&1

echo "[TASK 9] intall kubernetes apps"
apt-get update
apt-get install -y kubelet=1.24.12-00 kubeadm=1.24.12-00 kubectl=1.24.12-00
