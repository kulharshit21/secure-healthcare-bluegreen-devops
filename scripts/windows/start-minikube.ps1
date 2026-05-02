# Start Minikube for Healthcare API Demo (Windows PowerShell)
# Run this script to initialize Minikube cluster

param(
    [string]$Driver = "docker",
    [int]$Cpus = 4,
    [int]$Memory = 8192,
    [string]$KubeVersion = "latest"
)

Write-Host "==========================================" -ForegroundColor Cyan
Write-Host "Starting Minikube for Healthcare API Demo" -ForegroundColor Cyan
Write-Host "==========================================" -ForegroundColor Cyan

Write-Host ""
Write-Host "Configuration:" -ForegroundColor Yellow
Write-Host "  Driver: $Driver"
Write-Host "  CPUs: $Cpus"
Write-Host "  Memory: ${Memory}MB"
Write-Host ""

# Check if minikube is installed
if (-not (Get-Command minikube -ErrorAction SilentlyContinue)) {
    Write-Host "Error: minikube is not installed" -ForegroundColor Red
    Write-Host "Install from: https://minikube.sigs.k8s.io/docs/start/" -ForegroundColor Red
    exit 1
}

# Check if Docker is running
try {
    docker info | Out-Null
} catch {
    Write-Host "Error: Docker is not running" -ForegroundColor Red
    Write-Host "Please start Docker Desktop" -ForegroundColor Red
    exit 1
}

Write-Host "Step 1: Starting Minikube..." -ForegroundColor Green
minikube start `
    --driver=$Driver `
    --cpus=$Cpus `
    --memory=$Memory `
    --kubernetes-version=$KubeVersion

Write-Host ""
Write-Host "Step 2: Enabling required addons..." -ForegroundColor Green
minikube addons enable metrics-server
minikube addons enable ingress
minikube addons enable dashboard

Write-Host ""
Write-Host "Step 3: Configuring kubectl..." -ForegroundColor Green
kubectl cluster-info

Write-Host ""
Write-Host "Step 4: Verifying cluster status..." -ForegroundColor Green
kubectl get nodes
kubectl get pods -A

Write-Host ""
Write-Host "==========================================" -ForegroundColor Cyan
Write-Host "✓ Minikube started successfully" -ForegroundColor Green
Write-Host "==========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Next steps:" -ForegroundColor Yellow
Write-Host "  1. Deploy Blue: .\scripts\windows\deploy-blue.ps1"
Write-Host "  2. Run pipeline or deploy Green manually"
Write-Host "  3. Switch traffic: .\scripts\windows\switch-to-green.ps1"
Write-Host "  4. View dashboard: minikube dashboard"
Write-Host ""
Write-Host "Useful commands:" -ForegroundColor Yellow
Write-Host "  kubectl get all -n healthcare-devops"
Write-Host "  kubectl port-forward svc/healthcare-service 8080:80 -n healthcare-devops"
Write-Host "  curl http://localhost:8080/health"
Write-Host ""
