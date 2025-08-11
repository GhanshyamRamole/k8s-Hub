#!/bin/bash
# Kubernetes Master Node Setup Script (Error-Free & Idempotent)
# Author: Ghanshyam Ramole (Modified by ChatGPT)
# Last Updated: 2025-08-11

set -euo pipefail
LOG_FILE="/var/log/k8s_master_setup.log"
exec > >(tee -a "$LOG_FILE") 2>&1

POD_CIDR="10.244.0.0/16"  # Change if using a different CNI
JOIN_CMD_FILE="/root/k8s_join_command.sh"

echo "========================================================="
echo "🚀 Kubernetes Master Node Setup Script Started"
echo "========================================================="

# --- Function to check root privileges ---
check_root() {
    if [[ $EUID -ne 0 ]]; then
        echo "❌ This script must be run as root or with sudo privileges."
        exit 1
    fi
}

# --- Function to check kubeadm availability ---
check_kubeadm() {
    if ! command -v kubeadm &>/dev/null; then
        echo "❌ kubeadm is not installed. Please run the prerequisites script first."
        exit 1
    fi
}

# --- Function to clean old Kubernetes state ---
cleanup_old_cluster() {
    echo "🧹 Cleaning up any previous Kubernetes setup..."
    kubeadm reset -f || true
    rm -rf /etc/cni/net.d \
           $HOME/.kube \
           /var/lib/cni \
           /var/lib/kubelet \
           /var/lib/etcd \
           /etc/kubernetes || true

    systemctl stop kubelet || true
    systemctl stop containerd || true

    pkill -9 kube-apiserver || true
    pkill -9 etcd || true
    pkill -9 kube-controller || true
    pkill -9 kube-scheduler || true

    systemctl start containerd
    systemctl enable containerd
}

# --- Function to check and free ports ---
check_ports() {
    echo "🔍 Checking Kubernetes required ports..."
    local ports=(6443 10259 10257 10250 2380)
    for port in "${ports[@]}"; do
        if lsof -i :$port &>/dev/null; then
            echo "⚠️ Port $port is in use. Killing process..."
            lsof -ti :$port | xargs -r kill -9
        fi
    done
}

# --- Function to initialize Kubernetes master ---
init_cluster() {
    echo "🚀 Initializing Kubernetes Cluster with CIDR: $POD_CIDR..."
    kubeadm init --pod-network-cidr="$POD_CIDR" --upload-certs
}

# --- Function to setup kubeconfig ---
setup_kubeconfig() {
    echo "📂 Setting up kubeconfig for current user..."
    mkdir -p "$HOME/.kube"
    cp -i /etc/kubernetes/admin.conf "$HOME/.kube/config"
    chown "$(id -u):$(id -g)" "$HOME/.kube/config"
}

# --- Function to install Calico ---
install_calico() {
    echo "🌐 Installing Calico CNI..."
    kubectl apply -f https://raw.githubusercontent.com/projectcalico/calico/v3.26.0/manifests/calico.yaml
}

# --- Function to generate join command ---
generate_join_command() {
    echo "🔑 Generating join command for worker nodes..."
    kubeadm token create --print-join-command | tee "$JOIN_CMD_FILE"
    chmod +x "$JOIN_CMD_FILE"
    echo "✅ Join command saved to: $JOIN_CMD_FILE"
}

# --- MAIN EXECUTION ---
check_root
check_kubeadm
cleanup_old_cluster
check_ports
init_cluster
setup_kubeconfig
install_calico
generate_join_command

echo "========================================================="
echo "✅ Kubernetes Master Node setup complete!"
echo "📜 Log file: $LOG_FILE"
echo "💡 To join workers: run the command in $JOIN_CMD_FILE"
echo "========================================================="

