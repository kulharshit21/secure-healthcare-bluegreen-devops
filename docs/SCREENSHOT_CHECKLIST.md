# SCREENSHOT_CHECKLIST

- pytest 12 passed
- kubectl get nodes
- kubectl get pods -n healthcare-devops --show-labels
- kubectl get svc -n healthcare-devops
- blue main service /version showing blue-v1
- green service /version showing green-v2
- selector after switch showing healthcare-api green
- main service after switch showing green-v2
- selector after rollback showing healthcare-api blue
- main service after rollback showing blue-v1
- kubectl exec blue -- id showing uid=1000 gid=1000
- kubectl exec green -- id showing uid=1000 gid=1000
- Trivy scan showing 0 CRITICAL
- git status clean
