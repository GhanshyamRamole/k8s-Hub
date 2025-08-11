#!/bin/bash
# =============================================================
# Kubernetes Master Node Setup Script (Ubuntu 20.04/22.04)
# Author: Ghanshyam Ramole
# =============================================================
# USAGE:
#   1. Save this script:  setup_k8s_master.sh
#   2. Make it executable: chmod +x setup_k8s_master.sh
#   3. Run as root or with sudo: sudo ./setup_k8s_master.sh
#
# AFTER RUNNING:
#   - Share the "kubeadm join ..." command with your worker nodes.
#   - Deploy workloads using kubectl.
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
echo -e " Kubernetes Master Node Setup Script"
echo -e " Author: Ghanshyam Ramole"
echo -e "=============================================${NC}"

# 1. Initialize the Cluster
step 1 "Initializing Kubernetes Cluster..."
sudo kubeadm init --pod-network-cidr=192.168.0.0/16 || error_exit "Cluster initialization failed."
success "Kubernetes cluster initialized."

# 2. Set Up Local kubeconfig
step 2 "Configuring kubectl for the current user..."
mkdir -p "$HOME/.kube" || error_exit "Failed to create kube config directory."
sudo cp -i /etc/kubernetes/admin.conf "$HOME/.kube/config" || error_exit "Failed to copy admin.conf."
sudo chown "$(id -u):$(id -g)" "$HOME/.kube/config" || error_exit "Failed to change kube config permissions."
success "kubectl configured for the current user."

# 3. Install Calico CNI
step 3 "Installing Calico network plugin..."
kubectl apply -f https://raw.githubusercontent.com/projectcalico/calico/v3.26.0/manifests/calico.yaml || error_exit "Failed to install Calico."
success "Calico network plugin installed."

# 4. Generate Join Command
step 4 "Generating join command for worker nodes..."
JOIN_CMD=$(kubeadm token create --print-join-command) || error_exit "Failed to generate join command."
success "Join command generated."

# Display join command clearly
echo -e "\n${YELLOW}Share this command with your worker nodes:${NC}"
echo -e "${BLUE}$JOIN_CMD${NC}"

# =========[ FINISH MESSAGE ]=========
echo -e "\n${GREEN}✅ Kubernetes Master Node setup completed successfully!${NC}"
echo -e "${YELLOW}Next steps:${NC}"
echo -e " - Run the above join command on each worker node."
echo -e " - Verify nodes using: ${BLUE}kubectl get nodes${NC}"
echo -e "${GREEN}Cluster is ready! 🚀${NC}"

