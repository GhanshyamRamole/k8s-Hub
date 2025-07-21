
# ⚙️ KIND Cluster Setup

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
