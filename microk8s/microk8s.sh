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

echo "🔁 Applying new group membership (log out/in might be required)..."
echo "so, run this ./microk8s-1.sh  "
newgrp microk8s
