# 🌍 Wanderlust Blog - Production Deployment on AWS EKS

A full-stack blogging platform deployed on AWS EKS with CI/CD automation, monitoring, and GitOps practices.

## 🏗️ Architecture Overview

```

```

---

## 📋 Prerequisites

- AWS Account with appropriate IAM permissions
- `kubectl` installed
- `helm` installed
- `eksctl` installed
- Docker installed (for Jenkins)
- GitHub account with repository access
- Domain name (for production setup)

---

## 🚀 Deployment Guide

### 1️⃣ EKS Cluster Setup

Create EKS cluster with required permissions for CSI driver and ALB Ingress Controller:

```bash
eksctl create cluster \
  --name wanderlust-cluster \
  --region ap-south-1 \
  --nodegroup-name standard-workers \
  --node-type t3.medium \
  --nodes 3 \
  --nodes-min 2 \
  --nodes-max 4 \
  --managed
```

**⚠️ Important**: Ensure your nodes have sufficient IAM permissions for:
- EBS CSI Driver
- ALB Ingress Controller

> **Note**: Monitor node capacity - t3.medium instances can fill up quickly. Scale up if needed.

### 2️⃣ Install Required Components

Run the setup script to install ArgoCD, Prometheus, Grafana, AWS Load Balancer Controller, VPA, and Metrics Server:

```bash
cd k8s
chmod +x required-helm-charts.sh
./required-helm-charts.sh
```

This script will:
- ✅ Install ArgoCD (exposed via NodePort)
- ✅ Install Prometheus & Grafana (exposed via NodePort)
- ✅ Install AWS Load Balancer Controller
- ✅ Install Vertical Pod Autoscaler
- ✅ Install Metrics Server

**Modify the script** as per your needs before running.

### 3️⃣ Configure ArgoCD

1. Get ArgoCD initial password:
```bash
kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d
```

2. Access ArgoCD UI via NodePort or port-forward

3. Configure ArgoCD to monitor the `k8s/` folder:
   - Connect your GitHub repository
   - Set sync policy to **Auto-Sync**
   - Point to the `k8s/` directory in your repo

### 4️⃣ Jenkins CI Pipeline Setup

Jenkins runs locally and automates the entire CI process.

#### Configure Jenkins:

1. **Required Credentials**:
   - GitHub Token (for code checkout & pushing manifest changes)
   - Docker/GitHub Container Registry credentials
   - SonarQube token

2. **Environment Variables**: Update the Jenkinsfile with your values:
   - `sonarqube`
   - `git-creds`
   - `dockercred`

3. **Pipeline Stages**:
   - 🔍 Lint checking
   - 🧪 Unit tests
   - 🏗️ Build (npm/docker)
   - 📊 SonarQube code analysis
   - 🛡️ Trivy filesystem scan
   - 🐋 Docker image build
   - 🔒 Trivy image scan
   - 📤 Push image to registry
   - 🔄 Update k8s manifests with new image tag
   - 🚀 Push updated manifests to GitHub

> **Note**: Frontend-to-backend connection environment variable is hardcoded in the frontend Dockerfile. Update `VITE_API_PATH` as needed.

### 5️⃣ Database & Backend Configuration

- MongoDB and Redis run as **StatefulSets** inside EKS
- Backend connects to MongoDB/Redis using environment variables from ConfigMaps
- Configure database credentials in `k8s/config.yml`

### 6️⃣ Domain & HTTPS Setup

1. **Create ACM Certificate**:
   - Request certificate in AWS Certificate Manager
   - Use DNS validation with Route53

2. **Update Ingress**:
   - Add ACM certificate ARN in `ingress.yml`
   - Configured annotations for HTTPS redirect

3. **DNS Configuration**:
   - ALB is automatically created by Ingress Controller
   - Create CNAME record in Route53 pointing to ALB
   - Application accessible at:
     - `https://practicesayi.online` (frontend)
     - `https://practicesayi.online/api` (backend)
     - `www.practicesayi.online` (www redirect)

---

## 📊 Monitoring & Observability

### Grafana Dashboards
Access Grafana via NodePort and import dashboards for:
- Kubernetes cluster metrics
- Application performance
- Resource utilization
- Ingress/ALB metrics

### Prometheus
Metrics collection for all cluster resources and applications.

---

## 📸 Screenshots

### 🎨 Application UI
![application-ui](https://github.com/user-attachments/assets/eb0d3a71-4b2b-400f-8c00-d5214e4bb3ea)

### 🔄 Jenkins Pipeline
![jenkins-pipeline](https://github.com/user-attachments/assets/224876bb-fedf-4b74-ab0e-c336e2dc9630)

### 🔍 SonarQube Analysis
![sonarqube-results](https://github.com/user-attachments/assets/f160948a-2c16-4151-a3cc-0218d145f682)

### ☸️ Kubernetes Resources
![k8s-resources](https://github.com/user-attachments/assets/3124d2c4-c3ae-4536-86fb-e3b3750ffd12)

### 📈 Grafana Dashboards
![grafana-1](https://github.com/user-attachments/assets/63e8aa0a-5e30-4cfa-b6c0-d13024b02cc5)

![grafana-2](https://github.com/user-attachments/assets/57d0edbf-a25f-4af8-b763-37a31753bc44)

### 🌳 ArgoCD Application Tree
![argocd-tree](https://github.com/user-attachments/assets/2acd9d6d-8d97-4617-b944-cef154af9650)

---

## 🛠️ Tech Stack

| Component | Technology |
|-----------|-----------|
| Frontend | React + Vite |
| Backend | Node.js + Express |
| Database | MongoDB (StatefulSet) |
| Cache | Redis (StatefulSet) |
| Container Orchestration | Kubernetes (EKS) |
| CI/CD | Jenkins + ArgoCD |
| Code Quality | SonarQube |
| Security Scanning | Trivy |
| Monitoring | Prometheus + Grafana |
| Ingress | AWS Load Balancer Controller |
| GitOps | ArgoCD |
| DNS | Route53 |
| SSL/TLS | AWS Certificate Manager |

---

## 📝 Project Structure

```
.
├── backend/                 # Backend application code
├── frontend/                # Frontend application code
├── k8s/                     # Kubernetes manifests
│   ├── backend-dep-ser.yml
│   ├── backend-hpa.yml
│   ├── frontend-dep-ser.yml
│   ├── config.yml
│   ├── ingress.yml
│   ├── mongo-db-vpa.yml
│   ├── mongo-statefulset.yml
│   ├── redis-dep-ser.yml
│   ├── redis-vpa.yml
│   └── required-helm-charts.sh
├── Jenkinsfile              # CI pipeline configuration
└── README.md
```

---

## 🔐 Security Features

- ✅ Trivy filesystem & image scanning
- ✅ SonarQube code quality analysis
- ✅ HTTPS with ACM certificates
- ✅ Kubernetes secrets for sensitive data

---

## 🎯 Key Features

- ✨ Automated CI/CD with Jenkins & ArgoCD
- 🔄 GitOps-based deployment
- 📊 Real-time monitoring with Prometheus & Grafana
- 🚀 Auto-scaling with HPA & VPA
- 🔒 HTTPS enabled with custom domain
- 🛡️ Security scanning integrated in pipeline
- 📦 Stateful applications (MongoDB, Redis)

---

## 📞 Support

For issues or questions, please open an issue in the GitHub repository.

---

## 📄 License

[Add your license here]
