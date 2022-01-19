#!/usr/bin/env bash
set -e
set -x
# Install some stuff first
yum install -y bash-completion vim wget && source /etc/profile.d/bash_completion.sh
# Add my user
useradd  david
echo "Remember to set the password for david"
echo "david  ALL=(ALL)  NOPASSWD: ALL" >> /etc/sudoers.d/david
echo "Pl3a8s3!}chan83" | passwd --stdin david
# Stop firewall
systemctl disable firewalld
systemctl stop firewalld
# Install docker 
curl -fsSL https://get.docker.com -o get-docker.sh
sh get-docker.sh
sleep 3
sudo mkdir /etc/docker
cat <<EOF | sudo tee /etc/docker/daemon.json
{
  "exec-opts": ["native.cgroupdriver=systemd"],
  "log-driver": "json-file",
  "log-opts": {
    "max-size": "100m"
  },
  "storage-driver": "overlay2"
}
EOF
sleep 5
systemctl daemon-reload
systemctl enable --now docker
sleep 3
usermod -aG docker david
docker run hello-world
sleep 3
# Get PATH updated
echo "export PATH=$PATH:/usr/local/bin/" >> /etc/profile
source /etc/profile

# Install k3d
curl -s https://raw.githubusercontent.com/rancher/k3d/main/install.sh | bash
sleep 3
# Install k9s
curl -sS https://webinstall.dev/k9s | bash
sleep 3
# Install HELM
curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3
chmod 700 get_helm.sh
./get_helm.sh
sleep 3
# Install kubeadm
cat <<EOF | sudo tee /etc/modules-load.d/k8s.conf
br_netfilter
EOF
cat <<EOF | sudo tee /etc/sysctl.d/k8s.conf
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1
EOF
sysctl --system
cat <<EOF | sudo tee /etc/yum.repos.d/kubernetes.repo
[kubernetes]
name=Kubernetes
baseurl=https://packages.cloud.google.com/yum/repos/kubernetes-el7-\$basearch
enabled=1
gpgcheck=1
repo_gpgcheck=1
gpgkey=https://packages.cloud.google.com/yum/doc/yum-key.gpg https://packages.cloud.google.com/yum/doc/rpm-package-key.gpg
exclude=kubelet kubeadm kubectl
EOF
# Set SELinux in permissive mode (effectively disabling it)
 setenforce 0
sed -i 's/^SELINUX=enforcing$/SELINUX=permissive/' /etc/selinux/config
yum install -y  kubelet kubeadm kubectl --disableexcludes=kubernetes
systemctl enable --now kubelet
# Install RKE
curl -s https://api.github.com/repos/rancher/rke/releases/latest | grep download_url | grep amd64 | cut -d '"' -f 4 | wget -qi -
chmod +x rke_linux-amd64
mv rke_linux-amd64 /usr/local/bin/rke
rke --version

