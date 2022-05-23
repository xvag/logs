#!/bin/sh
set -x

# Go root and cd to ~
sudo su
cd

# Configure persistent loading of modules:
tee /etc/modules-load.d/containerd.conf <<EOF
overlay
br_netfilter
EOF

# Load at runtime:
modprobe overlay
modprobe br_netfilter

# Update Iptables Settings:
# (To ensure packets are properly processed by IP tables
# during filtering and port forwarding)
tee /etc/sysctl.d/kubernetes.conf<<EOF
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1
net.ipv4.ip_forward = 1
EOF

# Reload configs:
sysctl --system

# Add Docker repo:
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/debian $(lsb_release -cs) stable"

# Install containerd:
apt update
apt install -y containerd.io

# Configure containerd and start service:
mkdir -p /etc/containerd
containerd config default>/etc/containerd/config.toml

# Restart containerd:
systemctl restart containerd
systemctl enable containerd

# Update the apt package index
# and install packages needed to use the Kubernetes apt repository:
apt-get update && apt-get install -y apt-transport-https ca-certificates curl

# Download the Google Cloud public signing key:
curl -fsSLo /usr/share/keyrings/kubernetes-archive-keyring.gpg https://packages.cloud.google.com/apt/doc/apt-key.gpg

# Add the Kubernetes apt repository:
echo "deb [signed-by=/usr/share/keyrings/kubernetes-archive-keyring.gpg] https://apt.kubernetes.io/ kubernetes-xenial main" | sudo tee /etc/apt/sources.list.d/kubernetes.list

# Update apt package index, install kubelet, kubeadm and kubectl, and pin their version:
KUBE_VERSION=1.23.0
apt-get update
apt-get install -y kubelet=${KUBE_VERSION}-00 kubeadm=${KUBE_VERSION}-00 kubectl=${KUBE_VERSION}-00 kubernetes-cni=0.8.7-00
apt-mark hold kubelet kubeadm kubectl
systemctl enable kubelet && systemctl start kubelet
