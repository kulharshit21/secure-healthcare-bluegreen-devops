## Architecture: Secure CI/CD Pipeline with Blue-Green Deployment

---

## 1. High-Level System Architecture

```
┌─────────────────────────────────────────────────────────────────┐
│                          DEVELOPER WORKFLOW                      │
│  ┌───────────────────────────────────────────────────────────┐  │
│  │  1. Code Changes                                          │  │
│  │  2. Git Commit & Push                                    │  │
│  │  3. Create Pull Request (Optional)                       │  │
│  └───────────────────────────────────────────────────────────┘  │
└──────────────────────────┬──────────────────────────────────────┘
                           │
                           ↓
┌─────────────────────────────────────────────────────────────────┐
│                    GIT REPOSITORY (GitHub)                       │
│  - Source code                                                   │
│  - Dockerfile                                                    │
│  - Kubernetes manifests                                          │
│  - Jenkinsfile (CI/CD pipeline definition)                      │
│  - Scripts (deployment automation)                               │
└──────────────────────────┬──────────────────────────────────────┘
                           │
                           ↓
┌─────────────────────────────────────────────────────────────────┐
│                  JENKINS CI/CD PIPELINE                          │
│  ┌───────────────────────────────────────────────────────────┐  │
│  │  Declarative Pipeline:                                    │  │
│  │  ├─ Checkout Code                                         │  │
│  │  ├─ Setup Environment                                     │  │
│  │  ├─ Install Dependencies                                  │  │
│  │  ├─ Run Unit Tests (pytest)                              │  │
│  │  ├─ Build Docker Image                                    │  │
│  │  ├─ Security Scan (Trivy)                                │  │
│  │  ├─ Docker Login                                          │  │
│  │  ├─ Push Image to Registry                               │  │
│  │  ├─ Deploy Green Deployment                              │  │
│  │  ├─ Smoke Test Green                                     │  │
│  │  ├─ Switch Service Selector                              │  │
│  │  └─ Verify Production                                    │  │
│  └───────────────────────────────────────────────────────────┘  │
└────┬────────┬───────────────┬─────────────────┬─────────────────┘
     │        │               │                 │
     ↓        ↓               ↓                 ↓
┌─────────┐┌──────────┐ ┌────────────┐  ┌────────────┐
│  Docker ││  Trivy   │ │  Docker    │  │ Kubernetes │
│  Build  ││ Scanner  │ │  Registry  │  │  Minikube  │
└─────────┘└──────────┘ └────────────┘  └────────────┘
```

---

## 2. Kubernetes Cluster Architecture

```
┌────────────────────────────────────────────────────────────────────┐
│                      MINIKUBE CLUSTER                              │
│  ┌──────────────────────────────────────────────────────────────┐ │
│  │  Master Node (Minikube)                                      │ │
│  │  - API Server                                                │ │
│  │  - etcd (configuration store)                                │ │
│  │  - Controller Manager                                        │ │
│  │  - Scheduler                                                 │ │
│  └──────────────────────────────────────────────────────────────┘ │
│                                                                     │
│  ┌──────────────────────────────────────────────────────────────┐ │
│  │         HEALTHCARE-DEVOPS NAMESPACE                          │ │
│  │                                                              │ │
│  │  ┌──────────────────────────────────────────────────────┐  │ │
│  │  │  Configuration & Security                           │  │ │
│  │  │  - ConfigMap: Non-sensitive config                  │  │ │
│  │  │  - Secret: Sensitive data (JWT, passwords)          │  │ │
│  │  │  - ServiceAccount: Pod identity                     │  │ │
│  │  │  - Role: Permissions                                │  │ │
│  │  │  - RoleBinding: Assign Role to ServiceAccount       │  │ │
│  │  │  - NetworkPolicy: Traffic rules                     │  │ │
│  │  └──────────────────────────────────────────────────────┘  │ │
│  │                                                              │ │
│  │  ┌─────────────────────┐    ┌─────────────────────┐        │ │
│  │  │   BLUE DEPLOYMENT   │    │  GREEN DEPLOYMENT   │        │ │
│  │  │  (Current Prod v1)  │    │  (New Version v2)   │        │ │
│  │  │                     │    │                     │        │ │
│  │  │  ┌─────────────┐    │    │  ┌─────────────┐    │        │ │
│  │  │  │  Pod 1      │    │    │  │  Pod 1      │    │        │ │
│  │  │  │ :5000       │    │    │  │ :5000       │    │        │ │
│  │  │  │             │    │    │  │             │    │        │ │
│  │  │  │ Containers: │    │    │  │ Containers: │    │        │ │
│  │  │  │ - App       │    │    │  │ - App       │    │        │ │
│  │  │  └─────────────┘    │    │  └─────────────┘    │        │ │
│  │  │  ┌─────────────┐    │    │  ┌─────────────┐    │        │ │
│  │  │  │  Pod 2      │    │    │  │  Pod 2      │    │        │ │
│  │  │  │ :5000       │    │    │  │ :5000       │    │        │ │
│  │  │  └─────────────┘    │    │  └─────────────┘    │        │ │
│  │  │  v1.0.1             │    │  v2.0.1             │        │ │
│  │  └─────────────────────┘    └─────────────────────┘        │ │
│  │           ↑                            ↑                    │ │
│  │           │                            │                    │ │
│  │  ┌────────┴──────────┐        ┌───────┴──────────┐         │ │
│  │  │ Blue Service      │        │ Green Service    │         │ │
│  │  │ Port: 30080       │        │ Port: 30081      │         │ │
│  │  │ For: Production   │        │ For: Testing     │         │ │
│  │  └─────────┬─────────┘        └──────────────────┘         │ │
│  │            │                                                │ │
│  │            └────────────┬────────────────────────┐         │ │
│  │                         ↓                        │         │ │
│  │              ┌──────────────────────┐           │         │ │
│  │              │  Main Service        │           │         │ │
│  │              │  (Healthcare Service)│           │         │ │
│  │              │  Port: 30080         │           │         │ │
│  │              │  Selector switches   │           │         │ │
│  │              │  between Blue/Green  │           │         │ │
│  │              └──────────────────────┘           │         │ │
│  │                                                 │         │ │
│  └─────────────────────────────────────────────────┼─────────┘ │
│                                                     │           │
│  External Access:                                  │           │
│  kubectl port-forward svc/healthcare-service 8080 │           │
│                                                    ↓           │
│                                          http://localhost:8080 │
└────────────────────────────────────────────────────────────────┘
```

---

## 3. Blue-Green Deployment Flow Architecture

```
PHASE 1: INITIAL STATE
┌─────────────────────────────────────┐
│  Production Service Selector        │
│  {app: healthcare-api,              │
│   version: blue}                    │
└─────────────────────┬───────────────┘
                      │
                      ↓
                 ┌─────────────┐
                 │  Blue Pods  │
                 │ (v1 Running)│
                 └─────────────┘
                 
Production Traffic: 100% → Blue

─────────────────────────────────────────

PHASE 2: DEPLOY GREEN
┌─────────────────────────────────────┐
│  Production Service Selector        │
│  {app: healthcare-api,              │
│   version: blue}  [unchanged]       │
└─────────────────────────────────────┘

┌──────────────────────────────────────┐
│  Green Deployment                    │
│  ┌──────────────────────────────────┐│
│  │ Pods starting (v2)               ││
│  │ Status: Pending/ContainerCreating││
│  └──────────────────────────────────┘│
└──────────────────────────────────────┘
                 ↓
         ┌─────────────┐
         │  Blue Pods  │
         │ (v1 Running)│
         └─────────────┘

Production Traffic: 100% → Blue
Green Pods: Starting (no traffic)

─────────────────────────────────────────

PHASE 3: GREEN READY
┌──────────────────────────────────────┐
│  Green Deployment                    │
│  ┌──────────────────────────────────┐│
│  │ 2 Pods Ready                     ││
│  │ Health Checks: Passing           ││
│  │ Status: 2/2 Ready                ││
│  └──────────────────────────────────┘│
└──────────────────────────────────────┘
         ↓              ↓
  ┌─────────────┐ ┌─────────────┐
  │  Blue Pods  │ │Green Pods   │
  │ (v1 Running)│ │(v2 Ready)   │
  └─────────────┘ └─────────────┘

Production Service → Blue (100%)
Testing Service → Green (ready for tests)

─────────────────────────────────────────

PHASE 4: SWITCH TRAFFIC
kubectl patch service healthcare-service \
  -p '{"spec":{"selector":{"version":"green"}}}'
  
┌─────────────────────────────────────┐
│  Production Service Selector        │
│  {app: healthcare-api,              │
│   version: green}  [CHANGED]        │
└─────────────────────────────────────┘

┌─────────────────────────────────────┐
│  Service Endpoints Updated          │
│  Old: Blue Pod IPs                  │
│  New: Green Pod IPs                 │
└─────────────────────────────────────┘
         ↓              ↓
  ┌─────────────┐ ┌─────────────┐
  │  Blue Pods  │ │Green Pods   │
  │ (v1 Idle)   │ │(v2 Traffic) │
  └─────────────┘ └─────────────┘

Production Traffic: 100% → Green
Blue: Available for rollback (idle)

─────────────────────────────────────────

PHASE 5: ROLLBACK (if needed)
kubectl patch service healthcare-service \
  -p '{"spec":{"selector":{"version":"blue"}}}'

┌─────────────────────────────────────┐
│  Production Service Selector        │
│  {app: healthcare-api,              │
│   version: blue}  [REVERTED]        │
└─────────────────────────────────────┘
         ↓              ↓
  ┌─────────────┐ ┌─────────────┐
  │  Blue Pods  │ │Green Pods   │
  │ (v1 Traffic)│ │(v2 Idle)    │
  └─────────────┘ └─────────────┘

Production Traffic: 100% → Blue (back to stable)
```

---

## 4. Container Image Build Architecture

```
┌──────────────────────────────────────────────────────┐
│         DOCKERFILE - MULTI-STAGE BUILD               │
├──────────────────────────────────────────────────────┤
│                                                      │
│  STAGE 1: BUILDER                                   │
│  ┌────────────────────────────────────────────┐    │
│  │ FROM python:3.11-slim                      │    │
│  │                                            │    │
│  │ RUN pip install -r requirements.txt        │    │
│  │     (includes pip cache, build tools)      │    │
│  │                                            │    │
│  │ Image Size: ~800 MB                        │    │
│  │ Thrown Away (not in final image)           │    │
│  └────────────────────────────────────────────┘    │
│                         │                           │
│         Copy dependencies only ↓                    │
│                                                     │
│  STAGE 2: RUNTIME                                  │
│  ┌────────────────────────────────────────────┐    │
│  │ FROM python:3.11-slim                      │    │
│  │                                            │    │
│  │ COPY --from=builder /root/.local .         │    │
│  │ (copy only .local with dependencies)       │    │
│  │                                            │    │
│  │ COPY app/app.py .                          │    │
│  │                                            │    │
│  │ RUN groupadd -r healthcare                 │    │
│  │     useradd -r -g healthcare healthcare    │    │
│  │ (create non-root user)                     │    │
│  │                                            │    │
│  │ USER healthcare                            │    │
│  │ EXPOSE 5000                                │    │
│  │ CMD ["gunicorn", "--bind", "0.0.0.0:5000"]│    │
│  │                                            │    │
│  │ Image Size: ~400 MB (only runtime)         │    │
│  │ Final Product (published to registry)      │    │
│  └────────────────────────────────────────────┘    │
│                                                     │
└──────────────────────────────────────────────────────┘

Benefits of Multi-Stage Build:
✓ ~50% size reduction (no build tools in final image)
✓ No build cache in final image
✓ No pip install history
✓ Cleaner, more secure image
```

---

## 5. Jenkins Pipeline Stage Flow

```
START
  │
  ├─→ 1. CHECKOUT
  │   ├─ Git clone
  │   └─ Checkout branch
  │
  ├─→ 2. ENVIRONMENT INFO
  │   ├─ Docker version
  │   ├─ kubectl version
  │   └─ Python version
  │
  ├─→ 3. INSTALL DEPENDENCIES
  │   └─ pip install
  │
  ├─→ 4. UNIT TESTS
  │   ├─ pytest app/test_app.py
  │   ├─ All endpoints tested
  │   ├─ JSON response validated
  │   └─ [FAIL → ABORT, PASS → CONTINUE]
  │
  ├─→ 5. BUILD DOCKER IMAGE
  │   ├─ docker build (multi-stage)
  │   ├─ Tag: BUILD_NUMBER, green, latest
  │   └─ Image ready in Docker daemon
  │
  ├─→ 6. TRIVY SECURITY SCAN
  │   ├─ Scan for vulnerabilities
  │   ├─ Check severity: HIGH, CRITICAL
  │   ├─ Generate JSON report
  │   └─ [FAIL → ABORT, PASS → CONTINUE]
  │
  ├─→ 7. DOCKER LOGIN
  │   ├─ Authenticate with Docker Hub
  │   └─ (using Jenkins credentials)
  │
  ├─→ 8. PUSH IMAGE
  │   ├─ docker push BUILD_NUMBER tag
  │   ├─ docker push green tag
  │   └─ docker push latest tag
  │
  ├─→ 9. DEPLOY GREEN
  │   ├─ kubectl apply namespace.yaml
  │   ├─ kubectl apply configmap.yaml
  │   ├─ kubectl apply secret.yaml
  │   ├─ kubectl apply rbac.yaml
  │   ├─ kubectl apply blue-deployment.yaml
  │   ├─ kubectl apply green-deployment.yaml
  │   ├─ kubectl apply service.yaml
  │   ├─ kubectl set image (update Green)
  │   ├─ kubectl rollout status (wait for ready)
  │   └─ [TIMEOUT → ABORT, READY → CONTINUE]
  │
  ├─→ 10. SMOKE TEST GREEN
  │   ├─ Port-forward green-service
  │   ├─ Test /health (200 OK?)
  │   ├─ Test /version (green-v2?)
  │   ├─ Test /patients (data?)
  │   └─ [FAIL → ABORT, PASS → CONTINUE]
  │
  ├─→ 11. SWITCH TRAFFIC [MANUAL APPROVAL]
  │   ├─ Await user approval
  │   ├─ kubectl patch service selector
  │   └─ from: version=blue → to: version=green
  │
  ├─→ 12. VERIFY PRODUCTION
  │   ├─ Test /version (now green-v2?)
  │   ├─ Test /health (200 OK?)
  │   └─ [FAIL → MANUAL RECOVERY, SUCCESS → DONE]
  │
  └─→ END
     ├─ [SUCCESS] Production on Green
     └─ [FAILURE] Rollback to Blue (manual)
```

---

## 6. Network Architecture

```
┌─────────────────────────────────────────────────────┐
│              CLIENT WORKSTATION                      │
│  ┌───────────────────────────────────────────────┐  │
│  │  Browser/curl                                 │  │
│  │  GET http://localhost:8080/version           │  │
│  └───────────┬─────────────────────────────────┘  │
└──────────────┼───────────────────────────────────┘
               │
         kubectl port-forward
        (localhost:8080 → svc:80)
               │
               ↓
┌──────────────────────────────────────────────────┐
│       MINIKUBE CLUSTER (Internal Network)         │
│  ┌──────────────────────────────────────────┐   │
│  │  Service: healthcare-service             │   │
│  │  Cluster IP: 10.96.x.x                   │   │
│  │  Port: 80 → Container: 5000              │   │
│  │  Selector: {version: blue or green}      │   │
│  └──────────────────────┬───────────────────┘   │
│                         │                        │
│         Load Balance via endpoints               │
│                         │                        │
│        ┌────────────────┼────────────────┐      │
│        ↓                ↓                ↓      │
│  ┌─────────────┐  ┌─────────────┐      ┌──┐    │
│  │ Pod 1       │  │ Pod 2       │      │..│    │
│  │ 10.244.x.x:5000  10.244.x.x:5000    └──┘    │
│  │ ┌────────┐  │  │ ┌────────┐  │             │
│  │ │ App    │  │  │ │ App    │  │             │
│  │ │:5000   │  │  │ │:5000   │  │             │
│  │ └────────┘  │  │ └────────┘  │             │
│  └─────────────┘  └─────────────┘             │
│  Label: version=green (or blue after switch)  │
│                                                │
└──────────────────────────────────────────────────┘
```

---

## 7. Data Flow Diagram

```
USER/API REQUEST
        │
        ↓
LOAD BALANCER (Service)
        │
        ├─→ Route to Pod 1
        │   │
        │   ↓
        │   FLASK APP
        │   │
        │   ├─→ Read ConfigMap (config)
        │   ├─→ Read Secret (JWT, password)
        │   ├─→ Process Request
        │   ├─→ In-memory database (patients)
        │   └─→ Return JSON Response
        │
        ├─→ Route to Pod 2
        │   │
        │   ↓
        │   (Same as Pod 1)
        │
        ↓
USER RECEIVES RESPONSE


DEPLOYMENT FLOW:
CI/CD Server (Jenkins)
        │
        ├─→ Build: app → Docker image
        │
        ├─→ Scan: Image → Trivy results
        │
        ├─→ Push: Image → Docker Registry
        │
        ├─→ Deploy: Registry image → Kubernetes
        │   │
        │   ├─→ Pull image
        │   ├─→ Create pods
        │   ├─→ Mount ConfigMap
        │   ├─→ Mount Secret
        │   ├─→ Start containers
        │   └─→ Run health checks
        │
        └─→ Switch: Service selector
            (Blue → Green traffic routing)
```

---

## 8. Security Layers Architecture

```
┌─────────────────────────────────────────────┐
│  LAYER 1: IMAGE SECURITY                    │
│  ├─ Trivy vulnerability scanning             │
│  ├─ Multi-stage build                        │
│  ├─ Minimal base image                       │
│  └─ No sensitive data in layers              │
└─────────────────────────────────────────────┘
                    ↓
┌─────────────────────────────────────────────┐
│  LAYER 2: CONTAINER RUNTIME SECURITY        │
│  ├─ Non-root user execution                  │
│  ├─ Read-only root filesystem                │
│  ├─ Drop capabilities                        │
│  └─ Resource limits                          │
└─────────────────────────────────────────────┘
                    ↓
┌─────────────────────────────────────────────┐
│  LAYER 3: SECRETS MANAGEMENT                │
│  ├─ Kubernetes Secret object                 │
│  ├─ Separate from code                       │
│  ├─ Mount as env variables                   │
│  └─ Not logged or exposed                    │
└─────────────────────────────────────────────┘
                    ↓
┌─────────────────────────────────────────────┐
│  LAYER 4: ACCESS CONTROL (RBAC)             │
│  ├─ ServiceAccount identity                  │
│  ├─ Role with minimal permissions            │
│  ├─ RoleBinding to namespace only            │
│  └─ Audit trail of access                    │
└─────────────────────────────────────────────┘
                    ↓
┌─────────────────────────────────────────────┐
│  LAYER 5: NETWORK SECURITY                  │
│  ├─ NetworkPolicy restrictions               │
│  ├─ Ingress/Egress controls                  │
│  ├─ Namespace isolation                      │
│  └─ Service mesh ready                       │
└─────────────────────────────────────────────┘
                    ↓
┌─────────────────────────────────────────────┐
│  LAYER 6: DEPLOYMENT SECURITY               │
│  ├─ Blue-Green strategy                      │
│  ├─ Health checks (readiness/liveness)       │
│  ├─ Automated rollback                       │
│  └─ Zero-downtime updates                    │
└─────────────────────────────────────────────┘
```

---

## 9. High Availability Architecture

```
┌──────────────────────────────────────────┐
│  REPLICATION STRATEGY                    │
│                                          │
│  Blue Deployment:                        │
│  ├─ replicas: 2                          │
│  ├─ Pod 1: Running                       │
│  └─ Pod 2: Running                       │
│     (if Pod 1 fails, Pod 2 serves)       │
│                                          │
│  Green Deployment:                       │
│  ├─ replicas: 2                          │
│  ├─ Pod 1: Running                       │
│  └─ Pod 2: Running                       │
│     (isolated from Blue)                 │
│                                          │
│  Total Pods: 4 (2 Blue + 2 Green)        │
│  Min Available: 2 (1 Blue + 1 Green)     │
└──────────────────────────────────────────┘

┌──────────────────────────────────────────┐
│  ANTI-AFFINITY STRATEGY                  │
│                                          │
│  Pod Placement:                          │
│  ├─ Blue Pod 1 → Node A                  │
│  ├─ Blue Pod 2 → Node B (preferred)      │
│  ├─ Green Pod 1 → Node A                 │
│  └─ Green Pod 2 → Node B (preferred)     │
│                                          │
│  Benefits:                               │
│  ├─ Node failure tolerance               │
│  ├─ Rack-aware scheduling                │
│  └─ Reduced blast radius                 │
└──────────────────────────────────────────┘

┌──────────────────────────────────────────┐
│  HEALTH CHECK FLOW                       │
│                                          │
│  1. Startup Probe (initial)              │
│     └─→ Pod given time to boot           │
│                                          │
│  2. Readiness Probe (every 5s)           │
│     ├─→ Pass: Added to service           │
│     └─→ Fail: Removed from service       │
│                                          │
│  3. Liveness Probe (every 10s)           │
│     ├─→ Pass: Pod OK                     │
│     └─→ Fail (3x): Pod restarted         │
│                                          │
│  Result: Only healthy pods serve traffic │
└──────────────────────────────────────────┘
```

---

## 10. Monitoring & Observability Architecture

```
POD METRICS
        │
        ├─→ Health endpoints
        │   ├─ /health
        │   ├─ /version
        │   └─ /security-status
        │
        ├─→ Container logs
        │   ├─ Application logs
        │   ├─ Access logs
        │   └─ Error logs
        │
        ├─→ Kubernetes events
        │   ├─ Pod created
        │   ├─ Container started
        │   └─ Health checks
        │
        └─→ Metrics server
            ├─ CPU usage
            ├─ Memory usage
            └─ Network traffic

AGGREGATION LAYER (Production would add)
        │
        ├─→ ELK Stack / Splunk / CloudWatch
        │   └─ Centralized logging
        │
        ├─→ Prometheus / Grafana
        │   └─ Metrics collection
        │
        └─→ Alert Manager
            ├─ Alerts on failures
            ├─ Slack notifications
            └─ On-call escalation

DASHBOARDS & ALERTING
        │
        ├─→ Pod status dashboard
        ├─→ Error rate alerts
        ├─→ Deployment success alerts
        └─→ Security compliance alerts
```

---

## 11. Deployment Sequence Diagram

```
Time →

Developer          Jenkins              Docker           Kubernetes
    │                  │                   │                │
    │─── Push Code ──→ │                   │                │
    │                  │                   │                │
    │                  │─ Checkout Code    │                │
    │                  │─ Run Tests        │                │
    │                  │                   │                │
    │                  │─────── Build Docker Image ──────→ │
    │                  │                   │<─ Image built  │
    │                  │                   │                │
    │                  │────── Scan with Trivy ────→       │
    │                  │                   │<─ Scan report  │
    │                  │                   │                │
    │                  │─── Docker Login ──→                │
    │                  │                   │                │
    │                  │─── Push Image ────→ Docker Hub     │
    │                  │                   │<─ Pushed      │
    │                  │                   │                │
    │                  │─────── Deploy Green ──────────→    │
    │                  │                   │ ← Pull Image   │
    │                  │                   │ ← Start Pods   │
    │                  │                   │ ← Health Check │
    │                  │                   │ ← Pods Ready   │
    │                  │                   │                │
    │                  │──── Smoke Test Green ──────────→   │
    │                  │← /health OK, /version green-v2 OK  │
    │                  │                   │                │
    │◄─ Approve Switch?                    │                │
    │── Switch Traffic ──────────────────→ │                │
    │                  │                   │ ← Patch Service│
    │                  │                   │ ← Update EP    │
    │◄─ Production on Green v2 ────────────                │
    │                  │                   │                │
    │                  │──── Verify Prod ──────────────→    │
    │                  │← /version green-v2 OK              │
    │                  │                   │                │
    │──── Done ────→ │                   │                │
```

---

## 12. Error Handling & Rollback Architecture

```
ERROR SCENARIOS & RESPONSES

Scenario 1: Unit Test Failure
  → Pipeline stops at stage 4
  → Image not built
  → Jenkins notifies developer
  → No deployment to Kubernetes

Scenario 2: Trivy Finds Critical CVE
  → Pipeline stops at stage 6
  → Image not pushed to registry
  → Jenkins blocks deployment
  → Developer must fix vulnerability

Scenario 3: Green Pod Fails to Start
  → Pods stuck in Pending/CrashLoopBackOff
  → Health check fails
  → Stage 10 (Smoke Test) fails
  → Pipeline aborts before traffic switch
  → Blue remains production (no switch happened)

Scenario 4: Smoke Test Fails
  → /health returns 500
  → /version returns wrong version
  → curl fails
  → Stage 10 aborts
  → Pipeline stops
  → Blue remains production

Scenario 5: Switch Successful but Production Errors
  → Traffic switched to Green
  → Monitoring shows errors (would alert)
  → Manual rollback triggered:
     kubectl patch service healthcare-service \
       -p '{"spec":{"selector":{"version":"blue"}}}'
  → Traffic back to Blue (instant)
  → Blue serves requests again
  → Issue investigated on idle Green pods

RECOVERY TIME: < 5 seconds (kubectl patch execution)
```

---

## 13. Storage Architecture

```
POD EPHEMERAL STORAGE:
  ├─ /app (read-only code)
  ├─ /app/tmp (writable, ephemeral)
  └─ In-memory patient database

DATA PERSISTENCE NOTES:
  • Patient data: In-memory only (demo)
  • Production: Would need persistent storage
    ├─ PersistentVolume
    ├─ Database (external)
    └─ Object Storage (S3-compatible)

VOLUME MOUNTS:
  ├─ ConfigMap → /etc/config (config files)
  ├─ Secret → /etc/secrets (credentials)
  └─ emptyDir → /app/tmp (temporary)

BACKUP STRATEGY (Production):
  ├─ Database snapshots (daily)
  ├─ Kubernetes object backups (Velero)
  ├─ Cross-region replication
  └─ Disaster recovery tests (monthly)
```

---

## 14. Reference Architecture Summary

```
LAYERS:
  1. Git Repository (Source Control)
  2. Jenkins (CI/CD Orchestration)
  3. Docker (Containerization)
  4. Kubernetes (Orchestration)
  5. Minikube (Local Development)

FLOW:
  Code → Test → Build → Scan → Push → Deploy → Test → Switch → Monitor

STRATEGY:
  Blue-Green enables safe, zero-downtime deployments with instant rollback

SECURITY:
  6 layers: Image, Container, Secrets, RBAC, Network, Deployment

SCALABILITY:
  Ready to migrate to managed Kubernetes (EKS, AKS, GKE)
```

---

**Architecture Version**: 1.0
**Last Updated**: May 2, 2026
**Status**: Complete and Documented
