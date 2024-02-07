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
sudo apt-get install -y containerd

containerd config default | sudo tee /etc/containerd/config.toml >/dev/null 2>&1
sed -i 's/SystemdCgroup \= false/SystemdCgroup \= true/g' /etc/containerd/config.toml

systemctl restart containerd
systemctl enable containerd

echo "[TASK 7] Installing dependencies"
apt-get update
apt-get install -y apt-transport-https ca-certificates curl gpg -y

echo "[TASK 8] Add apt repo for kubernetes"
#curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key add - >/dev/null 2>&1
#apt-add-repository "deb http://apt.kubernetes.io/ kubernetes-xenial main" >/dev/null 2>&1
curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.27/deb/Release.key | sudo gpg --dearmor     -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg
# This overwrites any existing configuration in /etc/apt/sources.list.d/kubernetes.list
echo 'deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.27/deb/ /' | tee /etc/apt/sources.list.d/kubernetes.list

echo "[TASK 9] intall kubernetes apps"
apt-get update
apt-get install -y kubelet kubeadm kubectl
apt-mark hold containerd kubelet kubeadm kubectl
#echo "#apt-get update"
#echo "#apt-get install -y kubelet kubeadm kubectl"
#echo "#apt-mark hold containerd kubelet kubeadm kubectl"
