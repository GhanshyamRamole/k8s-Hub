#!/bin/bash

set -e
  echo ""
  read -p "Enter your Kind cluster name:" cluster_name
  echo $cluster_name
  config_file="config.yml"

set -o pipefail

echo " installing docker, Kind, & kubectl..."


# 1. Install Docker

if ! command -v docker &>/dev/null; then
  echo "📦 Installing Docker..."
  sudo apt-get update -y
  sudo apt-get install -y docker.io

  echo "👤 Adding current user to docker group..."
  sudo usermod -aG docker "$USER" 
  sudo newgrp docker   

  echo "✅ Docker installed and user added to docker group."
else
  echo "✅ Docker is already installed."
fi


# 2. Install Kind (based on architecture

if ! command -v kind &>/dev/null; then
  echo "📦 Installing Kind..."

  ARCH=$(uname -m)
  if [ "$ARCH" = "x86_64" ]; then
    curl -Lo ./kind https://kind.sigs.k8s.io/dl/v0.29.0/kind-linux-amd64
  elif [ "$ARCH" = "aarch64" ]; then
    curl -Lo ./kind https://kind.sigs.k8s.io/dl/v0.29.0/kind-linux-arm64
  else
    echo "❌ Unsupported architecture: $ARCH"
    exit 1
  fi

  chmod +x ./kind
  sudo mv ./kind /usr/local/bin/kind
  echo "✅ Kind installed successfully."
else
  echo "✅ Kind is already installed."
fi


# 3. Install kubectl (latest stable)

if ! command -v kubectl &>/dev/null; then
  echo "📦 Installing kubectl (latest stable version)..."

  curl -LO "https://dl.k8s.io/release/$(curl -Ls https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
  sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl
  rm -f kubectl

  echo "✅ kubectl installed successfully."
else
  echo "✅ kubectl is already installed."
fi


# 4. Confirm Versions

echo
echo "🔍 Installed Versions:"
docker --version
kind --version
kubectl version --client --output=yaml

echo
echo "🎉 Docker, Kind, and kubectl installation complete!"

# 5. creating cluster

echo ""
echo "creating cluster using kubectl"

echo "kind: Cluster
apiVersion: kind.x-k8s.io/v1alpha4
nodes:
  - role: control-plane
    image: kindest/node:v1.33.1
  - role: worker
    image: kindest/node:v1.33.1
  - role: worker
    image: kindest/node:v1.33.1" > config.yml

kind create cluster --config $config_file --name $cluster_name

echo "kind cluster create successfully"
echo "checking cluster nodes"

kubectl get nodes

echo "Ready to deploy Application "

