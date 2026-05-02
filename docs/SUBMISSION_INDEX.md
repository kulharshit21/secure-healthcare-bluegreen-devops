# SUBMISSION_INDEX

## 1) What to Submit

- `README.md`
- `Dockerfile`
- `Jenkinsfile`
- `Jenkinsfile.demo`
- `app/`
- `k8s/`
- `scripts/`
- `docs/PROJECT_REPORT.md`
- `docs/FINAL_RUNTIME_EVIDENCE.md`
- `docs/VIVA_DEMO_SCRIPT_FINAL.md`
- `docs/JENKINS_DEMO_SETUP.md`
- `screenshots/`

## 2) Screenshot Checklist

- Jenkins SUCCESS
- Jenkins console showing 12 passed
- `kubectl get nodes`
- `kubectl get pods -n healthcare-devops --show-labels`
- `kubectl get svc -n healthcare-devops`
- blue main service response
- green service response
- selector green
- main service after switch
- selector blue
- main service after rollback
- UID/GID proof
- Trivy 0 CRITICAL

## 3) Viva Order

1. Start with architecture
2. Show Jenkins
3. Show app/API
4. Show Kubernetes
5. Show switch/rollback
6. Show security
7. End with limitations/future scope
