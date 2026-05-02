# Secure Healthcare API - Blue-Green Deployment on Kubernetes with Jenkins CI/CD

**A comprehensive DevOps assignment demonstrating secure CI/CD pipeline automation, containerization, and zero-downtime deployment strategy**

---

## 📋 Table of Contents

1. [Project Overview](#project-overview)
2. [Assignment Topics Coverage](#assignment-topics-coverage)
3. [Problem Statement](#problem-statement)
4. [Objectives](#objectives)
5. [Features](#features)
6. [Tech Stack](#tech-stack)
7. [Architecture](#architecture)
8. [Project Structure](#project-structure)
9. [Prerequisites](#prerequisites)
10. [Quick Start](#quick-start)
11. [Detailed Setup](#detailed-setup)
12. [Blue-Green Deployment Flow](#blue-green-deployment-flow)
13. [Security Implementation](#security-implementation)
14. [Demo Walkthrough](#demo-walkthrough)
15. [Troubleshooting](#troubleshooting)
16. [References](#references)

---

## 🎯 Project Overview

This project builds an **end-to-end secure CI/CD pipeline** for a Dockerized healthcare API with automated Blue-Green deployment on Kubernetes using Jenkins. It covers all essential DevOps practices including containerization, orchestration, CI/CD automation, and security hardening.

The healthcare API is a Flask REST application providing patient management endpoints with realistic security practices suitable for a healthcare system.

Repository naming suggestion for GitHub:
- `secure-healthcare-bluegreen-devops`

### Key Value Propositions:
- **Zero-downtime deployment** using Blue-Green strategy
- **Automatic rollback capability** if issues detected
- **Production-grade security** with Trivy scanning, RBAC, and Secret management
- **Fully automated** via Jenkins pipeline
- **Easy local testing** with Minikube

---

## 📌 Assignment Topics Coverage

| Assignment Topic | Implementation in This Project |
|---|---|
| **CI/CD Pipeline to Deploy Dockerized Application on Kubernetes using Jenkins** | Jenkins builds Docker image, runs tests, performs security scanning, pushes to registry, and deploys to Kubernetes with automated kubectl commands |
| **Automated Blue-Green Deployment using Jenkins, Kubernetes, Docker** | Blue and Green Kubernetes deployments run simultaneously; Jenkins deploys new version to Green, tests it via separate service, then switches main service selector to route production traffic from Blue to Green |
| **Secure DevOps Implementation in Healthcare System** | Healthcare API uses Kubernetes Secrets for sensitive data, non-root container execution, RBAC for least-privilege access, Trivy vulnerability scanning, health probes for reliability, resource limits for stability, and ConfigMap for configuration management |

---

## ❓ Problem Statement

Traditional application deployment approaches have several challenges:
- **Downtime during updates**: Rolling updates interrupt service availability
- **Deployment failures**: Failed deployments leave system in inconsistent state
- **Security gaps**: Images with vulnerabilities deployed to production
- **Difficulty rolling back**: Complex and error-prone manual rollback procedures
- **Secret management**: Hardcoded credentials in code or configuration files

**Solution**: Implement a secure, automated CI/CD pipeline with Blue-Green deployment strategy that minimizes downtime, enables quick rollback, and enforces security best practices.

---

## 🎓 Objectives

1. **Containerize** the healthcare application using Docker with production-grade security practices
2. **Orchestrate** deployment and management using Kubernetes on Minikube
3. **Automate** build, test, scan, and deployment processes with Jenkins
4. **Implement** Blue-Green deployment strategy for zero-downtime updates
5. **Enforce** secure DevOps practices including RBAC, Secrets, scanning, and non-root execution
6. **Demonstrate** complete CI/CD workflow from code commit to production deployment
7. **Enable** quick rollback mechanism for production stability

---

## ✨ Features

### Application Features
- RESTful API endpoints for healthcare patient management
- Health check endpoints for Kubernetes probes
- Version information for deployment verification
- Security status endpoint showing implemented practices
- In-memory patient database (suitable for demo)

### DevOps Features
- **Containerization**: Multi-stage Docker build, non-root user, minimal image
- **Kubernetes**: Deployments, Services, ConfigMap, Secrets, RBAC, Network Policies
- **Blue-Green Deployment**: Simultaneous deployments with traffic switching
- **CI/CD Pipeline**: 13-stage automated Jenkins Declarative Pipeline
- **Security**: Trivy scanning, RBAC, Secrets management, health probes, resource limits
- **High Availability**: Replica sets, pod anti-affinity, readiness/liveness probes
- **Deployment Automation**: Bash and PowerShell scripts for manual control

---

## 🛠️ Tech Stack

### Application
- **Python 3.11** with Flask framework
- **pytest** for unit testing
- **gunicorn** for production WSGI server

### Containerization
- **Docker** with multi-stage builds
- **Docker Hub** registry support

### Orchestration & Deployment
- **Kubernetes** API objects (Deployments, Services, ConfigMaps, Secrets, RBAC)
- **Minikube** for local Kubernetes cluster
- **kubectl** for cluster management

### CI/CD & Automation
- **Jenkins** Declarative Pipeline
- **Trivy** for container image scanning
- **Bash shell scripts** for Unix/Linux/macOS
- **PowerShell scripts** for Windows

### Security
- **Kubernetes Secrets** for sensitive data
- **Kubernetes RBAC** for access control
- **Kubernetes Network Policies** for network segmentation
- **Non-root container execution**
- **Health checks** (readiness, liveness, startup probes)

---

## 🏗️ Architecture

### High-Level Architecture Flow

```
┌─────────────────────────────────────────────────────────────────┐
│                       Developer                                  │
│                    Git Repository                                │
└────────────────────────┬────────────────────────────────────────┘
                         │
                         ↓
┌─────────────────────────────────────────────────────────────────┐
│                      Jenkins Server                              │
│  ┌──────────────────────────────────────────────────────────┐  │
│  │  Pipeline Stages:                                        │  │
│  │  1. Checkout → 2. Build → 3. Test → 4. Scan           │  │
│  │  5. Push Image → 6. Deploy Green → 7. Test Green      │  │
│  │  8. Switch Service → 9. Verify Production             │  │
│  └──────────────────────────────────────────────────────────┘  │
└────────────────────────┬────────────────────────────────────────┘
                         │
        ┌────────────────┼────────────────┐
        ↓                ↓                ↓
   ┌─────────┐    ┌──────────────┐   ┌──────────┐
   │  Docker │    │   Trivy      │   │ Docker   │
   │  Build  │    │  Scanning    │   │   Hub    │
   └────┬────┘    └──────────────┘   └──────────┘
        │
        ↓
┌─────────────────────────────────────────────────────────────────┐
│                    Minikube Kubernetes Cluster                   │
│                                                                  │
│  ┌────────────────────────────────────────────────────────┐   │
│  │ healthcare-devops Namespace                            │   │
│  │                                                        │   │
│  │  ┌──────────────────┐    ┌──────────────────┐       │   │
│  │  │   Blue Service   │    │  Green Service   │       │   │
│  │  │  (Production)    │    │   (Testing)      │       │   │
│  │  └────────┬─────────┘    └────────┬─────────┘       │   │
│  │           │                       │                  │   │
│  │  ┌────────▼──────────┐  ┌─────────▼────────────┐  │   │
│  │  │ Blue Deployment   │  │  Green Deployment    │  │   │
│  │  │ (Pods: 2 replicas)│  │ (Pods: 2 replicas)   │  │   │
│  │  └────────────────────┘  └──────────────────────┘  │   │
│  │                                                     │   │
│  │  ConfigMap │ Secret │ RBAC │ Network Policy        │   │
│  └────────────────────────────────────────────────────┘   │
│                                                            │
└─────────────────────────────────────────────────────────────┘
```

### Blue-Green Deployment Flow

```
INITIAL STATE:
  healthcare-service selector: {app: healthcare-api, version: blue}
  Production traffic → Blue Pods

DEPLOYMENT PROCESS:
  1. Jenkins builds new image (green version)
  2. Jenkins deploys image to Green deployment
  3. Green pods start and become ready
  4. Jenkins tests Green via healthcare-green-service
  5. If tests pass, Jenkins patches healthcare-service selector
  
FINAL STATE:
  healthcare-service selector: {app: healthcare-api, version: green}
  Production traffic → Green Pods
  Blue remains running for quick rollback

ROLLBACK (if needed):
  Jenkins/Operator patches selector back to Blue
  healthcare-service selector: {app: healthcare-api, version: blue}
  Production traffic → Blue Pods (within seconds)
```

---

## 📁 Project Structure

```
secure-healthcare-bluegreen-devops/
│
├── app/                              # Flask Application
│   ├── app.py                       # Main Flask application with 6 endpoints
│   ├── __init__.py                  # Package initialization
│   ├── requirements.txt              # Python dependencies
│   └── test_app.py                  # pytest unit tests
│
├── Dockerfile                        # Multi-stage production Docker image
├── .dockerignore                     # Docker build exclusions
├── .gitignore                        # Git exclusions
├── .env.example                      # Environment variables template
├── Jenkinsfile                       # 13-stage Declarative Jenkins Pipeline
│
├── k8s/                             # Kubernetes Manifests
│   ├── namespace.yaml               # healthcare-devops namespace
│   ├── configmap.yaml               # Non-sensitive configuration
│   ├── secret.yaml                  # Sensitive secrets management
│   ├── rbac.yaml                    # ServiceAccount, Role, RoleBinding
│   ├── blue-deployment.yaml         # Blue deployment with security context
│   ├── green-deployment.yaml        # Green deployment with security context
│   ├── service.yaml                 # Main service + Blue testing service
│   ├── green-service.yaml           # Green testing service
│   └── network-policy.yaml          # Network segmentation policy
│
├── scripts/                         # Automation Scripts
│   ├── start-minikube.sh            # Initialize Minikube cluster
│   ├── deploy-blue.sh               # Deploy Blue environment
│   ├── deploy-green.sh              # Deploy Green environment
│   ├── switch-to-blue.sh            # Switch traffic to Blue
│   ├── switch-to-green.sh           # Switch traffic to Green
│   ├── rollback.sh                  # Rollback to Blue
│   ├── verify.sh                    # Verify deployment status
│   └── windows/                     # Windows PowerShell versions
│       ├── start-minikube.ps1
│       ├── deploy-blue.ps1
│       ├── deploy-green.ps1
│       ├── switch-to-blue.ps1
│       ├── switch-to-green.ps1
│       ├── rollback.ps1
│       └── verify.ps1
│
├── docs/                            # Comprehensive Documentation
│   ├── PROJECT_REPORT.md            # Academic report format
│   ├── DEMO_STEPS.md                # Step-by-step demo walkthrough
│   ├── SECURITY_NOTES.md            # Security implementation details
│   ├── ARCHITECTURE.md              # Architecture diagrams and explanation
│   └── VIVA_QUESTIONS.md            # 25+ interview questions with answers
│
└── README.md                        # This file
```

---

## 📦 Prerequisites

### System Requirements
- **OS**: Windows (with WSL2 or Docker Desktop), macOS, or Linux
- **RAM**: Minimum 8GB (for Minikube with multiple pods)
- **Disk Space**: 10GB free
- **Network**: Internet access for package downloads

### Required Software

#### All Platforms
```bash
# Docker Desktop (includes Docker daemon and Docker CLI)
# Download: https://www.docker.com/products/docker-desktop

# Minikube (Kubernetes distribution for local development)
# Download: https://minikube.sigs.k8s.io/docs/start/

# kubectl (Kubernetes command-line tool)
# Download: https://kubernetes.io/docs/tasks/tools/

# Python 3.11+
# Download: https://www.python.org/downloads/

# Git
# Download: https://git-scm.com/downloads/
```

#### For Jenkins (optional, can run locally)
```bash
# Jenkins
# Download: https://www.jenkins.io/download/

# Java 11+ (required for Jenkins)
# Download: https://www.oracle.com/java/technologies/downloads/
```

#### For Security Scanning
```bash
# Trivy (vulnerability scanner)
# Install: https://github.com/aquasecurity/trivy
# Or: curl -sfL https://raw.githubusercontent.com/aquasecurity/trivy/main/contrib/install.sh | sh -s -- -b /usr/local/bin
```

### Verification
```bash
# Verify installations
docker --version          # Should show Docker version
minikube version          # Should show Minikube version
kubectl version --client  # Should show kubectl version
python3 --version         # Should show Python 3.11+
git --version            # Should show Git version
```

---

## 🚀 Quick Start

### 1️⃣ Clone Repository
```bash
cd d:\Akul
# Repository already in: secure-healthcare-bluegreen-devops/
cd secure-healthcare-bluegreen-devops
```

### 2️⃣ Start Minikube
```bash
# Linux/macOS
chmod +x scripts/*.sh
./scripts/start-minikube.sh

# Windows PowerShell
.\scripts\windows\start-minikube.ps1
```

### 3️⃣ Build Docker Image
```bash
# Build local demo images
docker build -t healthcare-api:blue .
docker build -t healthcare-api:green .

# Load the images into Minikube for local Kubernetes testing
minikube image load healthcare-api:blue
minikube image load healthcare-api:green
```

### 4️⃣ Deploy Blue Environment
```bash
# Linux/macOS
./scripts/deploy-blue.sh

# Windows
.\scripts\windows\deploy-blue.ps1
```

### 5️⃣ Verify Deployment
```bash
# Linux/macOS
./scripts/verify.sh

# Windows
.\scripts\windows\verify.ps1

# Or manually
kubectl get pods -n healthcare-devops
kubectl get svc -n healthcare-devops
```

### 6️⃣ Test Application
```bash
# Port-forward to access locally
kubectl port-forward svc/healthcare-service 8080:80 -n healthcare-devops

# In another terminal, test endpoints
curl http://localhost:8080/health
curl http://localhost:8080/version
curl http://localhost:8080/patients
curl http://localhost:8080/security-status
```

---

## 🔧 Detailed Setup

### Step 1: Environment Setup

```bash
# Copy environment template
cp .env.example .env

# Edit .env with your values
# Important: Set DOCKERHUB_USERNAME to your Docker Hub username
```

Notes:
- `.env.example` is a template for local setup.
- `.env` should remain local and must not be committed.
- Default demo value uses `DOCKERHUB_USERNAME=kulharshit21`; change it if another user runs the project.

### Step 2: Python Application Setup (Optional, for local testing)

```bash
# Navigate to app directory
cd app

# Create virtual environment
python3 -m venv venv

# Activate virtual environment
# Linux/macOS
source venv/bin/activate
# Windows
.\venv\Scripts\activate

# Install dependencies
pip install -r requirements.txt

# Run tests
pytest test_app.py -v

# Run application locally
# Linux/macOS
APP_VERSION=blue-v1 DEPLOYMENT_COLOR=blue ENVIRONMENT=production python app.py

# Windows PowerShell
$env:APP_VERSION="blue-v1"; $env:DEPLOYMENT_COLOR="blue"; $env:ENVIRONMENT="production"; python app.py

# Access at http://localhost:5000
```

### Step 3: Docker Image Build

```bash
# Update Dockerfile image references if needed
# Currently uses multi-stage build

# Build local demo images
docker build -t healthcare-api:blue -f Dockerfile .
docker build -t healthcare-api:green -f Dockerfile .

# Load into Minikube
minikube image load healthcare-api:blue
minikube image load healthcare-api:green

# Test locally
docker run -e APP_VERSION=blue-v1 \
           -e DEPLOYMENT_COLOR=blue \
           -e ENVIRONMENT=development \
           -p 5000:5000 \
           healthcare-api:blue

# Access at http://localhost:5000
```

### Step 4: Kubernetes Cluster Setup

```bash
# Start Minikube
minikube start --driver=docker --cpus=4 --memory=8192

# Verify cluster
kubectl get nodes
kubectl cluster-info

# Create namespace and deploy
./scripts/deploy-blue.sh
```

### Step 5: Jenkins Pipeline Setup (Optional)

```bash
# If running Jenkins locally
# Download and run Jenkins

# Configure Jenkins:
# 1. Install plugins: Kubernetes, Docker, Git, Pipeline
# 2. Add Docker Hub credentials
# 3. Create Pipeline job
# 4. Point to Jenkinsfile in repository
# 5. Configure service account in Minikube for Jenkins

# For this demo, you can:
# - Use manual scripts instead of Jenkins
# - Or test Jenkinsfile in declarative syntax
# - Or setup Jenkins in Docker container
```

### Jenkins Demo Modes

- `Jenkinsfile` = intended full CI/CD automation (build, scan, push, deploy/switch/rollback) for a properly configured Jenkins agent.
- `Jenkinsfile.demo` = safe local Jenkins viva pipeline:
  - runs checkout + Python dependency + pytest
  - attempts Docker/kubectl/Trivy commands
  - marks unavailable tooling as UNSTABLE instead of failing the whole demo
- If Jenkins agent does not have Docker/kubectl configured, use `Jenkinsfile.demo` for CI proof and Minikube terminal screenshots for CD proof.
- If running Jenkins in Docker locally, prefer `http://localhost:9090` to avoid conflict with Kubernetes demo port-forward usage on `8080`.

---

## 🔄 Blue-Green Deployment Flow

### Scenario: Deploying new version (Green) to production

#### Step 1: Initial State
```bash
# Blue is production
kubectl get svc healthcare-service -n healthcare-devops -o jsonpath='{.spec.selector.app}={.spec.selector.version}{"\n"}'
# Output: app=healthcare-api version=blue

# Test production
curl -s http://$(minikube service healthcare-service -n healthcare-devops --url)/version | jq
# Output: {"version":"blue-v1"}
```

#### Step 2: Deploy Green
```bash
# Deploy new version to Green
./scripts/deploy-green.sh

# If you are using Minikube directly, make sure the image is loaded first
minikube image load healthcare-api:green

# Verify Green pods are running
kubectl get pods -l version=green -n healthcare-devops

# Test Green via separate service
kubectl port-forward svc/healthcare-green-service 8081:80 -n healthcare-devops
curl http://localhost:8081/version
# Output: {"version":"green-v2"}
```

#### Step 3: Run Tests on Green
```bash
# Green is isolated and can be tested thoroughly
# Jenkins would run smoke tests automatically

# Manual test
curl http://localhost:8081/health
curl http://localhost:8081/patients
```

#### Step 4: Switch Traffic to Green
```bash
# When tests pass, switch production traffic
./scripts/switch-to-green.sh

# Verify switch
kubectl get svc healthcare-service -n healthcare-devops -o jsonpath='{.spec.selector.app}={.spec.selector.version}{"\n"}'
# Output: app=healthcare-api version=green

# Test new production version
curl -s http://$(minikube service healthcare-service -n healthcare-devops --url)/version
# Output: {"version":"green-v2"}
```

#### Step 5: Rollback if Needed
```bash
# If Green has issues, rollback instantly
./scripts/switch-to-blue.sh

# Verify rollback
kubectl get svc healthcare-service -n healthcare-devops -o jsonpath='{.spec.selector.app}={.spec.selector.version}{"\n"}'
# Output: app=healthcare-api version=blue

# Confirm production on Blue again
curl -s http://$(minikube service healthcare-service -n healthcare-devops --url)/version
# Output: {"version":"blue-v1"}
```

---

## 🔒 Security Implementation

### 1. Container Security
- **Non-root user**: Application runs as user `healthcare` (UID 1000)
- **Multi-stage build**: Reduces final image size and attack surface
- **Minimal base image**: Uses `python:3.11-slim`
- **No setuid binaries**: Configured in Dockerfile

### 2. Kubernetes Secrets
- Sensitive data (JWT_SECRET, DATABASE_PASSWORD) stored in Kubernetes Secret
- Secrets mounted as environment variables
- Never logged or exposed in responses

### 3. Kubernetes RBAC
- Dedicated ServiceAccount with limited permissions
- Role restricted to deployment management within namespace only
- RoleBinding connects ServiceAccount to Role

### 4. Image Vulnerability Scanning
- **Trivy** scans Docker image for known CVEs
- Jenkins pipeline includes scanning stage
- Can block deployment on critical vulnerabilities

### 5. Health Checks
- **Readiness Probe**: Verifies pod is ready for traffic
- **Liveness Probe**: Restarts pod if unhealthy
- **Startup Probe**: Gives pods time to initialize

### 6. Resource Limits
- CPU: Requests 100m, Limits 500m
- Memory: Requests 128Mi, Limits 512Mi
- Prevents resource exhaustion attacks

### 7. Network Policies
- Restrictive ingress/egress rules
- Only required traffic allowed
- Provides network segmentation

### 8. ConfigMap for Configuration
- Non-sensitive configuration separated from code
- Environment-specific values managed centrally
- Easy to update without redeploying

### 9. Blue-Green Strategy
- Zero-downtime deployments
- Quick rollback capability
- Reduced blast radius of failures

For detailed security explanation, see [docs/SECURITY_NOTES.md](docs/SECURITY_NOTES.md)

---

## 📊 Demo Walkthrough

### Demo Objective
Show complete CI/CD pipeline flow from code change to production deployment using Blue-Green strategy.

### Prerequisites
- Minikube running: `minikube status`
- Blue environment deployed: `kubectl get all -n healthcare-devops`
- Docker image available locally or in registry

### Demo Script (15-20 minutes)

See [docs/DEMO_STEPS.md](docs/DEMO_STEPS.md) for complete step-by-step instructions.

Quick version:

```bash
# 1. Check current production (Blue)
kubectl port-forward svc/healthcare-service 8080:80 -n healthcare-devops
curl http://localhost:8080/version  # Shows blue-v1

# 2. Build and deploy Green
docker build -t healthcare-api:green .
./scripts/deploy-green.sh

# 3. Test Green before switching
kubectl port-forward svc/healthcare-green-service 8081:80 -n healthcare-devops
curl http://localhost:8081/version  # Shows green-v2

# 4. Switch traffic to Green
./scripts/switch-to-green.sh
curl http://localhost:8080/version  # Now shows green-v2

# 5. Show rollback capability
./scripts/switch-to-blue.sh
curl http://localhost:8080/version  # Back to blue-v1
```

---

## 🐛 Troubleshooting

### Minikube Issues

```bash
# Minikube won't start
minikube delete
minikube start --driver=docker

# Check Minikube logs
minikube logs

# Verify Docker is running
docker ps

# Access Minikube Docker
eval $(minikube docker-env)
docker images  # Should see local images
```

### Kubernetes Deployment Issues

```bash
# Check pod status
kubectl get pods -n healthcare-devops
kubectl describe pod <pod-name> -n healthcare-devops
kubectl logs <pod-name> -n healthcare-devops

# Check deployment status
kubectl rollout status deployment/healthcare-api-blue -n healthcare-devops
kubectl rollout history deployment/healthcare-api-blue -n healthcare-devops

# Restart deployment
kubectl rollout restart deployment/healthcare-api-blue -n healthcare-devops
```

### Service Connectivity Issues

```bash
# Check service
kubectl get svc -n healthcare-devops
kubectl describe svc healthcare-service -n healthcare-devops

# Check endpoints
kubectl get endpoints -n healthcare-devops

# Test connectivity
kubectl run -it --rm debug --image=busybox:latest --restart=Never -- sh
# Inside pod: wget -O- http://healthcare-service:80/health

# Port-forward with verbose
kubectl port-forward -v 10 svc/healthcare-service 8080:80 -n healthcare-devops
```

### Docker Issues

```bash
# Login to Docker Hub
docker login

# Check image locally
docker images | grep healthcare-api

# Build with verbose output
docker build -t healthcare-api:local . --progress=plain

# Check image history
docker history healthcare-api:local
```

### Common Errors

| Error | Solution |
|-------|----------|
| `error: no context named "minikube"` | Run `minikube start` first |
| `pod fails to pull image` | Ensure image tag is correct and image exists |
| `CrashLoopBackOff` | Check `kubectl logs` for application errors |
| `connection refused` | Verify service is running and port-forward is active |
| `permission denied` | Run scripts with `chmod +x scripts/*.sh` first |

---

## 📚 Documentation

- [PROJECT_REPORT.md](docs/PROJECT_REPORT.md) - Comprehensive academic report
- [DEMO_STEPS.md](docs/DEMO_STEPS.md) - Detailed demo walkthrough
- [SECURITY_NOTES.md](docs/SECURITY_NOTES.md) - Security implementation details
- [ARCHITECTURE.md](docs/ARCHITECTURE.md) - Architecture diagrams and explanations
- [VIVA_QUESTIONS.md](docs/VIVA_QUESTIONS.md) - Interview Q&A (25+ questions)

---

## 🔗 References

### Official Documentation
- [Docker Documentation](https://docs.docker.com/)
- [Kubernetes Documentation](https://kubernetes.io/docs/)
- [Minikube Documentation](https://minikube.sigs.k8s.io/)
- [Jenkins Documentation](https://www.jenkins.io/doc/)
- [Flask Documentation](https://flask.palletsprojects.com/)

### Blue-Green Deployment
- [Martin Fowler: Blue-Green Deployment](https://martinfowler.com/bliki/BlueGreenDeployment.html)
- [Kubernetes Deployment Strategies](https://container-solutions.com/kubernetes-deployment-strategies/)

### Security
- [Trivy Scanner](https://github.com/aquasecurity/trivy)
- [Kubernetes RBAC](https://kubernetes.io/docs/reference/access-authn-authz/rbac/)
- [Kubernetes Security Best Practices](https://kubernetes.io/docs/concepts/security/)

---

## 📝 License

This project is created for educational purposes as a DevOps assignment.

---

## 👥 Author

Created for DevOps Engineering Assignment - Secure CI/CD with Blue-Green Deployment

---

## ⚠️ Important Notes

1. **Demo Secrets**: Secrets in this project are for demonstration only. In production, use:
   - HashiCorp Vault
   - AWS Secrets Manager
   - Azure Key Vault
   - Kubernetes External Secrets Operator

2. **Docker Hub Credentials**: Update `DOCKERHUB_USERNAME` in `.env` with your actual username before pushing images.

3. **Network Policy**: NetworkPolicy requires CNI support. Test with Calico or Cilium if not working in vanilla Minikube.

4. **Resource Limits**: Adjust based on your machine capabilities in `k8s/*-deployment.yaml`.

5. **Production Considerations**:
   - Use managed Kubernetes (EKS, AKS, GKE) instead of Minikube
   - Setup persistent storage for databases
   - Implement monitoring (Prometheus, Grafana)
   - Use service mesh (Istio) for advanced traffic management
   - Implement GitOps (ArgoCD) for declarative deployments

6. **Windows Demo Guidance**:
   - Use **PowerShell** commands and scripts under `scripts/windows/`
   - Build and load **both** images before Kubernetes apply:
     - `docker build -t healthcare-api:blue .`
     - `docker build -t healthcare-api:green .`
     - `minikube image load healthcare-api:blue`
     - `minikube image load healthcare-api:green`
   - Main service uses `healthcare-service` on port-forward `8080`
   - Green testing service uses `healthcare-green-service` on port-forward `8081`
   - If localhost shows old version after service selector patch, restart the main `8080` port-forward tunnel

7. **Jenkins Runtime Scope**:
   - Jenkinsfile is implemented and reviewed, but Jenkins runtime execution was not available on this local machine
   - Runtime verification here is manual via Docker, Trivy, kubectl, and Minikube (same flow Jenkins automates)

8. **Trivy Findings Scope**:
   - Trivy scanning is integrated and executed as evidence
   - HIGH findings may still appear in local demo images; this is expected for assignment proof
   - Current local result: HIGH findings present, CRITICAL findings absent

---

## 🎓 Learning Outcomes

After completing this project, you will understand:

✅ How to containerize Python applications with Docker  
✅ How to deploy applications to Kubernetes  
✅ How to implement Blue-Green deployment strategy  
✅ How to automate deployments with Jenkins pipelines  
✅ How to implement Kubernetes RBAC and Secrets  
✅ How to scan images for vulnerabilities with Trivy  
✅ How to implement health checks and probes  
✅ How to design zero-downtime deployments  
✅ How to implement quick rollback mechanisms  
✅ How to follow security best practices in DevOps  

---

**Last Updated**: May 2, 2026
**Status**: Runtime-verified locally on Minikube except Jenkins execution
