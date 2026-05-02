# Deploy Blue Deployment to Kubernetes (Windows PowerShell)
param(
    [string]$Namespace = "healthcare-devops"
)

Write-Host '==========================================' -ForegroundColor Cyan
Write-Host 'Deploying Blue Environment' -ForegroundColor Cyan
Write-Host '==========================================' -ForegroundColor Cyan
Write-Host ''

kubectl apply -f k8s/namespace.yaml
kubectl apply -f k8s/configmap.yaml
kubectl apply -f k8s/secret.yaml
kubectl apply -f k8s/rbac.yaml
kubectl apply -f k8s/blue-deployment.yaml
kubectl apply -f k8s/service.yaml
kubectl rollout status deployment/healthcare-api-blue -n $Namespace --timeout=5m

Write-Host ''
kubectl get deployments -n $Namespace
kubectl get pods -n $Namespace
kubectl get svc -n $Namespace
Write-Host ''
Write-Host ('  kubectl port-forward svc/healthcare-service 8080:80 -n ' + $Namespace)
Write-Host '  curl http://localhost:8080/version'
