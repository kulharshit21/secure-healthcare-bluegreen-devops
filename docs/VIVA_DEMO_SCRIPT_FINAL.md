# VIVA_DEMO_SCRIPT_FINAL

## A) 5-Minute Demo Flow

1. Show project title and architecture:
   - "Secure CI/CD Pipeline for Automated Blue-Green Deployment of a Dockerized Healthcare Application on Kubernetes using Jenkins"
2. Show Flask endpoints:
   - `/health`, `/version`, `/patients`, `/security-status`
3. Show Dockerfile security:
   - non-root user/group (`1000:1000`)
4. Show Kubernetes blue/green pods:
   - `kubectl get pods -n healthcare-devops --show-labels`
5. Show blue URL:
   - main service on `8080` returns `blue-v1`
6. Show green URL:
   - green service on `8081` returns `green-v2`
7. Switch service selector:
   - patch `healthcare-service` selector to `version=green`
8. Show rollback:
   - patch back to `version=blue`
9. Show Trivy and security proof:
   - Trivy output, non-root id, secret object, RBAC can-i

## B) 10-Minute Demo Flow (PowerShell Commands)

```powershell
cd D:\Akul\secure-healthcare-bluegreen-devops

# 1) Environment + cluster
docker --version
kubectl version --client
minikube status
kubectl get nodes

# 2) Build + load images
docker build -t healthcare-api:blue .
docker build -t healthcare-api:green .
minikube image load healthcare-api:blue
minikube image load healthcare-api:green

# 3) Deploy and verify
kubectl apply -f k8s/namespace.yaml
kubectl apply -f k8s/configmap.yaml
kubectl apply -f k8s/secret.yaml
kubectl apply -f k8s/rbac.yaml
kubectl apply -f k8s/blue-deployment.yaml
kubectl apply -f k8s/service.yaml
kubectl apply -f k8s/green-deployment.yaml
kubectl apply -f k8s/green-service.yaml
kubectl get pods -n healthcare-devops --show-labels
kubectl get svc -n healthcare-devops

# 4) Main service (blue)
kubectl port-forward service/healthcare-service 8080:80 -n healthcare-devops
# New terminal:
curl.exe http://localhost:8080/version

# 5) Green service
kubectl port-forward service/healthcare-green-service 8081:80 -n healthcare-devops
# New terminal:
curl.exe http://localhost:8081/version

# 6) Switch to green
cmd /c "kubectl patch service healthcare-service -n healthcare-devops -p \"{\"\"spec\"\":{\"\"selector\"\":{\"\"app\"\":\"\"healthcare-api\"\",\"\"version\"\":\"\"green\"\"}}}\""
kubectl get svc healthcare-service -n healthcare-devops -o jsonpath="{.spec.selector.app} {.spec.selector.version}"

# Restart main port-forward, then:
curl.exe http://localhost:8080/version

# 7) Rollback to blue
cmd /c "kubectl patch service healthcare-service -n healthcare-devops -p \"{\"\"spec\"\":{\"\"selector\"\":{\"\"app\"\":\"\"healthcare-api\"\",\"\"version\"\":\"\"blue\"\"}}}\""
kubectl get svc healthcare-service -n healthcare-devops -o jsonpath="{.spec.selector.app} {.spec.selector.version}"

# Restart main port-forward, then:
curl.exe http://localhost:8080/version

# 8) Security and scan proof
kubectl exec -n healthcare-devops deployment/healthcare-api-blue -- id
kubectl exec -n healthcare-devops deployment/healthcare-api-green -- id
kubectl get secret healthcare-api-secret -n healthcare-devops -o yaml
kubectl auth can-i get deployments --as=system:serviceaccount:healthcare-devops:healthcare-api-sa -n healthcare-devops
kubectl auth can-i patch services --as=system:serviceaccount:healthcare-devops:healthcare-api-sa -n healthcare-devops
trivy image --severity HIGH,CRITICAL healthcare-api:blue
trivy image --severity HIGH,CRITICAL healthcare-api:green
```

## C) If Asked About Jenkins

"Jenkinsfile is implemented with checkout, test, Docker build, Trivy scan, push, deploy green, smoke test, service switch, and rollback logic. On this machine Jenkins service was not available, so runtime proof was done manually using the same Docker, Trivy, kubectl, and Minikube commands that Jenkins automates."

## D) If Asked About Healthcare Relevance

"This uses dummy patient data only. Healthcare relevance is shown through secure deployment practices: Kubernetes Secrets, RBAC, non-root container, vulnerability scanning, health checks, resource limits, and blue-green rollback for high availability."

## E) If Asked About Trivy HIGH Findings

"Trivy scanning was integrated and executed. It reported HIGH findings but 0 CRITICAL. For demo, this proves scanning works; production would block or remediate based on organizational policy."

## F) If Asked About Port-Forward Restart

"Port-forward was restarted after selector changes because a local port-forward tunnel can remain attached to a backend chosen before the selector change. In real cluster ingress/load balancer traffic would naturally follow service endpoints."
