## Demo Steps: Secure Blue-Green Deployment

**Duration**: 15-20 minutes  
**Audience**: DevOps evaluation, college assignment viva  
**Objective**: Demonstrate complete CI/CD pipeline and Blue-Green deployment flow

---

## Prerequisites

Before starting demo:

```bash
# 1. Minikube running
minikube status
# Expected: host: Running, kubelet: Running, apiserver: Running

# 2. Blue environment deployed
kubectl get all -n healthcare-devops
# Expected: healthcare-api-blue deployment with 2 pods, services running

# 3. Docker image available
docker images | grep healthcare-api
# Expected: healthcare-api:blue and healthcare-api:green

# Build the demo images if they are not present yet
docker build -t healthcare-api:blue .
docker build -t healthcare-api:green .

# Load them into Minikube for local Kubernetes testing
minikube image load healthcare-api:blue
minikube image load healthcare-api:green

# 4. Scripts executable
chmod +x scripts/*.sh
ls -la scripts/
```

```powershell
# Windows PowerShell equivalent checks
minikube status
kubectl get all -n healthcare-devops
docker images | findstr healthcare-api

# Build and load both images before deployment demos
docker build -t healthcare-api:blue .
docker build -t healthcare-api:green .
minikube image load healthcare-api:blue
minikube image load healthcare-api:green
```

---

## Demo Script (Step-by-Step)

### Part 1: Show Initial Blue Deployment (3 minutes)

#### Step 1.1: Verify Cluster
```bash
# Show Minikube cluster running
echo "=== Minikube Status ==="
minikube status

# Show cluster info
kubectl cluster-info
kubectl get nodes

# Expected Output:
# NAME       STATUS   ROLES    AGE   VERSION
# minikube   Ready    master   2d    v1.28.0
```

#### Step 1.2: Verify healthcare-devops Namespace
```bash
# Show namespace exists
echo "=== Healthcare DevOps Namespace ==="
kubectl get ns | grep healthcare-devops

# Show all resources in namespace
kubectl get all -n healthcare-devops

# Expected: 2 Blue deployments, 0-2 Green (can be not yet deployed)
```

#### Step 1.3: Check Current Production Version
```bash
# Port-forward to production service
echo "=== Setting up port-forward to production service ==="
kubectl port-forward svc/healthcare-service 8080:80 -n healthcare-devops &
PF_PID=$!
sleep 2

# Test production service
echo "=== Testing Production Service ==="
curl -s http://localhost:8080/version | python3 -m json.tool

# Expected Output:
# {
#     "app": "healthcare-api",
#     "version": "blue-v1",
#     "deployment": "blue",
#     "environment": "production"
# }

# Also test health and patients
echo ""
echo "=== Health Check ==="
curl -s http://localhost:8080/health | python3 -m json.tool

echo ""
echo "=== Patient Records ==="
curl -s http://localhost:8080/patients | python3 -m json.tool

# Stop port-forward
kill $PF_PID 2>/dev/null
```

#### Step 1.4: Show Service Selector
```bash
echo "=== Current Service Selector ==="
kubectl get svc healthcare-service -n healthcare-devops -o jsonpath='{.spec.selector.app}={.spec.selector.version}{"\n"}'

# Expected: app=healthcare-api version=blue
```

**Demo Talking Points:**
- "The healthcare-service currently routes to Blue deployment"
- "Blue is running version 1 of the API"
- "Production is healthy and serving requests"
- "Now let's deploy a new version to Green"

---

### Part 2: Deploy Green Version (3 minutes)

#### Step 2.1: Show Green Deployment
```bash
# Show green deployment doesn't have pods yet (or outdated version)
echo "=== Green Deployment Status Before ==="
kubectl get deployment healthcare-api-green -n healthcare-devops
kubectl get pods -l version=green -n healthcare-devops

# Expected: Either no pods or pods not ready
```

#### Step 2.2: Execute Deploy Green Script
```bash
# Deploy Green with new image
echo "=== Running deploy-green.sh ==="
./scripts/deploy-green.sh

# Expected Output:
# - Applying Green Deployment...
# - Updating Green deployment image...
# - Waiting for Green deployment to be ready...
# - ✓ Green deployment completed
```

#### Step 2.3: Verify Green Pods Are Ready
```bash
# Wait and monitor Green pod startup
echo "=== Monitoring Green Pod Startup ==="
watch -n 1 'kubectl get pods -l version=green -n healthcare-devops'

# Press Ctrl+C to exit watch
# Expected: 2 pods in Running state with 1/1 ready
```

#### Step 2.4: Check Green Deployment Replicas
```bash
echo "=== Green Deployment Details ==="
kubectl get deployment healthcare-api-green -n healthcare-devops -o wide

# Expected:
# NAME                   READY   UP-TO-DATE   AVAILABLE   ...
# healthcare-api-green   2/2     2            2           ...
```

**Demo Talking Points:**
- "Green deployment has been created with the new version"
- "Two replicas are starting up"
- "Green is isolated from Blue and production traffic"
- "Now let's test Green before switching traffic"

---

### Part 3: Test Green Version (4 minutes)

#### Step 3.1: Set Up Port-Forward to Green Service
```bash
echo "=== Setting up port-forward to Green testing service ==="
kubectl port-forward svc/healthcare-green-service 8081:80 -n healthcare-devops &
GREEN_PF_PID=$!
sleep 2
```

#### Step 3.2: Test Green Version Endpoint
```bash
# Test that Green is running new version
echo "=== Testing Green /version Endpoint ==="
curl -s http://localhost:8081/version | python3 -m json.tool

# Expected Output:
# {
#     "app": "healthcare-api",
#     "version": "green-v2",
#     "deployment": "green",
#     "environment": "production"
# }

# Emphasize the version is "green-v2" not "blue-v1"
```

#### Step 3.3: Test Green Health
```bash
echo "=== Testing Green /health Endpoint ==="
curl -s http://localhost:8081/health | python3 -m json.tool

# Expected: {"status":"healthy","service":"healthcare-api","deployment":"green"}
```

#### Step 3.4: Test Green Patients Endpoint
```bash
echo "=== Testing Green /patients Endpoint ==="
curl -s http://localhost:8081/patients | python3 -m json.tool

# Expected: List of patient records
```

#### Step 3.5: Test Green Security Status
```bash
echo "=== Testing Green /security-status Endpoint ==="
curl -s http://localhost:8081/security-status | python3 -m json.tool

# Show security features implemented
```

#### Step 3.6: Show Logs of Green Pods
```bash
echo "=== Green Pod Logs ==="
kubectl logs -l version=green -n healthcare-devops --tail=20

# Expected: Access logs or application logs showing requests
```

#### Step 3.7: Cleanup Port-Forward
```bash
kill $GREEN_PF_PID 2>/dev/null
```

**Demo Talking Points:**
- "Green is running version 2 with new features"
- "All endpoints working correctly"
- "Security features are in place"
- "Green has passed smoke tests"
- "Safe to switch production traffic to Green"

---

### Part 4: Switch Traffic to Green (3 minutes)

#### Step 4.1: Show Both Deployments Running
```bash
echo "=== Both Blue and Green Running ==="
kubectl get pods -n healthcare-devops

# Expected: 2 Blue pods + 2 Green pods (4 total)
```

#### Step 4.2: Show Current Service Selector
```bash
echo "=== Service Selector Before Switch ==="
kubectl get svc healthcare-service -n healthcare-devops -o jsonpath='{.spec.selector.app}={.spec.selector.version}{"\n"}'

# Expected: app=healthcare-api version=blue
```

#### Step 4.3: Execute Switch to Green
```bash
echo "=== Switching Traffic to Green ==="
./scripts/switch-to-green.sh

# Expected Output:
# - Current service selector: app=healthcare-api version=blue
# - Patching healthcare-service selector to Green...
# - ✓ Traffic switched to Green
# - New service selector: app=healthcare-api version=green
```

#### Step 4.4: Verify Service Selector Changed
```bash
echo "=== Service Selector After Switch ==="
kubectl get svc healthcare-service -n healthcare-devops -o jsonpath='{.spec.selector.app}={.spec.selector.version}{"\n"}'

# Expected: app=healthcare-api version=green
```

#### Step 4.5: Verify Endpoints Updated
```bash
echo "=== Service Endpoints ==="
kubectl get endpoints healthcare-service -n healthcare-devops

# Expected: IPs of Green pods (not Blue)
```

> If `curl http://localhost:8080/version` still shows old version after selector switch, restart the main `kubectl port-forward service/healthcare-service 8080:80 -n healthcare-devops` tunnel and test again.

**Demo Talking Points:**
- "Service selector has been patched from Blue to Green"
- "This single change redirects ALL production traffic to Green"
- "The change took less than 1 second"
- "No downtime, seamless switch"
- "Blue remains running for instant rollback"

---

### Part 5: Verify New Production (2 minutes)

#### Step 5.1: Port-Forward to Production Service (Now Green)
```bash
echo "=== Setting up port-forward to production service ==="
kubectl port-forward svc/healthcare-service 8080:80 -n healthcare-devops &
PROD_PF_PID=$!
sleep 2
```

#### Step 5.2: Test Production (Now Green)
```bash
echo "=== Testing Production Service (Now Running Green) ==="
curl -s http://localhost:8080/version | python3 -m json.tool

# Expected Output:
# {
#     "version": "green-v2",
#     "deployment": "green",
#     ...
# }

# Key Point: Production is now on Green!
```

#### Step 5.3: Test All Endpoints
```bash
echo "=== Production Health Check ==="
curl -s http://localhost:8080/health | python3 -m json.tool

echo "=== Production Patients ==="
curl -s http://localhost:8080/patients | python3 -m json.tool

echo "=== Production Security Status ==="
curl -s http://localhost:8080/security-status | python3 -m json.tool
```

#### Step 5.4: Cleanup
```bash
kill $PROD_PF_PID 2>/dev/null
```

**Demo Talking Points:**
- "Production is now running Green version"
- "All endpoints working correctly"
- "Zero downtime achieved"
- "Users experienced no service interruption"
- "Now let's show the rollback capability"

---

### Part 6: Demonstrate Rollback (3 minutes)

#### Step 6.1: Show Both Versions Still Running
```bash
echo "=== All Deployments Still Running ==="
kubectl get pods -n healthcare-devops

# Expected: Blue (2 pods) + Green (2 pods) both running
```

#### Step 6.2: Show Current Service Points to Green
```bash
echo "=== Current Production Points to Green ==="
kubectl get svc healthcare-service -n healthcare-devops -o jsonpath='{.spec.selector.app}={.spec.selector.version}{"\n"}'

# Expected: app=healthcare-api version=green
```

#### Step 6.3: Simulate Issue - Switch Back to Blue
```bash
echo "=== Simulating Production Issue - Rolling Back to Blue ==="
./scripts/rollback.sh

# Expected Output:
# - ⚠️ INITIATING ROLLBACK
# - Patching healthcare-service selector back to Blue...
# - ✓ ROLLBACK COMPLETED
```

#### Step 6.4: Verify Rollback
```bash
echo "=== Service Selector After Rollback ==="
kubectl get svc healthcare-service -n healthcare-devops -o jsonpath='{.spec.selector.app}={.spec.selector.version}{"\n"}'

# Expected: app=healthcare-api version=blue
```

#### Step 6.5: Test Production on Blue Again
```bash
echo "=== Port-forward after rollback ==="
kubectl port-forward svc/healthcare-service 8080:80 -n healthcare-devops &
ROLLBACK_PF_PID=$!
sleep 2

echo "=== Testing Production (Back on Blue) ==="
curl -s http://localhost:8080/version | python3 -m json.tool

# Expected: "version": "blue-v1"

kill $ROLLBACK_PF_PID 2>/dev/null
```

> Same note: if selector changed but localhost output looks stale, restart the main `8080` port-forward and retest.

## Jenkins Runtime Note

Jenkinsfile is implemented, but Jenkins service/runtime was not available on this machine during local validation.  
Runtime verification was executed manually with Docker, Trivy, kubectl, and Minikube.

**Demo Talking Points:**
- "Blue and Green can be swapped instantly"
- "Rollback took less than 5 seconds"
- "Production is back on stable version"
- "Issue investigation can happen on Green"
- "This eliminates deployment risk"

---

### Part 7: Show Deployment Information (2 minutes)

#### Step 7.1: Run Verify Script
```bash
./scripts/verify.sh

# Shows:
# - All deployments
# - All pods
# - All services
# - Current selectors
# - RBAC configuration
# - ConfigMap and Secrets
```

#### Step 7.2: Show Pod Details
```bash
echo "=== Blue Deployment Details ==="
kubectl describe deployment healthcare-api-blue -n healthcare-devops

echo "=== Green Deployment Details ==="
kubectl describe deployment healthcare-api-green -n healthcare-devops

# Show security context, probes, resource limits
```

#### Step 7.3: Show Security Configuration
```bash
echo "=== Security Context in Pods ==="
kubectl get pod -l version=blue -n healthcare-devops -o jsonpath='{.items[0].spec.securityContext}' | python3 -m json.tool

# Expected:
# {
#     "fsGroup": 1000,
#     "runAsNonRoot": true,
#     "runAsUser": 1000
# }
```

**Demo Talking Points:**
- "Pods running as non-root user (UID 1000)"
- "Resource limits prevent runaway consumption"
- "Health checks ensure pod is responsive"
- "Security practices implemented throughout"

---

## Optional: Jenkins Pipeline Demo

If Jenkins is available:

### Step 1: Show Jenkins Dashboard
```bash
# Jenkins typically at http://localhost:8080
open http://localhost:8080
```

### Step 2: Show Pipeline Job
- Navigate to Healthcare API job
- Show pipeline visualization
- Click on Build to show stages

### Step 3: Show Build Logs
- Click on a build number
- Show Console Output
- Highlight key stages:
  - Tests passing
  - Docker build successful
  - Trivy scanning results
  - Image push to registry
  - Kubernetes deployment

### Step 4: Show Jenkins Credentials
- Show Docker Hub credentials configured
- (Don't show actual values)

---

## Troubleshooting During Demo

| Issue | Solution |
|-------|----------|
| Pods not ready | `kubectl get pods -n healthcare-devops` and wait 30 seconds |
| Port-forward fails | Ensure previous port-forward killed: `pkill -f port-forward` |
| Image pull error | Check image exists: `docker images \| grep healthcare-api` |
| Service not accessible | Check endpoints: `kubectl get endpoints -n healthcare-devops` |
| Pod logs show errors | `kubectl logs <pod-name> -n healthcare-devops` |

---

## Key Metrics to Highlight

During demo, mention these achievements:

| Metric | Value |
|--------|-------|
| **Deployment Downtime** | 0 seconds (zero-downtime deployment) |
| **Rollback Time** | < 5 seconds (instant switch) |
| **Testing Time** | 30 seconds (automated smoke tests) |
| **Resource Usage** | ~400MB per pod × 4 pods = 1.6GB |
| **Pods per Deployment** | 2 (high availability) |
| **Kubernetes Namespace** | healthcare-devops (isolated) |
| **Services** | 3 (production + 2 testing) |
| **Security Layers** | 6 (container, image, secrets, RBAC, network, deployment) |

---

## Demo Conclusion (1 minute)

### Summary to Present

"We've demonstrated a complete, secure CI/CD pipeline with Blue-Green deployment strategy that:

1. ✅ **Deployed** a new version to production
2. ✅ **Tested** the new version in isolation
3. ✅ **Switched** production traffic with zero downtime
4. ✅ **Rolled back** instantly when needed
5. ✅ **Secured** using Kubernetes best practices

This approach eliminates deployment risk and enables frequent, safe updates in production healthcare systems."

### Questions to Prepare For

See [VIVA_QUESTIONS.md](VIVA_QUESTIONS.md) for 25+ common questions and answers.

---

## Time Breakdown

- **Part 1** (Initial Blue): 3 minutes
- **Part 2** (Deploy Green): 3 minutes  
- **Part 3** (Test Green): 4 minutes
- **Part 4** (Switch Traffic): 3 minutes
- **Part 5** (Verify Production): 2 minutes
- **Part 6** (Rollback): 3 minutes
- **Part 7** (Show Details): 2 minutes
- **Total**: 20 minutes

Adjust pacing based on audience familiarity with Kubernetes.

---

**Demo Last Updated**: May 2, 2026
