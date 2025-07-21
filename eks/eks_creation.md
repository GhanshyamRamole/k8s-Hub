# 🚀 Kubernetes Container Orchestration

Learn how to run your web application on Kubernetes for **scalability**, **reliability**, and **self-healing** deployments.

---

## 📘 What This Project Does

✅ Deploys your app in multiple containers (pods)  
✅ Automatically restarts failed containers  
✅ Load balances traffic between pods  
✅ Scales up/down based on demand  
✅ Enables service discovery & internal networking  

---

## 🛠 Deployment Options

### 🧪 Option A: Local Kubernetes (Recommended for Learning)
- Uses **Docker Desktop** (with Kubernetes) or **Minikube**
- Free & fast to set up
- Great for learning Kubernetes concepts

### ☁️ Option B: AWS EKS (Optional, For Production Experience)
- Fully managed Kubernetes service on AWS
- Suitable for real-world infrastructure
- **Note:** May incur AWS billing

---

## ✅ Prerequisites

### For Local Kubernetes:
- Docker Desktop (with Kubernetes enabled)  
  **OR**  
- Minikube
- `kubectl` CLI

### For AWS EKS (Optional):
- AWS account
- AWS CLI configured
- `eksctl`
- `kubectl`

---

## 🧪 Option A: Local Kubernetes Setup

### Step 1: Enable Kubernetes

**Docker Desktop:**
- Open Docker Desktop → Settings → Kubernetes
- Enable **“Enable Kubernetes”**
- Click **“Apply & Restart”**
- Wait until Kubernetes status is green ✅

**OR Minikube:**

```bash
minikube start
minikube addons enable metrics-server
eval $(minikube docker-env)
```

---

### Step 2: Build Docker Image

```bash
docker build -t my-webapp:latest .
docker images | grep my-webapp
```

---

### Step 3: Deploy to Kubernetes

```bash
kubectl apply -f k8s/app.yaml
kubectl get pods
kubectl get services
kubectl get pods -w
```

---

### Step 4: Access the Application

**Docker Desktop:**

```bash
kubectl get services my-webapp-service
# Use the EXTERNAL-IP shown
```

**Minikube:**

```bash
minikube service my-webapp-service --url
```

---

### Step 5: Test Kubernetes Features

**Scaling:**

```bash
kubectl scale deployment my-webapp --replicas=5
kubectl get pods -w
kubectl scale deployment my-webapp --replicas=2
```

**Self-Healing:**

```bash
kubectl delete pod [POD-NAME]
kubectl get pods -w
```

**Rolling Updates:**

```bash
kubectl set image deployment/my-webapp webapp=my-webapp:v2
kubectl rollout status deployment/my-webapp
```

---

## ☁️ Option B: AWS EKS Setup (Optional)

### Step 1: Create EKS Cluster

```bash
chmod +x eks-setup.sh
./eks-setup.sh
```

### Step 2: Push Docker Image to ECR

```bash
aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin <ACCOUNT-ID>.dkr.ecr.us-east-1.amazonaws.com

docker tag my-webapp:latest <ACCOUNT-ID>.dkr.ecr.us-east-1.amazonaws.com/my-webapp:latest

docker push <ACCOUNT-ID>.dkr.ecr.us-east-1.amazonaws.com/my-webapp:latest
```

### Step 3: Update Kubernetes Deployment

- Edit `k8s/app.yaml` and update the image path
- Apply changes:

```bash
kubectl apply -f k8s/app.yaml
```

---

## 🔧 Useful Kubernetes Commands

```bash
kubectl get all
kubectl describe pod [POD-NAME]
kubectl logs [POD-NAME]
kubectl logs -f [POD-NAME]
kubectl exec -it [POD-NAME] -- /bin/sh
kubectl get events --sort-by=.metadata.creationTimestamp
kubectl port-forward service/my-webapp-service 8080:80
kubectl delete -f k8s/app.yaml
```

---

## 📂 Understanding `k8s/app.yaml`

### Deployment

```yaml
replicas: 3                   # Run 3 instances of the app
resources:
  limits:
    cpu: "500m"
    memory: "256Mi"
livenessProbe:                # Restart if unhealthy
readinessProbe:               # Send traffic only if ready
```

### Service

```yaml
type: LoadBalancer            # Public-facing
port: 80                      # External access
targetPort: 3001              # Internal container port
```

### ConfigMap

- Stores config data
- Mountable as files or environment variables
- No rebuild needed for changes

### HPA (Horizontal Pod Autoscaler)

```yaml
minReplicas: 2
maxReplicas: 10
targetCPUUtilizationPercentage: 70
```

---

## 🧪 Troubleshooting

### Local Kubernetes

| Problem | Solution |
|--------|----------|
| ❌ No resources found | `kubectl cluster-info`<br>`kubectl config current-context`<br>`minikube status` |
| ❌ ImagePullBackOff | `eval $(minikube docker-env)`<br>`docker build -t my-webapp:latest .` |
| ❌ Pods stuck in Pending | `kubectl describe nodes`<br>`kubectl get events --sort-by=.metadata.creationTimestamp` |
| ❌ Can't access app | `kubectl get services`<br>`minikube service my-webapp-service --url`<br>`kubectl logs [POD-NAME]` |
| ❌ Health checks failing | `kubectl logs [POD-NAME]`<br>`kubectl exec [POD-NAME] -- curl localhost:3001/health`<br>`kubectl port-forward [POD-NAME] 3001:3001`<br>`curl localhost:3001/health` |

### AWS EKS

| Problem | Solution |
|--------|----------|
| ❌ `eksctl` not found | Install:  
```bash
curl -sL "https://github.com/weaveworks/eksctl/releases/latest/download/eksctl_$(uname -s)_amd64.tar.gz" | tar xz -C /tmp  
sudo mv /tmp/eksctl /usr/local/bin
``` |
| ❌ Cluster creation failed |  
`aws sts get-caller-identity`  
Check IAM permissions  
Check AWS service limits |

---

## 🧹 Clean Up

### Local Kubernetes:

```bash
kubectl delete -f k8s/app.yaml
minikube stop
minikube delete
```

### AWS EKS:

```bash
kubectl delete -f k8s/app.yaml
eksctl delete cluster --name my-webapp-cluster --region us-east-1
```

---

## 📚 What You Learned

✅ Kubernetes container orchestration  
✅ Replica management and self-healing  
✅ Load balancing and service discovery  
✅ Config management with ConfigMaps  
✅ Health checks and rolling updates  
✅ Horizontal pod autoscaling  
✅ (Optional) EKS production deployment

---

## 🌐 Real-World Use Cases

- Microservices architecture  
- High availability web apps  
- Zero-downtime deployments  
- Traffic-based autoscaling  
- Resilient production systems  

---

## 🔄 Next Steps

- Learn about **Kubernetes namespaces**
- Explore **Helm** for deployment automation
- Study **Ingress controllers** for routing and security
- Move on to **Project 4: Monitoring and Observability**

---

🎉 **Congratulations! You're now running scalable apps on Kubernetes!**

