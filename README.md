# 🚀 1. Minikube Installation Guide for Ubuntu

This guide provides step-by-step instructions for installing **Minikube** on Ubuntu. Minikube allows you to run a **local single-node Kubernetes cluster** for development and testing purposes.

---

## ✅ Pre-requisites

- 🐧 Ubuntu OS (20.04+ recommended)
- 🧑‍💻 `sudo` privileges
- 🌐 Internet access
- 🔒 Virtualization support (check with):
  ```bash
  egrep -c '(vmx|svm)' /proc/cpuinfo
  # 0 = Disabled, 1 or more = Enabled
  ```

---

## 🧱 Step 1: Update System Packages

```bash
sudo apt update
```

---

## 📦 Step 2: Install Required Packages

```bash
sudo apt install -y curl wget apt-transport-https
```

---

## 🐳 Step 3: Install Docker (Minikube Driver)

```bash
sudo apt install -y docker.io
sudo systemctl enable --now docker
```

Add your user to the `docker` group so you can run Docker without `sudo`:

```bash
sudo usermod -aG docker $USER && newgrp docker
```

⚠️ After running this, **logout and login again**, or run `exit` and reconnect to your terminal.

---

## 📥 Step 4: Install Minikube

Download the latest Minikube binary:

```bash
curl -Lo minikube https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64
chmod +x minikube
sudo mv minikube /usr/local/bin/
```

Verify installation:

```bash
minikube version
```

---

## 📥 Step 5: Install `kubectl` (Kubernetes CLI)

Download the latest stable release of `kubectl`:

```bash
curl -LO "https://dl.k8s.io/release/$(curl -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
chmod +x kubectl
sudo mv kubectl /usr/local/bin/
```

Verify installation:

```bash
kubectl version --client
```

---

## ▶️ Step 6: Start Minikube

Start the cluster using Docker as the driver:

```bash
minikube start --driver=docker --vm=true
```

This launches a single-node Kubernetes cluster inside Docker.

---

## 📊 Step 7: Check Cluster Status

```bash
minikube status
kubectl get nodes
```

---

## 🛑 Step 8: Stop Minikube

```bash
minikube stop
```

---

## ❌ Optional: Delete Minikube Cluster

```bash
minikube delete
```

---

## 🎉 You Did It!

You've successfully installed **Minikube** and a working **local Kubernetes cluster** on Ubuntu! You're now ready to:

- Practice deploying Kubernetes apps
- Test YAML configurations
- Learn cluster management with `kubectl`

---

## 🔗 Next Steps

- Deploy your first app using `kubectl apply -f`
- Set up a local dashboard: `minikube dashboard`
- Explore Helm for app packaging
- Learn Kubernetes objects: Pods, Deployments, Services

---
# ⚙️ KIND Cluster Setup Guide (Kubernetes IN Docker)

This guide walks you through setting up a **local Kubernetes cluster using KIND (Kubernetes IN Docker)**. Ideal for testing, development, and local learning environments.

---

## 🛠 1. Installing KIND and kubectl

Install `kind` and `kubectl` using the recommended install script or your OS package manager.

- KIND: https://kind.sigs.k8s.io/docs/user/quick-start/
- kubectl: https://kubernetes.io/docs/tasks/tools/

---

## 🧱 2. Setting Up the KIND Cluster

### Create a `kind-config.yaml` file:

```yaml
kind: Cluster
apiVersion: kind.x-k8s.io/v1alpha4
nodes:
  - role: control-plane
    image: kindest/node:v1.33.1
  - role: worker
    image: kindest/node:v1.33.1
  - role: worker
    image: kindest/node:v1.33.1
```

### Create the cluster:

```bash
kind create cluster --config kind-config.yaml --name tws-kind-cluster
```

### Verify the cluster:

```bash
kubectl get nodes
kubectl cluster-info
```

---

## 📡 3. Accessing the Cluster

Use `kubectl` to interact with your KIND cluster:

```bash
kubectl cluster-info
```

---

## 📊 4. Setting Up the Kubernetes Dashboard

### Deploy the Dashboard:

```bash
kubectl apply -f https://raw.githubusercontent.com/kubernetes/dashboard/v2.7.0/aio/deploy/recommended.yaml
```

### Create an Admin User

Create a file named `dashboard-admin-user.yml` with the following content:

```yaml
apiVersion: v1
kind: ServiceAccount
metadata:
  name: admin-user
  namespace: kubernetes-dashboard
---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: admin-user
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: cluster-admin
subjects:
- kind: ServiceAccount
  name: admin-user
  namespace: kubernetes-dashboard
```

Apply the configuration:

```bash
kubectl apply -f dashboard-admin-user.yml
```

### Get the Access Token

```bash
kubectl -n kubernetes-dashboard create token admin-user
```

Copy the token and use it to log in to the dashboard.

### Access the Dashboard

```bash
kubectl proxy
```

Open your browser and go to:

```
http://localhost:8001/api/v1/namespaces/kubernetes-dashboard/services/https:kubernetes-dashboard:/proxy/
```

Use the previously copied token to log in.

---

## 🧹 5. Deleting the KIND Cluster

To delete the cluster:

```bash
kind delete cluster --name my-kind-cluster
```

---

## 📝 6. Notes

- 🌀 **Multiple Clusters**: KIND supports running multiple clusters by specifying unique `--name` values.
- 🧱 **Custom Node Images**: You can specify different Kubernetes versions using custom node images.
- ⚠️ **Ephemeral Clusters**: KIND clusters are temporary. They are lost if Docker is restarted or the container is deleted.

---

🎉 You now have a running Kubernetes cluster inside Docker using KIND! Great for testing and CI pipelines.

