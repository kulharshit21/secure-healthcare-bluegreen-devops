# Verify and Display Current Deployment Status (Windows PowerShell)

param(
    [string]$Namespace = "healthcare-devops"
)

Write-Host "==========================================" -ForegroundColor Cyan
Write-Host "Healthcare API - Deployment Status" -ForegroundColor Cyan
Write-Host "==========================================" -ForegroundColor Cyan

Write-Host ""
Write-Host "========== Namespace ==========" -ForegroundColor Yellow
kubectl get namespace $Namespace

Write-Host ""
Write-Host "========== Deployments ==========" -ForegroundColor Yellow
kubectl get deployments -n $Namespace -o wide

Write-Host ""
Write-Host "========== Pods ==========" -ForegroundColor Yellow
kubectl get pods -n $Namespace -o wide

Write-Host ""
Write-Host "========== Replica Sets ==========" -ForegroundColor Yellow
kubectl get rs -n $Namespace

Write-Host ""
Write-Host "========== Services ==========" -ForegroundColor Yellow
kubectl get svc -n $Namespace -o wide

Write-Host ""
Write-Host "========== Service Selectors ==========" -ForegroundColor Yellow
Write-Host "Main Service (healthcare-service) selector:"
$MainApp = kubectl get svc healthcare-service -n $Namespace -o jsonpath='{.spec.selector.app}'
$MainVersion = kubectl get svc healthcare-service -n $Namespace -o jsonpath='{.spec.selector.version}'
Write-Host "  app=$MainApp"
Write-Host "  version=$MainVersion"

Write-Host ""
Write-Host "Green Service selector:"
$GreenApp = kubectl get svc healthcare-green-service -n $Namespace -o jsonpath='{.spec.selector.app}'
$GreenVersion = kubectl get svc healthcare-green-service -n $Namespace -o jsonpath='{.spec.selector.version}'
Write-Host "  app=$GreenApp"
Write-Host "  version=$GreenVersion"

Write-Host ""
Write-Host "========== Endpoints ==========" -ForegroundColor Yellow
kubectl get endpoints -n $Namespace

Write-Host ""
Write-Host "========== ConfigMap ==========" -ForegroundColor Yellow
kubectl get configmap -n $Namespace

Write-Host ""
Write-Host "========== Secrets ==========" -ForegroundColor Yellow
kubectl get secrets -n $Namespace

Write-Host ""
Write-Host "========== RBAC ==========" -ForegroundColor Yellow
Write-Host "Service Accounts:"
kubectl get serviceaccount -n $Namespace
Write-Host ""
Write-Host "Roles:"
kubectl get roles -n $Namespace
Write-Host ""
Write-Host "Role Bindings:"
kubectl get rolebindings -n $Namespace

Write-Host ""
Write-Host "========== Recent Pod Events ==========" -ForegroundColor Yellow
kubectl describe pods -n $Namespace | Select-String -Pattern "Events" -Context 0,5

Write-Host ""
Write-Host "========== Testing Endpoints ==========" -ForegroundColor Yellow
Write-Host ""
Write-Host "To test production service (currently routing to):"
Write-Host "  kubectl port-forward svc/healthcare-service 8080:80 -n $Namespace &"
Write-Host "  curl http://localhost:8080/version"
Write-Host "  curl http://localhost:8080/health"
Write-Host "  curl http://localhost:8080/patients"
Write-Host ""

Write-Host "To test Green service specifically:"
Write-Host "  kubectl port-forward svc/healthcare-green-service 8081:80 -n $Namespace &"
Write-Host "  curl http://localhost:8081/version"
Write-Host ""

Write-Host "To test Blue service specifically:"
Write-Host "  kubectl port-forward svc/healthcare-blue-service 8082:80 -n $Namespace &"
Write-Host "  curl http://localhost:8082/version"
Write-Host ""

Write-Host "==========================================" -ForegroundColor Cyan
