#!/bin/bash
#
# Setup for Control Plane (Master) servers

set -euxo pipefail

VIRTUAL_IP="192.168.1.250:8090"
MASTER_IP="$(ip --json a s | jq -r '.[] | if .ifname == "ens192" then .addr_info[] | if .family == "inet" then .local else empty end else empty end')"
NODENAME=$(hostname -s)
POD_CIDR="10.50.0.0/16"

# sudo kubeadm config images pull

echo "Preflight Check Passed: Downloaded All Required Images"

sudo kubeadm init --control-plane-endpoint=$MASTER_IP --apiserver-advertise-address=$MASTER_IP --apiserver-cert-extra-sans=$MASTER_IP --node-name $NODENAME --pod-network-cidr=$POD_CIDR --ignore-preflight-errors Swap --v=9
#sudo kubeadm init --apiserver-advertise-address=$MASTER_IP --apiserver-cert-extra-sans=$MASTER_IP --pod-network-cidr=$POD_CIDR --ignore-preflight-errors Swap --v=9

mkdir -p "$HOME"/.kube 
sudo cp -i /etc/kubernetes/admin.conf "$HOME"/.kube/config 
sudo chown "$(id -u)":"$(id -g)" "$HOME"/.kube/config

# Install Claico Network Plugin Network

curl https://docs.projectcalico.org/manifests/calico.yaml -O

kubectl apply -f calico.yaml

systemctl restart containerd
#systemctl restart crio

