# Deploy Green Deployment to Kubernetes (Windows PowerShell)
param(
    [string]$DockerImage = "healthcare-api:green",
    [string]$Namespace = "healthcare-devops",
    [string]$GreenDeployment = "healthcare-api-green"
)

Write-Host '==========================================' -ForegroundColor Cyan
Write-Host 'Deploying Green Environment' -ForegroundColor Cyan
Write-Host '==========================================' -ForegroundColor Cyan
Write-Host ('Using Docker Image: ' + $DockerImage) -ForegroundColor Yellow
Write-Host ''

kubectl apply -f k8s/green-deployment.yaml
kubectl apply -f k8s/green-service.yaml
kubectl set image deployment/$GreenDeployment healthcare-api=$DockerImage -n $Namespace --record
kubectl rollout status deployment/$GreenDeployment -n $Namespace --timeout=5m

Write-Host ''
kubectl get deployments -n $Namespace
kubectl get pods -n $Namespace
kubectl get svc -n $Namespace
Write-Host ''
Write-Host ('  kubectl port-forward svc/healthcare-green-service 8081:80 -n ' + $Namespace)
Write-Host '  curl http://localhost:8081/version'
