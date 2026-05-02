## Viva Questions & Answers: Secure CI/CD with Blue-Green Deployment

**Prepared for**: College DevOps assignment evaluation/viva  
**Format**: 30 comprehensive questions with detailed answers

---

## SECTION 1: FUNDAMENTALS

### Q1. What is CI/CD and why is it important?

**Answer:**
CI/CD stands for Continuous Integration and Continuous Delivery/Deployment. It's a set of practices and tools that automate the process of building, testing, and deploying software.

- **Continuous Integration (CI)**: Every code change is automatically tested
- **Continuous Delivery (CD)**: Tested code is ready for deployment at any time
- **Continuous Deployment**: Code automatically deployed to production

**Why Important:**
- Reduces deployment time from weeks to minutes
- Catches bugs early through automated testing
- Enables frequent, safe releases
- Reduces human error
- Improves team productivity
- Faster feedback loop to developers

**In Our Project:**
Jenkins pipeline automates: Checkout → Test → Build → Scan → Push → Deploy

---

### Q2. What is Docker and how does containerization help?

**Answer:**
Docker is a containerization platform that packages applications with all dependencies into isolated, lightweight containers.

**Container vs VM:**
```
Container:
├─ OS: Shared kernel
├─ Size: ~100-500 MB
├─ Startup: Seconds
├─ Isolation: Process-level
└─ Resource: Minimal

VM:
├─ OS: Full OS per instance
├─ Size: ~10-50 GB
├─ Startup: Minutes
├─ Isolation: Machine-level
└─ Resource: High
```

**Benefits in Healthcare:**
- Consistency: Same environment dev → staging → production
- Portability: Run anywhere (laptop, cloud, on-prem)
- Scalability: Quickly spin up multiple instances
- Security: Isolated environment per application
- Dependency management: All dependencies packaged

**Our Dockerfile:**
- Multi-stage build (reduces size by 70%)
- Non-root user (security)
- Health checks (reliability)

---

### Q3. What is Kubernetes and why use it?

**Answer:**
Kubernetes (K8s) is an open-source container orchestration platform that automates deployment, scaling, and management of containerized applications.

**Kubernetes provides:**
- **Deployment**: Automated rollout and rollback
- **Scaling**: Auto-scale pods based on demand
- **Self-healing**: Restart failed containers
- **Service discovery**: DNS-based service routing
- **Load balancing**: Distribute traffic across pods
- **Storage management**: Persistent and ephemeral storage
- **Resource management**: CPU/memory limits and requests
- **Security**: RBAC, network policies, secrets

**Kubernetes Objects (used in our project):**
```
├─ Namespace: Resource isolation
├─ Deployment: Manage pod replicas
├─ Service: Network access to pods
├─ ConfigMap: Configuration data
├─ Secret: Sensitive data
├─ ServiceAccount: Pod identity
├─ Role/RoleBinding: RBAC
└─ NetworkPolicy: Network rules
```

**Why Kubernetes for Healthcare:**
- High availability (multiple replicas)
- Automatic failure recovery
- Secure communication
- Compliance-ready
- Enterprise-grade

---

### Q4. What is Minikube and when is it used?

**Answer:**
Minikube is a tool that runs a single-node Kubernetes cluster inside a VM/container on your computer.

**Minikube Features:**
- Single-node cluster (not production-grade)
- For local development and testing
- Minimal resource requirements
- Quick startup
- Free and open-source

**Minikube vs Production Kubernetes:**
```
Minikube:
├─ Single node
├─ Local machine
├─ Development/testing only
└─ Resource-limited

Production (EKS/AKS/GKE):
├─ Multiple nodes (100+)
├─ Cloud provider
├─ Production workloads
└─ Enterprise features
```

**Our Project:**
- Use Minikube for demo
- Can migrate to cloud Kubernetes without code changes
- Scripts and manifests work on any Kubernetes

---

### Q5. What is Jenkins and what is its role in CI/CD?

**Answer:**
Jenkins is an open-source automation server that orchestrates CI/CD pipelines.

**Jenkins Capabilities:**
- Executes jobs based on triggers (webhook, schedule, manual)
- Builds software (compile, package)
- Runs tests (unit, integration, automated)
- Produces artifacts (Docker images, compiled binaries)
- Deploys to various environments
- Provides visibility through dashboards and logs

**Jenkins Pipeline (Declarative):**
```groovy
pipeline {
    agent any
    environment { ... }
    stages {
        stage('Build') { ... }
        stage('Test') { ... }
        stage('Deploy') { ... }
    }
    post { ... }  // Cleanup, notifications
}
```

**Our Jenkinsfile:**
- 12 stages from code to production
- Automated testing
- Docker build and push
- Kubernetes deployment
- Blue-Green switching
- Error handling and rollback

---

## SECTION 2: BLUE-GREEN DEPLOYMENT

### Q6. What is Blue-Green Deployment and how does it work?

**Answer:**
Blue-Green is a deployment strategy that maintains two identical production environments:
- **Blue**: Current production (active)
- **Green**: New version (inactive)

**Process:**
```
1. Blue running (100% traffic)
2. Deploy new version to Green
3. Test Green thoroughly
4. Switch service router from Blue to Green
5. Blue remains running for instant rollback
6. If issues: Switch back to Blue
```

**Advantages:**
- Zero downtime (instant switch)
- Easy rollback (just switch back)
- Full testing before production (on Green)
- No split traffic issues
- Clear version separation

**Disadvantages:**
- Requires 2x resources
- Database migration complexity
- DNS caching issues
- Session management needed

**Our Implementation:**
- Service selector switches between Blue/Green labels
- Main service + testing services
- Automated switching via Kubernetes patch

---

### Q7. Why is Blue-Green better than Rolling Deployment?

**Answer:**

**Rolling Deployment:**
```
Pod 1 (v1) → Pod 1 (v2)     [Downtime for Pod 1]
Pod 2 (v1) → Pod 2 (v2)     [Downtime for Pod 2]
Pod 3 (v1) → Pod 3 (v2)     [Downtime for Pod 3]

Gradual: 33% → 66% → 100% traffic on new version
```

**Blue-Green Deployment:**
```
[Blue v1]  →  [Blue v1 + Green v2]  →  [Green v2]
100% Blue      Testing Green          100% Green
              0% traffic to Green       (Instant switch)
```

**Comparison:**

| Aspect | Blue-Green | Rolling |
|--------|-----------|---------|
| **Downtime** | Zero | Potential brief windows |
| **Testing** | Full v2 before switch | Limited pre-production testing |
| **Rollback Speed** | < 5 seconds | 5-10 minutes |
| **Resource Usage** | 2x | 1.5x |
| **Complexity** | Medium | Low |
| **Best For** | Critical systems | Non-critical apps |

**Healthcare Use Case:**
Healthcare systems need Blue-Green because:
- **High availability**: Patients depend on service 24/7
- **Quick recovery**: Rollback in seconds if issues
- **Risk reduction**: Full testing before users see it

---

### Q8. What happens during Blue-Green traffic switch?

**Answer:**
The switch is a simple change to the Kubernetes Service selector:

**Before:**
```yaml
apiVersion: v1
kind: Service
metadata:
  name: healthcare-service
spec:
  selector:
    app: healthcare-api
    version: blue  # ← Points to Blue
```

**Command:**
```bash
kubectl patch service healthcare-service \
  -p '{"spec":{"selector":{"version":"green"}}}'
```

**After:**
```yaml
spec:
  selector:
    app: healthcare-api
    version: green  # ← Now points to Green
```

**What Happens Behind Scenes:**
1. Service selector updated (1ms)
2. Kubernetes updates endpoints list
3. Old endpoint (Blue pods) removed
4. New endpoint (Green pods) added
5. Service load balancer redirects traffic
6. New requests go to Green pods
7. Old requests complete on Blue pods

**Network Impact:**
- Active connections: Might drop (brief moment)
- New connections: Go to Green
- Total downtime: < 100ms (graceful)

**In Our Demo:**
```
curl http://localhost:8080/version

Before: {"version": "blue-v1"}
[Switch]
After: {"version": "green-v2"}
```

---

### Q9. How do you rollback in Blue-Green deployment?

**Answer:**
Rollback is reverse of traffic switch:

**Automated Rollback (if tests fail):**
```groovy
stage('10. Smoke Test Green') {
    steps {
        sh 'curl -f http://green:8080/health'  # Fails? Stop.
    }
    post {
        failure {
            sh '''
                echo "Green failed tests - not switching"
                # Production stays on Blue
            '''
        }
    }
}
```

**Manual Rollback (if production issues):**
```bash
# Immediate switch back to Blue
./scripts/rollback.sh

# Or manually:
kubectl patch service healthcare-service \
  -n healthcare-devops \
  -p '{"spec":{"selector":{"version":"blue"}}}'
```

**Rollback Timeline:**
- Detection: < 30 seconds (health checks)
- Execution: < 5 seconds (kubectl patch)
- Full recovery: < 1 minute
- Total downtime: < 100ms

**Comparison with Other Strategies:**

| Strategy | Rollback Time |
|----------|---|
| **Blue-Green** | < 5 seconds |
| **Rolling** | 5-10 minutes |
| **Canary** | 2-3 minutes |
| **Manual** | 30+ minutes |

---

### Q10. Can you have multiple Blue-Green cycles?

**Answer:**
Yes, cycles can repeat:

```
Cycle 1:
  Blue v1 → Green v2 → Switch → Cycle complete

Cycle 2 (New update ready):
  Green v2 (now active) stays
  Blue v1 (now idle) gets updated to v3
  Deploy v3 to Blue
  Test Blue
  Switch traffic from Green to Blue
```

**Reusing Deployments:**
- Alternate between two deployments
- Blue and Green swap roles each cycle
- Same manifests reused
- Only image tags change

**In Our Project:**
```
First deployment:
  Blue runs v1.0 (stable)
  Green gets v1.1 (new)
  Switch to Green

Second deployment:
  Green running v1.1 (now stable)
  Blue gets v1.2 (new)
  Switch to Blue

Third deployment:
  Blue running v1.2 (now stable)
  Green gets v1.3 (new)
  Switch to Green

... and so on
```

---

## SECTION 3: KUBERNETES CONCEPTS

### Q11. What is a Kubernetes Deployment and how is it different from a Pod?

**Answer:**

**Pod:**
- Smallest deployable unit in Kubernetes
- Single container (usually) in a pod
- Ephemeral (created/destroyed frequently)
- Not directly managed by users

**Deployment:**
- Higher-level object that manages pods
- Declares desired state (e.g., "3 replicas of this image")
- Creates/manages ReplicaSets
- Handles rollouts and rollbacks
- Enables scaling

**Deployment Example:**
```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: healthcare-api-blue
spec:
  replicas: 2        # Run 2 pod instances
  strategy: ...      # How to update
  selector: ...      # Which pods to manage
  template: ...      # Pod template
```

**Hierarchy:**
```
Deployment (desired state)
  └─ ReplicaSet (ensures replicas match)
      ├─ Pod 1
      └─ Pod 2
```

**In Our Project:**
```
healthcare-api-blue deployment
  ├─ 2 replicas running
  └─ If pod crashes → ReplicaSet creates new pod

healthcare-api-green deployment
  ├─ 2 replicas running (separately)
  └─ Independent from Blue
```

---

### Q12. What is a Kubernetes Service and why do we need it?

**Answer:**
A Service is an abstraction that exposes pods over the network.

**Why Needed:**
- Pods are ephemeral (get recreated)
- Pod IPs change (new pod = new IP)
- Need stable endpoint for clients
- Service provides stable IP/DNS name

**Service Types:**

| Type | Use Case |
|------|----------|
| **ClusterIP** | Internal pod-to-pod communication |
| **NodePort** | External access via node port (30000-32767) |
| **LoadBalancer** | External load balancer (cloud providers) |
| **ExternalName** | Route to external DNS name |

**Our Services:**
```yaml
healthcare-service: NodePort 30080
  ├─ Production traffic
  └─ Selector switches between Blue/Green

healthcare-green-service: NodePort 30081
  └─ Testing Green before switch

healthcare-blue-service: NodePort 30082
  └─ Optional: Testing Blue
```

**DNS Naming:**
```
Within Kubernetes:
  healthcare-service.healthcare-devops.svc.cluster.local

External:
  localhost:30080 (via port-forward or node IP)
```

---

### Q13. What is a Kubernetes Secret and how do we use it?

**Answer:**
Secret stores sensitive data (passwords, tokens, keys) in Kubernetes.

**Secret Types:**
- `Opaque`: Arbitrary user-defined data (base64 encoded)
- `kubernetes.io/service-account-token`: Service account token
- `kubernetes.io/dockercfg`: Docker config
- `kubernetes.io/basic-auth`: Basic authentication
- `kubernetes.io/ssh-auth`: SSH authentication
- `tls`: TLS certificate and key

**Creating Secret:**
```bash
# From command line
kubectl create secret generic my-secret \
  --from-literal=password=mypass123

# From YAML (base64 encoded)
kubectl apply -f secret.yaml

# From file
kubectl create secret generic my-secret \
  --from-file=config.json
```

**Using Secret in Deployment:**
```yaml
env:
- name: DATABASE_PASSWORD
  valueFrom:
    secretKeyRef:
      name: healthcare-api-secret
      key: DATABASE_PASSWORD
```

**Our Implementation:**
```yaml
Secret: healthcare-api-secret
  ├─ JWT_SECRET: demo-secret-change-me
  └─ DATABASE_PASSWORD: demo-password-change-me

Used by:
  ├─ healthcare-api-blue pods
  └─ healthcare-api-green pods

Never:
  ├─ Logged to output
  ├─ Visible in deployment YAML (base64 only)
  └─ Stored in ConfigMap
```

**Important:** Base64 is NOT encryption. For production, use:
- HashiCorp Vault
- AWS Secrets Manager
- Azure Key Vault
- Sealed-secrets with encryption

---

### Q14. What is RBAC and why is it important?

**Answer:**
RBAC (Role-Based Access Control) is Kubernetes authorization mechanism.

**RBAC Components:**

1. **ServiceAccount**: Identity for pods
   ```yaml
   apiVersion: v1
   kind: ServiceAccount
   metadata:
     name: healthcare-api-sa
   ```

2. **Role**: Defines permissions
   ```yaml
   rules:
   - apiGroups: ["apps"]
     resources: ["deployments"]
     verbs: ["get", "list", "update", "patch"]
   ```

3. **RoleBinding**: Links ServiceAccount to Role
   ```yaml
   subjects:
   - kind: ServiceAccount
     name: healthcare-api-sa
   ```

**Permission Example:**
```yaml
Pod (healthcare-api-sa) wants to update deployment
  ↓
Kubernetes checks RoleBinding
  ↓
Found: healthcare-api-sa → healthcare-api-role
  ↓
Check Role permissions
  ↓
Rule matches: apiGroups=[apps], resource=deployments, verb=update
  ↓
✓ Allowed (return 200)
```

**Principle of Least Privilege:**
Grant only necessary permissions.

```
Our Project:
✓ Can: get, list, watch deployments
✓ Can: read configmaps
✓ Can: read secrets in namespace
✗ Cannot: access other namespaces
✗ Cannot: create/delete namespaces
✗ Cannot: delete secrets
✗ Cannot: modify RBAC
```

**Scope:**
- **Role/RoleBinding**: Namespace-scoped
- **ClusterRole/ClusterRoleBinding**: Cluster-wide

---

### Q15. What is a ConfigMap and how is it different from Secret?

**Answer:**

**ConfigMap:**
- Stores non-sensitive configuration data
- In plain text (no encoding)
- Data < 1 MB
- Examples: app settings, feature flags, URLs

**Secret:**
- Stores sensitive data
- Base64 encoded
- Separate storage (etcd)
- Examples: passwords, API keys, tokens

**Comparison:**

| Aspect | ConfigMap | Secret |
|--------|-----------|--------|
| **Content** | Non-sensitive | Sensitive |
| **Encoding** | Plain text | Base64 |
| **Visibility** | Visible to users | Restricted |
| **Use Case** | Configuration | Credentials |

**Our Project:**

```yaml
ConfigMap: healthcare-api-config
├─ ENVIRONMENT: production
├─ SERVICE_NAME: healthcare-api
├─ LOG_LEVEL: INFO
└─ FLASK_ENV: production
# These are non-secret, can be visible

Secret: healthcare-api-secret
├─ JWT_SECRET: xxx (hidden)
├─ DATABASE_PASSWORD: xxx (hidden)
└─ API_KEY: xxx (hidden)
# These are sensitive, access controlled
```

**Mounting in Pods:**

```yaml
# ConfigMap as environment variables
envFrom:
- configMapRef:
    name: healthcare-api-config

# Secret as environment variables
env:
- name: JWT_SECRET
  valueFrom:
    secretKeyRef:
      name: healthcare-api-secret
      key: JWT_SECRET

# Or as volumes
volumeMounts:
- name: config
  mountPath: /etc/config
volumes:
- name: config
  configMap:
    name: healthcare-api-config
```

---

## SECTION 4: SECURITY

### Q16. Why should containers not run as root user?

**Answer:**
Running as non-root is a fundamental security best practice.

**Risks of Running as Root:**
- Full system access if container compromised
- Can modify kernel, system files, other containers
- Can bind to privileged ports (< 1024)
- Privilege escalation attacks more dangerous
- No containment of damage

**Non-Root Benefits:**
- Limited permissions for compromised process
- Cannot modify system files
- Reduced attack surface
- Meets security compliance

**Our Implementation:**
```dockerfile
# Create non-root user
RUN groupadd -r healthcare && \
    useradd -r -g healthcare healthcare

# Switch to non-root
USER healthcare  # UID 1000

# Run app as non-root user
CMD ["gunicorn", "--bind", "0.0.0.0:5000", "app:app"]
```

**In Kubernetes:**
```yaml
securityContext:
  runAsNonRoot: true
  runAsUser: 1000
  allowPrivilegeEscalation: false
```

**Testing:**
```bash
# Try to write to /etc
kubectl exec -it <pod> -n healthcare-devops -- touch /etc/test
# Result: Permission denied (expected)

# Try to install package
kubectl exec -it <pod> -- apt-get update
# Result: Command not found or permission denied (expected)
```

**Best Practices:**
- Always use non-root in production
- Create custom user during image build
- Never use USER nobody (security concern)
- Verify with `id` command: uid=1000 (not 0)

---

### Q17. What is Trivy and what does it scan for?

**Answer:**
Trivy is a vulnerability scanner for container images.

**What Trivy Scans:**
1. **OS Package Vulnerabilities**
   - Debian, Alpine, Ubuntu packages
   - Known CVEs in libraries
   
2. **Application Dependencies**
   - Python pip packages
   - Node npm packages
   - Java maven/gradle
   - Ruby gems
   
3. **Misconfigurations**
   - Dockerfile best practices
   - Kubernetes manifests
   - Infrastructure as Code
   
4. **Secrets**
   - API keys
   - Passwords
   - Private keys

**Severity Levels:**
```
CRITICAL (0-10 severity score)
├─ Immediate fix required
└─ Security breach risk

HIGH (7-10)
├─ Should fix before production
└─ Major vulnerabilities

MEDIUM (4-6)
├─ Fix in next release
└─ Moderate impact

LOW (0-4)
├─ Monitor
└─ Low priority

UNKNOWN
└─ Undetermined severity
```

**Our Usage:**
```groovy
stage('6. Security Scan with Trivy') {
    steps {
        sh '''
            trivy image \
                --severity HIGH,CRITICAL \
                --exit-code 0 \
                ${DOCKER_IMAGE}:${BUILD_TAG}
        '''
    }
}
```

**Example Output:**
```
healthcare-api:latest
2023-04-15T10:30:00.000Z  [CRITICAL]  package-xyz in pip
[GHSA-xxxx-xxxx-xxxx]  Remote Code Execution in xyz
Upgrade to version 2.0.0 or later

Total: 2 vulnerabilities (1 CRITICAL, 1 HIGH)
```

**Best Practices:**
- Scan before every deployment
- Block deployment on CRITICAL
- Update base images regularly
- Keep dependencies updated
- Create Security SLA: Fix CRITICAL within 24 hours

---

### Q18. How are secrets handled securely in this project?

**Answer:**
Secrets are handled at multiple levels:

**1. In Code:**
```python
# DON'T do this:
JWT_SECRET = "hardcoded-secret"  # ✗ Bad

# DO this:
JWT_SECRET = os.getenv('JWT_SECRET')  # ✓ Good
# Gets from environment variable or Secret mount
```

**2. In Docker:**
```dockerfile
# DON'T do this:
ENV JWT_SECRET=password123  # ✗ Bad (visible in image)

# DO this:
# Don't embed secrets in image
# Mount secrets at runtime via Kubernetes
```

**3. In Kubernetes:**
```yaml
# Store in Secret object (not ConfigMap)
apiVersion: v1
kind: Secret
type: Opaque
stringData:
  JWT_SECRET: demo-secret-change-me

# Never in deployment YAML
# Mount as environment variables
env:
- name: JWT_SECRET
  valueFrom:
    secretKeyRef:
      name: healthcare-api-secret
      key: JWT_SECRET
```

**4. In API Responses:**
```python
# DON'T do this:
return jsonify({
    "jwt_secret": JWT_SECRET  # ✗ Exposed
})

# DO this:
return jsonify({
    "security": "secrets managed by Kubernetes Secret"  # ✓ Information only
})
```

**5. In Logs:**
```python
# DON'T do this:
logger.info(f"Secret: {JWT_SECRET}")  # ✗ Logged

# DO this:
logger.info("Secret initialized")  # ✓ No value logged
```

**Production Recommendations:**
- Use Vault for centralized secret management
- Enable encryption at rest for etcd
- Implement secret rotation (90-day cycles)
- Audit all secret access
- Use separate secrets per environment
- Implement least-privilege access to secrets

---

### Q19. What is Network Policy and why do we need it?

**Answer:**
NetworkPolicy is a Kubernetes resource for network segmentation.

**Default Kubernetes Networking:**
- By default: All pods can talk to all pods
- Implicit allow everything
- Security risk: Lateral movement possible

**NetworkPolicy:**
- Explicit deny everything (default deny)
- Only allowed traffic flows
- Restricts ingress/egress

**Our NetworkPolicy:**

```yaml
# Only allow from same namespace
ingress:
- from:
  - namespaceSelector:
      matchLabels:
        name: healthcare-devops

# Only allow to DNS and HTTPS
egress:
- to:
  - namespaceSelector:
      matchLabels:
        name: kube-system
  ports:
  - protocol: UDP
    port: 53  # DNS
```

**Effect:**

```
Without NetworkPolicy:
  Pod A → Pod B (any namespace) ✓ Allowed
  Pod A → External DB ✓ Allowed
  Pod A → etcd ✓ Allowed (security risk!)

With NetworkPolicy:
  Pod A → Pod B (same namespace) ✓ Allowed
  Pod A → External DB ✗ Blocked
  Pod A → etcd ✗ Blocked
```

**Limitations:**
- Requires CNI support (Calico, Cilium)
- Not available in all Kubernetes distributions
- Minikube: Works with Calico addon
- Not enabled by default

**In Our Project:**
- NetworkPolicy provided as example
- Optional to enable
- Works if CNI supports it
- Minikube needs: `minikube addons enable calico`

---

### Q20. What are health checks (readiness and liveness probes)?

**Answer:**
Health checks ensure only healthy pods receive traffic.

**Readiness Probe:**
```yaml
readinessProbe:
  httpGet:
    path: /health
    port: 5000
  initialDelaySeconds: 10
  periodSeconds: 5
  timeoutSeconds: 3
  successThreshold: 1
  failureThreshold: 3
```

**Purpose:** "Is pod ready to serve traffic?"
- Checked every 5 seconds
- If fails 3 times → Pod removed from service
- New requests don't go to unready pod
- Old connections finish gracefully

**Liveness Probe:**
```yaml
livenessProbe:
  httpGet:
    path: /health
    port: 5000
  initialDelaySeconds: 30
  periodSeconds: 10
  timeoutSeconds: 5
  failureThreshold: 3
```

**Purpose:** "Is pod still alive?"
- Checked every 10 seconds
- If fails 3 times → Pod is restarted
- Self-healing mechanism
- Recovers from deadlocks/hangs

**Startup Probe:**
```yaml
startupProbe:
  httpGet:
    path: /health
    port: 5000
  failureThreshold: 30
  periodSeconds: 5
```

**Purpose:** "Is pod starting up?"
- Gives pod time to boot
- Disables other probes during startup
- Prevents premature restart

**Our /health Endpoint:**
```python
@app.route('/health', methods=['GET'])
def health():
    return jsonify({
        "status": "healthy",
        "service": "healthcare-api"
    }), 200
```

**Probe Timeline:**
```
Pod Created
  ↓
Startup Probe checks (every 5s, up to 150s)
  ├─ Pass: Move to readiness/liveness
  └─ Fail 30 times: Pod restarted
  ↓
Readiness Probe checks (every 5s)
  ├─ Pass: Add to service
  └─ Fail 3 times: Remove from service
  ↓
Liveness Probe checks (every 10s)
  ├─ Pass: Pod healthy
  └─ Fail 3 times: Pod restarted
```

---

## SECTION 5: JENKINS & AUTOMATION

### Q21. Explain the Jenkins pipeline stages in our project

**Answer:**

**12-Stage Pipeline:**

1. **Checkout**: Clone Git repository
   - Gets latest code
   - Sets up workspace

2. **Environment Info**: Display versions
   - Docker, kubectl, Python versions
   - Aids troubleshooting

3. **Install Dependencies**: pip install
   - Installs Python packages
   - Sets up test environment

4. **Unit Tests**: pytest
   - Runs test_app.py
   - Tests all endpoints
   - [FAIL → Stop]

5. **Build Docker Image**: docker build
   - Multi-stage build
   - Tags: BUILD_NUMBER, green, latest

6. **Trivy Security Scan**: Scan image
   - Checks for CVEs
   - HIGH, CRITICAL severity
   - [CRITICAL → Abort]

7. **Docker Login**: Authenticate
   - Logs into Docker Hub
   - Uses Jenkins credentials

8. **Push Image**: docker push
   - Pushes 3 tagged versions
   - Makes available for deployment

9. **Deploy Green**: kubectl apply
   - Deploys to Kubernetes
   - Creates/updates Green deployment
   - Waits for pods ready

10. **Smoke Test Green**: Automated tests
    - Tests /health, /version, /patients
    - [FAIL → Stop]

11. **Switch Traffic**: Manual approval
    - Waits for user approval
    - Patches service selector Blue→Green
    - Production traffic switched

12. **Verify Production**: Final verification
    - Tests /version returns green-v2
    - Confirms deployment success

**Post Actions:**
- On Success: Print success message
- On Failure: Print rollback command
- Always: Display pod status

---

### Q22. How does Jenkins integrate with Docker and Kubernetes?

**Answer:**

**Docker Integration:**
```groovy
// Build image
docker build -t healthcare-api:BUILD_NUMBER .

// Tag image
docker tag healthcare-api:BUILD_NUMBER \
           healthcare-api:green

// Scan with Trivy
trivy image healthcare-api:BUILD_NUMBER

// Push to registry
docker push healthcare-api:BUILD_NUMBER
```

**Kubernetes Integration:**
```groovy
// Apply manifests
kubectl apply -f k8s/namespace.yaml
kubectl apply -f k8s/deployment.yaml

// Update image
kubectl set image deployment/healthcare-api-green \
  healthcare-api=healthcare-api:BUILD_NUMBER

// Wait for rollout
kubectl rollout status deployment/healthcare-api-green

// Patch service
kubectl patch service healthcare-service \
  -p '{"spec":{"selector":{"version":"green"}}}'

// Get status
kubectl get pods -n healthcare-devops
```

**Workflow:**
```
Jenkins            Docker              Kubernetes
  │                  │                     │
  ├─ Build ────────→ docker build         │
  │                  ├─ compile            │
  │                  └─ package image      │
  │                                        │
  ├─ Scan ─────────→ Trivy scans           │
  │                                        │
  ├─ Login ────────→ Docker Hub auth       │
  │                                        │
  ├─ Push ─────────→ Push image            │
  │                  └─ Image in registry  │
  │                                        │
  ├─ Deploy ──────────────────────────→ Pull image
  │                                   Deploy pod
  │                                   Start container
  │
  ├─ Test Green ──────────────────────→ Call /health
  │                                   Check response
  │
  ├─ Switch ──────────────────────────→ Patch service
  │                                   Update endpoints
  │
  └─ Verify ──────────────────────────→ Check status
                                      Get pods
```

---

### Q23. What happens if a Jenkins stage fails?

**Answer:**

**Unit Tests Fail (Stage 4):**
```
Pipeline Status: FAILED ✗
  ├─ Build not created
  ├─ No image pushed
  └─ Kubernetes: No change
  
Developer Action: Fix code, recommit
```

**Docker Build Fails (Stage 5):**
```
Pipeline Status: FAILED ✗
  ├─ Dockerfile syntax error
  ├─ Missing files
  └─ Image not created
  
Reason: Check Dockerfile, file permissions
```

**Trivy Finds CRITICAL (Stage 6):**
```
Pipeline Status: FAILED ✗
  ├─ Vulnerability found
  ├─ Image not pushed
  └─ Deployment blocked
  
Example: OpenSSL CVE-2023-xxxx (CRITICAL)
Action: Update base image or dependencies
```

**Kubernetes Deploy Fails (Stage 9):**
```
Pipeline Status: FAILED ✗
  ├─ Pods fail to start
  ├─ Image pull error
  ├─ Resource quota exceeded
  └─ No traffic switch
  
Blue remains production (no switch happened)
```

**Smoke Test Fails (Stage 10):**
```
Pipeline Status: FAILED ✗
  ├─ /health returns 500
  ├─ /version returns wrong data
  ├─ Connection refused
  └─ Pipeline stops (before switch!)
  
Blue remains production (protected by test)
```

**Switch Approved but Service Fails (Stage 11):**
```
Pipeline Status: FAILED ✗
  ├─ Service not found
  ├─ Patch fails
  └─ Manual intervention needed
  
Rollback: ./scripts/switch-to-blue.sh
```

**Post-Failure Actions:**
```groovy
post {
    failure {
        echo "Build failed"
        sh '''
            echo "Rollback command:"
            echo "kubectl patch service healthcare-service \
                 -p '{\"spec\":{\"selector\":{\"version\":\"blue\"}}}'"
            kubectl logs -l version=green \
              -n healthcare-devops --tail=50
        '''
    }
}
```

---

### Q24. How would you add automated monitoring/alerting to this pipeline?

**Answer:**

**Current State:**
- Manual testing in stage 10
- No automated metrics collection
- No alerting on production issues

**Monitoring Enhancements:**

**1. Application Metrics:**
```python
# Add to Flask app
from prometheus_client import Counter, Histogram

request_count = Counter('app_requests_total', 'Total requests')
request_duration = Histogram('app_request_duration_seconds', 'Request duration')

@app.route('/metrics')
def metrics():
    from prometheus_client import generate_latest
    return generate_latest()
```

**2. Kubernetes Metrics:**
```bash
# Deploy Prometheus
helm install prometheus prometheus-community/kube-prometheus-stack

# Collect metrics:
# - Pod CPU/memory
# - Network traffic
# - Pod restart count
```

**3. Add Alerting to Jenkins:**
```groovy
stage('13. Monitor Green') {
    steps {
        sh '''
            # Check pod metrics
            cpu=$(kubectl top pod -l version=green \
                  -n healthcare-devops --no-headers | awk '{print $2}' | cut -d 'm' -f1 | awk '{s+=$1} END {print s/NR}')
            
            if [ $cpu -gt 500 ]; then
                echo "High CPU usage: $cpu%"
                exit 1  # Fail stage
            fi
        '''
    }
}
```

**4. Slack Notifications:**
```groovy
post {
    failure {
        slackSend(
            color: 'danger',
            message: "Healthcare API Deployment FAILED\n${BUILD_URL}\nRollback: kubectl patch..."
        )
    }
    success {
        slackSend(
            color: 'good',
            message: "Healthcare API deployed to Green successfully!\nVersion: green-v2"
        )
    }
}
```

**5. Email Notifications:**
```groovy
post {
    always {
        emailext(
            subject: "Jenkins Build ${BUILD_NUMBER}",
            body: "Build: ${BUILD_URL}\nStatus: ${BUILD_STATUS}",
            to: 'devops@hospital.com',
            attachmentsPattern: 'trivy-scan-*.json'
        )
    }
}
```

**6. Centralized Logging:**
```yaml
# Deploy ELK Stack
elasticsearch:  # Store logs
logstash:       # Process logs
kibana:         # Visualize logs

# All pod logs collected automatically:
kubectl logs -f healthcare-api-green \
  -n healthcare-devops | logstash
```

---

## SECTION 6: PRODUCTION CONSIDERATIONS

### Q25. What changes would you make to run this in production?

**Answer:**

**1. Kubernetes Cluster:**
```
From: Minikube (single node)
To:   Managed Kubernetes (EKS/AKS/GKE)

Requirements:
├─ Multiple nodes (3+ minimum)
├─ High availability zones
├─ Auto-scaling
├─ Managed control plane
└─ 99.99% SLA
```

**2. Secret Management:**
```
From: Kubernetes Secret (base64 only)
To:   HashiCorp Vault / AWS Secrets Manager

Features:
├─ Encrypted at rest
├─ Automatic rotation
├─ Audit trail
├─ Access control
└─ Compliance ready
```

**3. Container Registry:**
```
From: Docker Hub public
To:   Private registry (ECR/ACR/GCR)

Benefits:
├─ Private images
├─ Image signing
├─ Vulnerability scanning
├─ Access control
└─ Compliance audit
```

**4. Ingress & Load Balancing:**
```yaml
# Add Ingress for external access
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: healthcare-ingress
  annotations:
    cert-manager.io/cluster-issuer: letsencrypt-prod
spec:
  tls:
  - hosts:
    - healthcare.hospital.com
      secretName: healthcare-tls
  rules:
  - host: healthcare.hospital.com
    http:
      paths:
      - path: /
        backend:
          service:
            name: healthcare-service
            port:
              number: 80
```

**5. TLS/HTTPS:**
```
Add:
├─ SSL certificates (Let's Encrypt)
├─ Cert-manager for auto-renewal
├─ TLS termination at Ingress
└─ HTTPS enforcement
```

**6. Database:**
```
From: In-memory only (demo)
To:   Persistent database

Options:
├─ Managed (RDS, CloudSQL)
├─ StatefulSet (MySQL in K8s)
├─ Kubernetes PersistentVolume
└─ Backup strategy (daily snapshots)
```

**7. Logging & Monitoring:**
```
Add:
├─ Prometheus for metrics
├─ Grafana for dashboards
├─ ELK for log aggregation
├─ Alert manager for notifications
└─ APM (DataDog, New Relic)
```

**8. Security Enhancements:**
```
├─ Pod Security Policies
├─ Network Policies (mandatory)
├─ Encryption at rest (etcd)
├─ Encryption in transit (TLS)
├─ Image signing & verification
├─ Regular penetration testing
├─ SIEM integration
└─ Compliance scanning (CIS)
```

**9. Backup & Disaster Recovery:**
```
├─ Velero for cluster backup
├─ Database point-in-time recovery
├─ Cross-region replication
├─ RTO < 1 hour
├─ RPO < 15 minutes
└─ DR drills (quarterly)
```

**10. GitOps:**
```
From: Manual Jenkins deployment
To:   GitOps (ArgoCD/Flux)

Benefits:
├─ Git as source of truth
├─ Automatic reconciliation
├─ Rollback via git revert
├─ Audit trail
└─ Policy enforcement
```

**11. Cost Optimization:**
```
├─ Node auto-scaling
├─ Pod disruption budgets
├─ Reserved instances
├─ Spot instances for non-critical
└─ Resource quotas per team
```

**12. Compliance:**
```
Healthcare-specific:
├─ HIPAA compliance
├─ GDPR data residency
├─ SOC 2 audit
├─ Encryption requirements
├─ Access logs (immutable)
├─ Data retention policy
└─ Right to delete
```

---

### Q26. How would you handle database migrations between Blue and Green?

**Answer:**

**Challenge:**
Blue and Green may have different database schemas.

**Strategy 1: Backward-Compatible Migrations**
```
Goal: New app works with old schema

Steps:
1. Design new schema backward-compatible
2. Green reads from old and new columns
3. Switch to Green (uses old schema)
4. Run migration (add new columns)
5. Green uses new schema
```

**Strategy 2: Blue Performs Migration**
```
1. Blue running (v1)
2. Blue runs migration script (schema updated)
3. Green deployed (works with new schema)
4. Switch to Green
5. Green uses updated schema
```

**Strategy 3: Separate Migration Service**
```
Migration Service (runs independently)
├─ Updates schema before deployment
├─ Validates schema compatibility
└─ Notifies when safe to deploy

Deployment:
1. Run migration service
2. Wait for completion
3. Deploy Green
4. Switch to Green
```

**Example: Adding Column**

```sql
-- WRONG (breaks Green if it expects column):
ALTER TABLE patients ADD COLUMN address VARCHAR(200);

-- RIGHT (backward-compatible):
ALTER TABLE patients 
  ADD COLUMN address VARCHAR(200) DEFAULT '';

-- Then deploy:
1. Run migration
2. Deploy Green (handles NULL/empty)
3. Switch to Green
4. Green starts populating address
5. Later: Remove DEFAULT, require address
```

**Database-Specific Tools:**
```bash
# Database schema versioning
Flyway, Liquibase, Alembic (Python)

# Migration process:
1. Version control schema changes
2. Apply to database automatically
3. Rollback support
4. Audit trail
5. CI/CD integration
```

**Our Project:**
- Demo: In-memory database (no migration needed)
- Production: Would use Flyway or Liquibase
- Blue-Green: Schema changes handled by migration tool
- Rollback: Database versioning enabled

---

### Q27. How would you implement canary deployment with this architecture?

**Answer:**

**Canary vs Blue-Green:**

```
Blue-Green:
  0% Green → 100% Green (binary switch)

Canary:
  0% → 5% → 10% → 25% → 50% → 100% (gradual)
```

**Canary Implementation:**

**Option 1: Kubernetes Native (Nginx Ingress)**
```yaml
# Ingress with traffic weight
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  annotations:
    nginx.ingress.kubernetes.io/canary: "true"
    nginx.ingress.kubernetes.io/canary-weight: "10"  # 10% to canary
spec:
  rules:
  - host: healthcare.hospital.com
    http:
      paths:
      - path: /
        backend:
          service:
            name: healthcare-service  # 90%
            port: 80
---
# Canary Ingress (10%)
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  annotations:
    nginx.ingress.kubernetes.io/canary: "true"
    nginx.ingress.kubernetes.io/canary-weight: "10"
spec:
  rules:
  - host: healthcare.hospital.com
    http:
      paths:
      - path: /
        backend:
          service:
            name: healthcare-canary-service  # 10%
            port: 80
```

**Option 2: Service Mesh (Istio)**
```yaml
apiVersion: networking.istio.io/v1alpha3
kind: VirtualService
metadata:
  name: healthcare-vs
spec:
  hosts:
  - healthcare.hospital.com
  http:
  - match:
    - headers:
        user-type:
          exact: beta-tester  # Beta testers get v2
    route:
    - destination:
        host: healthcare-service
        subset: v2
      weight: 100
  - route:
    - destination:
        host: healthcare-service
        subset: v1
      weight: 90  # 90% v1
    - destination:
        host: healthcare-service
        subset: v2
      weight: 10  # 10% v2
```

**Canary Deployment Process:**

```
Phase 1: Deploy Green (Canary)
  Production: Blue (100%)
  Canary: Green (0% traffic, ready)

Phase 2: Start Canary (5%)
  Production: Blue (95%)
  Canary: Green (5%)
  Monitor: Error rates, latency, CPU

Phase 3: Ramp Up (10%)
  Monitor metrics
  If errors < threshold, continue
  If errors > threshold, rollback to 0%

Phase 4: Ramp Up (25%)
  Monitor for 15 minutes
  Check logs, metrics, alerts

Phase 5: Ramp Up (50%)
  Monitor for 30 minutes
  Run load tests

Phase 6: Complete Transition (100%)
  All traffic on Green
  Blue still running for rollback

Phase 7: Cleanup
  Keep Blue for 1 hour
  Monitor Green stability
  If OK, terminate Blue
```

**Canary Metrics to Monitor:**
```
├─ Error rate (HTTP 500s)
├─ Latency (p50, p95, p99)
├─ CPU & Memory
├─ Database connection count
├─ API response times
├─ Business metrics (conversions)
└─ User feedback
```

**Automatic Rollback Criteria:**
```
if error_rate > 5% {
    rollback();  // Go back to previous weight
}

if latency_p99 > 1000ms {
    rollback();
}

if cpu_usage > 80% {
    rollback();
}
```

**Canary Advantages:**
- Early bug detection with real traffic
- Gradual rollback possible
- Catch issues before 100% traffic
- Safe for production

**Disadvantages:**
- Complexity (multiple versions running)
- Resource usage (3x for full ramp)
- Longer deployment time
- Split-brain issues with state

---

### Q28. How would you handle zero-downtime updates for database schema changes?

**Answer:**

**Challenge:**
Schema changes might break running version.

**Approach: Expand-Contract Pattern**

**Phase 1: Expand (Add Column)**
```sql
-- Blue running v1
-- Add new column to DB
ALTER TABLE patients ADD COLUMN age_group VARCHAR(20) DEFAULT '';

-- Both v1 and v2 can run:
-- v1: Ignores age_group
-- v2: Uses age_group
```

**Phase 2: Deploy Green**
```
Green deployed (v2)
├─ Reads/writes age_group
└─ Blue running (ignores age_group)
```

**Phase 3: Migration Data**
```bash
-- Backfill data
UPDATE patients SET age_group = 
  CASE 
    WHEN age < 18 THEN 'Minor'
    WHEN age < 65 THEN 'Adult'
    ELSE 'Senior'
  END;
```

**Phase 4: Switch Traffic**
```
Blue (v1) → Green (v2)
└─ Green uses age_group
```

**Phase 5: Contract (Remove Old)**
```sql
-- After Green stable for hours
ALTER TABLE patients DROP COLUMN age;  -- old column

-- Now only age_group exists
-- v1 can't run anymore
-- But switch already happened
```

**Real Example: Rename Column**

Wrong way (causes downtime):
```sql
ALTER TABLE patients RENAME COLUMN age TO age_years;
-- v1: age not found (ERROR!)
-- v2: age_years not found (ERROR!)
```

Right way (expand-contract):
```
Step 1: Add new column
  ALTER TABLE patients ADD COLUMN age_years INT;

Step 2: Deploy v2 (reads age_years, writes both)
  INSERT INTO age_years SELECT age FROM patients;

Step 3: Switch traffic (v2 active)
  age_years has data, Blue can still read age

Step 4: v1 instances terminate naturally
  No more v1 reading age

Step 5: Drop old column
  ALTER TABLE patients DROP COLUMN age;
```

---

### Q29. What about session management during Blue-Green switch?

**Answer:**

**Problem:**
User has session on Blue, request goes to Green after switch.

**Scenario:**
```
User Login → Blue (session created, session_id=123)
[Traffic switched to Green]
User Action → Green (session_id=123 not found!)
Result: User logged out (bad experience)
```

**Solutions:**

**Option 1: External Session Store**
```
Use Redis or Memcached (external)

Flow:
1. User login on Blue
   → Session stored in Redis
2. Traffic switched
3. User action on Green
   → Green reads session from Redis (found!)
4. Continue without logout

Implementation:
├─ Flask-Session with Redis backend
├─ Shared session storage
└─ Both Blue and Green access same store
```

**Option 2: Session Affinity (Sticky Sessions)**
```yaml
# Service with session affinity
apiVersion: v1
kind: Service
metadata:
  name: healthcare-service
spec:
  sessionAffinity: ClientIP
  sessionAffinityConfig:
    clientIP:
      timeoutSeconds: 10800  # 3 hours
```

**Effect:**
- User request goes to same pod
- Even after Blue-Green switch
- Pod has connection state
- Problems:
  - Uneven load
  - Session stuck on failed pod

**Option 3: JWT Tokens (Stateless)**
```python
# Instead of session storage:
@app.route('/login', methods=['POST'])
def login():
    # Create JWT token (no server-side session)
    token = jwt.encode({
        'user_id': user.id,
        'exp': datetime.utcnow() + timedelta(hours=1)
    }, JWT_SECRET)
    return {'token': token}

# Client stores token
# Sends in header: Authorization: Bearer <token>

# Server validates token
@app.route('/patients', methods=['GET'])
def get_patients():
    token = request.headers.get('Authorization')
    payload = jwt.decode(token, JWT_SECRET)
    user_id = payload['user_id']
    # Continue
```

**Benefits of JWT:**
- No server-side session storage needed
- Stateless (can scale infinitely)
- Works with Blue-Green/stateless deployments
- Secure with signature

**Our Project Recommendation:**
```
Development: Session affinity (simple)
Production: JWT tokens (scalable)

Implementation:
1. Add JWT auth to Flask app
2. Client stores token in localStorage
3. Send in every request
4. Server validates signature
5. Blue-Green switch: No impact
6. Can scale to any number of pods
```

---

### Q30. How would you implement GitOps with this project?

**Answer:**

**Current State:**
```
Manual: Developer → Jenkins → Kubectl → Kubernetes
```

**GitOps State:**
```
Git as source of truth
  ↓
Automatic reconciliation
  ↓
Kubernetes always matches Git
```

**Setup GitOps with ArgoCD:**

**Step 1: Create Git Repository Structure**
```
healthcare-gitops-repo/
├─ environments/
│  ├─ dev/
│  │  └─ kustomization.yaml
│  └─ prod/
│     └─ kustomization.yaml
├─ apps/
│  └─ healthcare-api/
│     ├─ deployment.yaml
│     ├─ service.yaml
│     └─ kustomization.yaml
└─ argocd-apps/
   └─ healthcare-api-app.yaml
```

**Step 2: Deploy ArgoCD**
```bash
kubectl create namespace argocd
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml

# ArgoCD controller watches Git
# Syncs to Kubernetes automatically
```

**Step 3: Create ArgoCD Application**
```yaml
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: healthcare-api
  namespace: argocd
spec:
  project: default
  source:
    repoURL: https://github.com/hospital/healthcare-gitops-repo
    targetRevision: main
    path: apps/healthcare-api
  destination:
    server: https://kubernetes.default.svc
    namespace: healthcare-devops
  syncPolicy:
    automated:
      prune: true          # Delete resources not in Git
      selfHeal: true       # Resync if drift detected
    syncOptions:
    - CreateNamespace=true
```

**Step 4: Update Deployment via Git**
```bash
# Instead of: kubectl set image ...
# Just update Git:

git checkout -b feature/update-to-v2
# Edit apps/healthcare-api/deployment.yaml
image: healthcare-api:v2  # Change version

git commit -m "Upgrade to v2"
git push origin feature/update-to-v2
# Create Pull Request
# Approve PR
# Merge to main

# ArgoCD detects Git change
# ArgoCD applies changes to Kubernetes
# Kubernetes updates deployment
# Blue-Green switch happens
```

**GitOps Workflow:**

```
Developer                 Git                      ArgoCD              Kubernetes
    │                      │                         │                    │
    ├─ Code change        │                         │                    │
    │                      │                         │                    │
    ├─ Commit & Push ─────→ feature branch          │                    │
    │                      │                         │                    │
    ├─ Create PR ─────────→ PR created              │                    │
    │                      │                         │                    │
    ├─ Approve PR ────────→ Merge to main           │                    │
    │                      │                         │                    │
    │                      ├─ Webhook ─────────────→ Detected change     │
    │                      │                         │                    │
    │                      │                         ├─ Fetch new commit  │
    │                      │                         │                    │
    │                      │                         ├─ Generate manifests
    │                      │                         │                    │
    │                      │                         ├─ Apply manifests ──→ Deployment updated
    │                      │                         │                    │
    │                      │                         ├─ Monitor sync ────→ Pods updated
    │                      │                         │                    │
    └─ View deployment    ← ← ← ← ← ← ← ← ← ← ← ← ─ Dashboard ← ← ← ← Pods running
```

**Advantages:**
- Git is source of truth
- Every change tracked in Git
- Easy rollback (git revert)
- Audit trail (Git history)
- No manual kubectl
- Policy enforcement (only approved PRs)
- Self-healing (detects drift)

**Blue-Green with GitOps:**

```yaml
# Git repo stores both Blue and Green versions

# blue/deployment.yaml
image: healthcare-api:v1
version: blue

# green/deployment.yaml
image: healthcare-api:v2
version: green

# main/service.yaml
selector:
  version: blue  # Change this to switch traffic

# Switch traffic:
# 1. Edit main/service.yaml (version: green)
# 2. Commit and push
# 3. Create and approve PR
# 4. Merge to main
# 5. ArgoCD detects change
# 6. ArgoCD patches service
# 7. Traffic switches to Green
```

**Rollback with GitOps:**
```bash
# If issue detected:
git revert HEAD
git push
# ArgoCD automatically reverts deployment
# Traffic back to Blue (automatic!)
```

---

## Summary

These 30 questions cover:
- ✅ Fundamentals (CI/CD, Docker, Kubernetes, Jenkins)
- ✅ Blue-Green deployment strategy
- ✅ Kubernetes objects and concepts
- ✅ Security implementation
- ✅ Jenkins automation
- ✅ Production considerations
- ✅ Advanced topics (canary, GitOps, zero-downtime)

**For Viva Preparation:**
- Understand each answer thoroughly
- Be ready to explain with examples
- Discuss trade-offs and limitations
- Show practical examples from the project
- Explain why each decision was made

**Key Points to Emphasize:**
1. Blue-Green enables safe deployments
2. Security is layered (not just one thing)
3. Automation reduces human error
4. Testing before production is critical
5. Monitoring enables quick detection
6. GitOps is the future of deployment

---

**Last Updated**: May 2, 2026
**Status**: Prepared for Viva review
