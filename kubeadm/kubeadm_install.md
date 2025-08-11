# 🚀 KubeBeam – Kubernetes Installation Toolkit

## 📌 Overview
KubeBeam is a set of **ready-to-run scripts** that simplify the installation of a **Kubernetes cluster** on Ubuntu 20.04/22.04.  
It automates:
- 📦 Node preparation (Master & Worker)
- 🛠 Master node initialization
- 🔗 Worker node joining

Designed for **DevOps engineers**, **students**, and **Kubernetes enthusiasts**, KubeBeam ensures a **clean, error-free, and repeatable** installation process.

---

## 🗂 Scripts Included
| Script | Purpose | Run On |
|--------|---------|--------|
| `kubeadm_common.sh` | Installs dependencies, configures container runtime, and sets up Kubernetes components. | Master & Worker nodes |
| `master_node.sh` | Initializes the Kubernetes cluster and installs Calico CNI. | Master node only |
| `worker_node.sh` | Joins a worker node to the cluster using the master’s join command. | Worker nodes only |

---

## 🖥️ System Requirements
- **OS:** Ubuntu 20.04 / 22.04 (fresh install recommended)  
- **RAM:** 2 GB minimum (4 GB+ recommended for master node)  
- **CPU:** 2+ cores  
- **Network:** All nodes must be able to communicate over LAN  
- **Privileges:** Root or `sudo` access  

---

## ⚙️ Installation Steps

### **1️⃣ Prepare All Nodes (Master & Worker)**
Run on **every node** in the cluster:
```bash
chmod +x kubeadm_common.sh
sudo ./kubeadm_common.sh
```

### **2️⃣ Initialize the Master Node
Run only on the master:

```bash
chmod +x master_node.sh
sudo ./master_node.sh
```

This will:

Initialize the Kubernetes cluster with Calico CNI

Configure kubectl for the current user

Print the join command for worker nodes

### **3️⃣ Join Worker Nodes
On each worker node:

Copy the join command displayed by the master.

Run:

```bash
chmod +x worker_node.sh
sudo ./worker_node.sh
```

### 🔍 Verifying the Cluster
On the master node:

```bash
kubectl get nodes
```
Expected output:

```bash
NAME         STATUS   ROLES           AGE   VERSION
master-node  Ready    control-plane   5m    v1.29.x
worker-1     Ready    <none>          2m    v1.29.x
worker-2     Ready    <none>          2m    v1.29.x
```

### 🛠 Troubleshooting
Pods stuck in Pending state?
Check Calico installation:

```bash
kubectl get pods -n kube-system
```

Join command expired?
Regenerate it on master:

```bash
kubeadm token create --print-join-command
```

Container runtime issues?
Restart containerd:

```bash
sudo systemctl restart containerd
```

### 📄 License
MIT License – 

### 👨‍💻 Author
Ghanshyam Ramole – DevOps Engineer & Cloud Enthusiast
