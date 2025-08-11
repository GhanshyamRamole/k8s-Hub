#!/bin/bash
# Kubernetes Installation Script (Advanced)
# Works for Ubuntu 20.04+ on both Master & Worker Nodes
# Author: Ghanshyam Ramole (Modified by ChatGPT)
# Last Updated: 2025-08-11

set -euo pipefail
LOG_FILE="/var/log/k8s_install.log"
exec > >(tee -a $LOG_FILE) 2>&1

echo "========================================================="
echo "🚀 Kubernetes Prerequisites & Installation Script Started"
echo "========================================================="
sleep 1

# --- Functions ---
check_root() {
    if [[ $EUID -ne 0 ]]; then
        echo "❌ This script must be run as root or with sudo privileges."
        exit 1
    fi
}

check_os() {
    if ! grep -q "Ubuntu" /etc/os-release; then
        echo "❌ This script only supports Ubuntu."
        exit 1
    fi
}

run_cmd() {
    "$@"
    if [[ $? -ne 0 ]]; then
        echo "❌ Command failed: $*"
        exit 1
    fi
}

# --- Step 0: Basic Checks ---
check_root
check_os
echo "✅ Running as root on Ubuntu."

# --- Step 1: Disable Swap ---
echo "[1/7] Disabling swap..."
swapoff -a
sed -i '/ swap / s/^/#/' /etc/fstab

# --- Step 2: Load Kernel Modules ---
echo "[2/7] Loading necessary kernel modules..."
cat <<EOF | tee /etc/modules-load.d/k8s.conf
overlay
br_netfilter
EOF
modprobe overlay
modprobe br_netfilter

# --- Step 3: Set Sysctl Parameters ---
echo "[3/7] Configuring sysctl parameters..."
cat <<EOF | tee /etc/sysctl.d/k8s.conf
net.bridge.bridge-nf-call-iptables  = 1
net.bridge.bridge-nf-call-ip6tables = 1
net.ipv4.ip_forward                 = 1
EOF
sysctl --system

# --- Step 4: Install Containerd ---
echo "[4/7] Installing containerd..."
apt-get update -y
apt-get install -y ca-certificates curl gnupg lsb-release
install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /etc/apt/keyrings/docker.gpg
chmod a+r /etc/apt/keyrings/docker.gpg
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] \
  https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" \
  | tee /etc/apt/sources.list.d/docker.list > /dev/null

apt-get update -y
apt-get install -y containerd.io

# Configure containerd with SystemdCgroup
containerd config default | \
    sed -e 's/SystemdCgroup = false/SystemdCgroup = true/' \
        -e 's/sandbox_image = "registry.k8s.io\/pause:3.6"/sandbox_image = "registry.k8s.io\/pause:3.9"/' \
    | tee /etc/containerd/config.toml

systemctl restart containerd
systemctl enable containerd
systemctl is-active containerd && echo "✅ containerd running."

# --- Step 5: Install Kubernetes Components ---
echo "[5/7] Installing Kubernetes components..."
apt-get install -y apt-transport-https ca-certificates curl gpg
mkdir -p /etc/apt/keyrings
curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.29/deb/Release.key \
    | gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg
echo "deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] \
https://pkgs.k8s.io/core:/stable:/v1.29/deb/ /" \
    | tee /etc/apt/sources.list.d/kubernetes.list

apt-get update -y
apt-get install -y kubelet kubeadm kubectl
apt-mark hold kubelet kubeadm kubectl

# --- Step 6: Verify Installation ---
echo "[6/7] Verifying installations..."
kubeadm version
kubectl version --client
kubelet --version
containerd --version

# --- Step 7: Final Message ---
echo "========================================================="
echo "✅ Kubernetes prerequisites and components installed successfully!"
echo "📜 Log file: $LOG_FILE"
echo "💡 Next Steps:"
echo "  👉 On Master Node: kubeadm init --pod-network-cidr=10.244.0.0/16"
echo "  👉 On Worker Node: Use the join command from master init output"
echo "========================================================="

