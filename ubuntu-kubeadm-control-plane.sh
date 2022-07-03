# Control Plane node
hostnamectl set-hostname k8s-control

echo "Set up hostnames in hosts file"

cat >> /etc/hosts <<EOL
155.138.194.18          k8s-control
104.238.179.58          k8s-worker1
108.61.192.149          k8s-worker2
EOL

cat >> /etc/modules-load.d/containerd.conf <<EOL
overlay
br_netfilter
EOL

modprobe overlay
modprobe br_netfilter

cat <<EOF | tee /etc/sysctl.d/99-kubernetes-cri.conf
net.bridge.bridge-nf-call-iptables = 1
net.ipv4.ip_forward = 1
net.bridge.bridge-nf-call-ip6tables = 1
EOF
sysctl --system

apt-get update && sudo apt-get install -y containerd
mkdir -p /etc/containerd
containerd config default | sudo tee /etc/containerd/config.toml
systemctl restart containerd

swapoff -a

apt-get update && sudo apt-get install -y apt-transport-https curl
curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key add -
cat << EOF | sudo tee /etc/apt/sources.list.d/kubernetes.list
deb https://apt.kubernetes.io/ kubernetes-xenial main
EOF

apt-get update
apt-get install -y kubelet=1.23.0-00 kubeadm=1.23.0-00 kubectl=1.23.0-00
apt-mark hold kubelet kubeadm kubectl

kubeadm init --pod-network-cidr 192.168.0.0/16 --kubernetes-version 1.23.0
mkdir -p /home/dpbak/.kube
cp -i /etc/kubernetes/admin.conf /home/dpbak/.kube/config
chown dpbak:dpbak /home/dpbak/.kube/config

echo "Verifiy cluster is working"

# kubectl get nodes
# kubectl apply -f https://docs.projectcalico.org/manifests/calico.yaml
# kubeadm token create --print-join-command
# kubeadm join 155.138.194.18:6443 --token zlpd8y.qm6vp9jkkupa3n5b --discovery-token-ca-cert-hash sha256:3512b4d7c81bb4f2164d49dda3f330120d53fd9423fde1c4b4ccb9263e11983f

