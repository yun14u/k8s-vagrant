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

echo "[TASK 2] prep repo"
export OS=xUbuntu_22.04
export CRIO_VERSION=1.29

curl -fsSL https://download.opensuse.org/repositories/isv:/cri-o:/stable:/v${CRIO_VERSION}/deb/Release.key |gpg --dearmor | sudo tee /etc/apt/keyrings/cri-o-keyring.gpg > /dev/null
echo "deb [signed-by=/etc/apt/keyrings/cri-o-keyring.gpg] https://download.opensuse.org/repositories/isv:/cri-o:/stable:/v${CRIO_VERSION}/deb/ ./" |  sudo tee /etc/apt/sources.list.d/cri-o.list

curl -fsSL https://download.opensuse.org/repositories/isv:/kubernetes:/core:/stable:/v${CRIO_VERSION}/deb/Release.key |gpg --dearmor | sudo tee /etc/apt/keyrings/kubernetes.gpg > /dev/null
echo "deb [signed-by=/etc/apt/keyrings/kubernetes.gpg] https://download.opensuse.org/repositories/isv:/kubernetes:/core:/stable:/v${CRIO_VERSION}:/build/deb/ ./" | sudo tee /etc/apt/sources.list.d/kubernetes.list

sudo apt update

echo "[TASK 3] install crio"
apt update
apt install cri-o -y
apt install runc conmon -y

systemctl start cri-o.service
systemctl enable cri-o.service

systemctl status cri-o.service --no-pager

echo "[TASK 4] post-crio installation task"
# 1. Create /etc/crio directory
sudo mkdir -p /etc/crio

# 2. Generate the crio.conf
crio config | sudo tee /etc/crio/crio.conf > /dev/null

# 3. Now you can cd into it
cd /etc/crio

# 4. Fix the conmon and network settings
sudo sed -i.bak 's|^# *conmon = ""|conmon = "/usr/bin/conmon"|' crio.conf
sudo sed -i.bak 's|^# *network_dir = .*|network_dir = "/etc/cni/net.d"|' crio.conf
sudo sed -i.bak 's|^# *plugin_dirs = .*|plugin_dirs = [ "/opt/cni/bin/", "/usr/lib/cni/" ]|' crio.conf

# 5. Install CNI plugins
sudo apt install -y containernetworking-plugins

# 6. Replace the CNI default config
sudo rm -f /etc/cni/net.d/100-crio-bridge.conflist
sudo mkdir -p /etc/cni/net.d
sudo curl -fsSLo /etc/cni/net.d/11-crio-ipv4-bridge.conflist https://raw.githubusercontent.com/cri-o/cri-o/main/contrib/cni/11-crio-ipv4-bridge.conflist

# 7. Restart CRI-O
sudo systemctl daemon-reexec
sudo systemctl restart crio
systemctl status cri-o.service --no-pager


echo "[TASK 5] Installing dependencies"
apt-get update
apt-get install -y apt-transport-https ca-certificates curl gpg -y


echo "[TASK 6] intall kubernetes apps"
apt-get update
apt-get install -y kubelet kubeadm kubectl
apt-mark hold containerd kubelet kubeadm kubectl
