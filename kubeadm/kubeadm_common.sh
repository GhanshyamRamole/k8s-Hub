#!/bin/bash
# =============================================================
# Kubernetes Node Setup Script (Ubuntu 20.04/22.04)
# Author: Ghanshyam Ramole
# Works for both Master & Worker nodes
# =============================================================
# USAGE:
#   1. Save this script:  setup_k8s_node.sh
#   2. Make it executable: chmod +x setup_k8s_node.sh
#   3. Run as root or with sudo: sudo ./setup_k8s_node.sh
#
# AFTER RUNNING:
#   - On Master: Run `kubeadm init ...` to initialize the cluster
#   - On Worker: Run the `kubeadm join ...` command provided by Master
# =============================================================

# =========[ COLORS FOR OUTPUT ]=========
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# =========[ HELPER FUNCTIONS ]=========
function step() {
    echo -e "\n${BLUE}>>> Step $1:${NC} $2${NC}"
}

function success() {
    echo -e "${GREEN}✔ SUCCESS:${NC} $1"
}

function warn() {
    echo -e "${YELLOW}⚠ WARNING:${NC} $1"
}

function error_exit() {
    echo -e "${RED}✘ ERROR:${NC} $1"
    exit 1
}

# =========[ SCRIPT START ]=========
echo -e "${GREEN}============================================="
echo -e " Kubernetes Node Setup Script"
echo -e " Author: Ghanshyam Ramole"
echo -e "=============================================${NC}"

# 1. Disable Swap
step 1 "Disabling swap (Required for Kubernetes)..."
sudo swapoff -a || error_exit "Failed to disable swap."
success "Swap disabled."

# 2. Load Kernel Modules
step 2 "Loading necessary kernel modules for Kubernetes networking..."
cat <<EOF | sudo tee /etc/modules-load.d/k8s.conf >/dev/null
overlay
br_netfilter
EOF
sudo modprobe overlay && sudo modprobe br_netfilter || error_exit "Failed to load kernel modules."
success "Kernel modules loaded."

# 3. Set Sysctl Parameters
step 3 "Applying sysctl settings for Kubernetes networking..."
cat <<EOF | sudo tee /etc/sysctl.d/k8s.conf >/dev/null
net.bridge.bridge-nf-call-iptables  = 1
net.bridge.bridge-nf-call-ip6tables = 1
net.ipv4.ip_forward                 = 1
EOF
sudo sysctl --system || error_exit "Failed to apply sysctl parameters."
success "Sysctl parameters applied."

# 4. Install Containerd
step 4 "Installing and configuring containerd runtime..."
sudo apt-get update
sleep 2

sudo apt-get install -y ca-certificates curl
sleep 2

sudo install -m 0755 -d /etc/apt/keyrings
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
sudo chmod a+r /etc/apt/keyrings/docker.asc
sleep 2

echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu $(. /etc/os-release && echo \"$VERSION_CODENAME\") stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

sudo apt-get update
sleep 2

sudo apt-get install -y containerd.io
sleep 2

containerd config default | sed -e 's/SystemdCgroup = false/SystemdCgroup = true/' -e 's/sandbox_image = "registry.k8s.io\/pause:3.6"/sandbox_image = "registry.k8s.io\/pause:3.9"/' | sudo tee /etc/containerd/config.toml

sudo systemctl restart containerd
sleep 2

sudo systemctl is-active containerd
sleep 2
# 5. Install Kubernetes Components
step 5 "Installing Kubernetes components (kubelet, kubeadm, kubectl)..."
sudo apt-get update
sleep 2

sudo apt-get install -y apt-transport-https ca-certificates curl gpg 
sleep 2

curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.29/deb/Release.key | sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg -y
sleep 2

echo 'deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.29/deb/ /' | sudo tee /etc/apt/sources.list.d/kubernetes.list

sudo apt-get update
sleep 2

sudo apt-get install -y kubelet kubeadm kubectl
sleep 2

sudo apt-mark hold kubelet kubeadm kubectl
sleep 2

echo "Kubernetes setup completed."
# =========[ FINISH MESSAGE ]=========
echo -e "\n${GREEN}✅ Kubernetes Node setup completed successfully!${NC}"
echo -e "${YELLOW}Next steps:${NC}"
echo -e " - On MASTER: Run ${BLUE}sudo kubeadm init --pod-network-cidr=10.244.0.0/16${NC}"
echo -e " - On WORKER: Run the ${BLUE}kubeadm join ...${NC} command given by Master."
echo -e "${GREEN}Happy Kubernetes-ing! 🚀${NC}"

