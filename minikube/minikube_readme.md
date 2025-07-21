# 🚀 1. Minikube Installation on Ubuntu

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

