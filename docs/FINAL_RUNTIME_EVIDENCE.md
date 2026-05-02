# FINAL_RUNTIME_EVIDENCE

## 1) Tools Verified

- Docker:
  - `docker --version` -> `Docker version 29.4.0, build 9d7ad9f`
- kubectl:
  - `kubectl version --client` -> `Client Version: v1.34.1`
- Minikube:
  - `minikube version` -> `v1.38.1`
  - `minikube status` -> `host: Running`, `kubelet: Running`, `apiserver: Running`, `kubeconfig: Configured`
- Trivy:
  - `trivy --version` -> `Version: 0.70.0`
- Jenkins:
  - Jenkins Docker container runtime was executed for demo pipeline
  - Jenkins fetched `Jenkinsfile.demo` from GitHub and completed CI demo run

## 2) Python Test Proof

- Command:
  - `python -m pytest app/test_app.py -v`
- Result:
  - `12 passed`

## 3) Docker Proof

- `docker build -t healthcare-api:blue .` succeeded
- `docker build -t healthcare-api:green .` succeeded
- Runtime version proof (through service testing):
  - Blue path returned `blue-v1`
  - Green path returned `green-v2`

## 4) Kubernetes Proof

- Node readiness:
  - `kubectl get nodes` -> `minikube   Ready   control-plane`
- Pods running:
  - Blue deployment pods: running and ready
  - Green deployment pods: running and ready
- Services created:
  - `healthcare-service`
  - `healthcare-blue-service`
  - `healthcare-green-service`

## 5) Blue-Green Proof

Before switch:
main service /version -> blue-v1 / blue

Green independent test:
green service /version -> green-v2 / green

After switch:
main service /version -> green-v2 / green

After rollback:
main service /version -> blue-v1 / blue

Note:
Because `kubectl port-forward` can pin to an existing backend, the main port-forward tunnel was restarted after selector patch to show the updated service route.

## 6) Security Proof

- Non-root UID/GID proof (post-hardening):
  - `kubectl exec -n healthcare-devops deployment/healthcare-api-blue -- id` -> `uid=1000 gid=1000 groups=1000`
  - `kubectl exec -n healthcare-devops deployment/healthcare-api-green -- id` -> `uid=1000 gid=1000 groups=1000`
- Secret proof:
  - `kubectl get secret healthcare-api-secret -n healthcare-devops -o yaml`
  - Secret exists as `type: Opaque` with `data` keys (`API_KEY`, `DATABASE_PASSWORD`, `JWT_SECRET`)
- RBAC proof:
  - `kubectl auth can-i get deployments --as=system:serviceaccount:healthcare-devops:healthcare-api-sa -n healthcare-devops` -> `yes`
  - `kubectl auth can-i patch services --as=system:serviceaccount:healthcare-devops:healthcare-api-sa -n healthcare-devops` -> `yes`
- Health probe proof:
  - `kubectl describe deployment healthcare-api-blue -n healthcare-devops` shows readiness/liveness/startup probes on `/health`
  - `kubectl describe deployment healthcare-api-green -n healthcare-devops` shows readiness/liveness/startup probes on `/health`
- Trivy summary (final):
  - Blue: OS `7 HIGH, 0 CRITICAL`; Python `3 HIGH, 0 CRITICAL`
  - Green: OS `7 HIGH, 0 CRITICAL`; Python `3 HIGH, 0 CRITICAL`

## 7) Errors Found and Fixed

- `gunicorn` missing in runtime image (`ModuleNotFoundError`) -> fixed in `Dockerfile` runtime dependency install
- Stale Minikube image cache behavior -> handled with image reload + rollout restart
- PowerShell JSON patch quoting issues -> switched to robust command format
- PowerShell script parse errors -> fixed in Windows deployment/switch/rollback scripts
- Non-root group hardening gap (`gid=0`) -> fixed to `uid=1000 gid=1000`

## 8) Remaining Limitations

- Jenkins runtime was not executed on this local machine
- Trivy still reports HIGH findings (0 CRITICAL), mostly base OS package CVEs
- Minikube is a single-node local cluster, not production HA
- Demo uses dummy patient data only

## 9) Jenkins Demo Runtime Status

- Jenkins source:
  - Jenkins obtained `Jenkinsfile.demo` from GitHub repository
- Jenkins execution behavior:
  - checkout completed
  - virtualenv created
  - dependencies installed in virtualenv
  - pytest executed
  - result: `12 passed`
  - build result: `Finished: SUCCESS`
- Optional tooling behavior inside Jenkins Docker:
  - Docker/kubectl/Trivy stages skipped cleanly when tools were unavailable in container
- Scope note:
  - Full Docker/Kubernetes/Trivy runtime proof remains captured from host Minikube terminal verification

## Final Statement

Runtime-verified locally on Minikube, with Jenkins CI demo execution verified via `Jenkinsfile.demo`.
