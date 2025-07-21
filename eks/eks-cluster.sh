#!/bin/bash
# Amazon EKS cluster setup

set -e

CLUSTER_NAME="my-cluster-name"
REGION="us-east-1"
NODE_GROUP_NAME="my-nodes-name"

echo "Setting up EKS cluster: $CLUSTER_NAME in $REGION"

# Check if eksctl is installed
if ! command -v eksctl &> /dev/null; then
    echo "Installing eksctl..."
    curl --silent --location "https://github.com/weaveworks/eksctl/releases/latest/download/eksctl_$(uname -s)_amd64.tar.gz" | tar xz -C /tmp
    sudo mv /tmp/eksctl /usr/local/bin
fi

# Create EKS cluster
echo "Creating EKS cluster (wait for 15-20 minutes)..."
eksctl create cluster \
    --name $CLUSTER_NAME \
    --region $REGION \
    --node-type t3.medium \
    --nodes 2 \
    --nodes-min 1 \
    --nodes-max 4 \
    --managed

echo "EKS cluster created successfully!"
echo "Updating kubeconfig..."
aws eks update-kubeconfig --region $REGION --name $CLUSTER_NAME

echo "Testing cluster connection..."
kubectl get nodes

echo ""
echo "🎉 EKS cluster is ready!"
echo ""
echo "To delete the cluster later:"
echo "eksctl delete cluster --name $CLUSTER_NAME --region $REGION"
