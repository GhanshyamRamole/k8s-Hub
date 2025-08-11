#!/bin/bash
# =============================================================
# Kubernetes Worker Node Join Script (Ubuntu 20.04/22.04)
# Author: Ghanshyam Ramole
# =============================================================
# USAGE:
#   1. Save this script:  join_k8s_worker.sh
#   2. Make it executable: chmod +x join_k8s_worker.sh
#   3. Run as root or with sudo: sudo ./join_k8s_worker.sh
#
# IMPORTANT:
#   - Replace the <JOIN_COMMAND_FROM_MASTER> placeholder below
#     with the join command provided by the master node.
#   - Example join command:
#     kubeadm join 192.168.1.100:6443 --token abc123.0123456789abcdef \
#     --discovery-token-ca-cert-hash sha256:abcdef1234567890... \
#     --cri-socket "unix:///run/containerd/containerd.sock" --v=5
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
echo -e " Kubernetes Worker Node Join Script"
echo -e " Author: Ghanshyam Ramole"
echo -e "=============================================${NC}"

read -p "Enter your join command output" KUBE_JOIN_CMD

# 1. Reset node
step 1 "Resetting any previous Kubernetes configuration..."
sudo kubeadm reset -f || error_exit "Failed to reset the node."
success "Node reset completed."

# 2. Join the cluster
step 2 "Joining the Kubernetes cluster..."
# Replace <JOIN_COMMAND_FROM_MASTER> with the actual join command from Master
sudo $KUBE_JOIN_CMD || error_exit "Failed to join the Kubernetes cluster."
success "Worker node joined the cluster successfully."

# =========[ FINISH MESSAGE ]=========
echo -e "\n${GREEN}✅ Worker node is now part of the Kubernetes cluster!${NC}"
echo -e "${YELLOW}Verify on master with:${NC} ${BLUE}kubectl get nodes${NC}"

