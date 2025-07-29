#!/bin/bash
# MicroK8s Installation Script for Ubuntu (Root/sudo required)

set -e

echo "📦 Updating system packages..."
sudo apt update && sudo apt upgrade -y

echo "🐳 Installing container tools (Docker & dependencies)..."
sudo apt install -y docker.io curl git

echo "🔐 Adding current user to 'docker' group (if needed)..."
sudo usermod -aG docker $USER

echo "⚙️ Installing snapd (Snap Package Manager)..."
sudo apt install -y snapd

echo "🚀 Installing MicroK8s via snap..."
sudo snap install microk8s --classic

echo "⏳ Waiting for MicroK8s to initialize..."
sudo microk8s status --wait-ready

echo "👤 Adding user '$USER' to microk8s group..."
sudo usermod -a -G microk8s $USER
sudo chown -f -R $USER ~/.kube || true

echo "#!/bin/bash
echo "🔧  Enabling useful MicroK8s addons..."
sudo microk8s enable dns storage ingress dashboard metallb:192.168.1.240-192.168.1.250

echo "📂  Creating ~/.kube/config for kubectl compatibility..."
mkdir -p ~/.kube
sudo microk8s config > ~/.kube/config

echo "🧪  Testing MicroK8s setup..."
microk8s kubectl get nodes

echo -e "\n✅  MicroK8s is successfully installed and running!"
echo "👉  To use kubectl, either use: microk8s kubectl or configure global kubectl"

echo ""
echo "🎯  Useful Commands:"
echo "  - microk8s status"
echo "  - microk8s kubectl get all --all-namespaces"
echo "  - microk8s dashboard-proxy"
echo "  - microk8s stop / microk8s start" " > microk8s-1.sh

chmod +x microk8s-1.sh 

echo "🔁 Applying new group membership (log out/in might be required)..."
echo "so, run this ./microk8s-1.sh  "
newgrp microk8s
