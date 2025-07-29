#!/bin/bash
echo "🔧 Enabling useful MicroK8s addons..."
sudo microk8s enable dns storage ingress dashboard metallb:192.168.1.240-192.168.1.250

echo "📂 Creating ~/.kube/config for kubectl compatibility..."
mkdir -p ~/.kube
sudo microk8s config > ~/.kube/config

echo "🧪 Testing MicroK8s setup..."
microk8s kubectl get nodes

echo -e "\n✅ MicroK8s is successfully installed and running!"
echo "👉 To use kubectl, either use: microk8s kubectl or configure global kubectl"

echo ""
echo "🎯 Useful Commands:"
echo "  - microk8s status"
echo "  - microk8s kubectl get all --all-namespaces"
echo "  - microk8s dashboard-proxy"
echo "  - microk8s stop / microk8s start"
