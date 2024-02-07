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

echo "[TASK 2] install crio"
export OS=xUbuntu_22.04
export CRIO_VERSION=1.26

echo "deb https://download.opensuse.org/repositories/devel:/kubic:/libcontainers:/stable/$OS/ /"| sudo tee /etc/apt/sources.list.d/devel:kubic:libcontainers:stable.list
echo "deb http://download.opensuse.org/repositories/devel:/kubic:/libcontainers:/stable:/cri-o:/$CRIO_VERSION/$OS/ /"| sudo tee /etc/apt/sources.list.d/devel:kubic:libcontainers:stable:cri-o:$CRIO_VERSION.list

curl -L https://download.opensuse.org/repositories/devel:kubic:libcontainers:stable:cri-o:$CRIO_VERSION/$OS/Release.key | sudo apt-key add -
curl -L https://download.opensuse.org/repositories/devel:/kubic:/libcontainers:/stable/$OS/Release.key | sudo apt-key add -

apt update
apt install cri-o cri-o-runc -y

systemctl start crio
systemctl enable crio
systemctl status crio

echo "[TASK 3] Add CNI Plugin for crio"
apt install containernetworking-plugins -y
cd /etc/crio
sed -i.bak 's|^# conmon = ""|conmon = "/usr/bin/conmon"|' crio.conf
sed -i.bak 's|^# network_dir|network_dir|' crio.conf
sed -i.bak 's|^# plugin_dirs |plugin_dirs |' crio.conf
sed -i.bak  's|^# [[:blank:]]"/opt/cni/bin/",|     "/opt/cni/bin/","/usr/lib/cni/", ]|' crio.conf

rm -f /etc/cni/net.d/100-crio-bridge.conflist
curl -fsSLo /etc/cni/net.d/11-crio-ipv4-bridge.conflist https://raw.githubusercontent.com/cri-o/cri-o/main/contrib/cni/11-crio-ipv4-bridge.conflist
systemctl restart crio
apt install cri-tools -y


echo "[TASK 4] Installing dependencies"
apt-get update
apt-get install -y apt-transport-https ca-certificates curl gpg -y

echo "[TASK 8] Add apt repo for kubernetes"
#curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key add - >/dev/null 2>&1
#apt-add-repository "deb http://apt.kubernetes.io/ kubernetes-xenial main" >/dev/null 2>&1
curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.27/deb/Release.key | sudo gpg --dearmor     -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg
# This overwrites any existing configuration in /etc/apt/sources.list.d/kubernetes.list
echo 'deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.27/deb/ /' | tee /etc/apt/sources.list.d/kubernetes.list

echo "[TASK 5] intall kubernetes apps"
apt-get update
apt-get install -y kubelet kubeadm kubectl
apt-mark hold containerd kubelet kubeadm kubectl
