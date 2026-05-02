# Switch traffic from Green back to Blue (Windows PowerShell)

param(
    [string]$Namespace = "healthcare-devops",
    [string]$Service = "healthcare-service"
)

Write-Host "==========================================" -ForegroundColor Cyan
Write-Host "Switching Traffic: Green -> Blue" -ForegroundColor Cyan
Write-Host "==========================================" -ForegroundColor Cyan

Write-Host ""
Write-Host "Current service selector:" -ForegroundColor Yellow
$CurrentApp = kubectl get svc $Service -n $Namespace -o jsonpath='{.spec.selector.app}'
$CurrentVersion = kubectl get svc $Service -n $Namespace -o jsonpath='{.spec.selector.version}'
Write-Host "  app=$CurrentApp"
Write-Host "  version=$CurrentVersion"
Write-Host ""

Write-Host "Patching $Service selector to Blue..." -ForegroundColor Green
kubectl patch service $Service `
    -n $Namespace `
    -p '{"spec":{"selector":{"app":"healthcare-api","version":"blue"}}}'

Write-Host ""
Write-Host "Waiting for endpoints to update..." -ForegroundColor Yellow
Start-Sleep -Seconds 3

Write-Host ""
Write-Host "==========================================" -ForegroundColor Cyan
Write-Host "✓ Traffic switched back to Blue" -ForegroundColor Green
Write-Host "==========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "New service selector:" -ForegroundColor Yellow
$NewApp = kubectl get svc $Service -n $Namespace -o jsonpath='{.spec.selector.app}'
$NewVersion = kubectl get svc $Service -n $Namespace -o jsonpath='{.spec.selector.version}'
Write-Host "  app=$NewApp"
Write-Host "  version=$NewVersion"
Write-Host ""
Write-Host "Service endpoints:" -ForegroundColor Yellow
kubectl get endpoints $Service -n $Namespace
Write-Host ""
Write-Host "Verify by checking version:" -ForegroundColor Yellow
Write-Host "  kubectl port-forward svc/$Service 8080:80 -n $Namespace"
Write-Host "  curl http://localhost:8080/version"
Write-Host ""
