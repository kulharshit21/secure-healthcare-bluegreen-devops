# Rollback to Blue Deployment (Windows PowerShell)
param(
    [string]$Namespace = "healthcare-devops",
    [string]$Service = "healthcare-service"
)

Write-Host '==========================================' -ForegroundColor Cyan
Write-Host 'Rollback: Switching Traffic Back to Blue' -ForegroundColor Red
Write-Host '==========================================' -ForegroundColor Cyan
Write-Host ''

Write-Host 'Current service selector:' -ForegroundColor Yellow
$currentApp = kubectl get svc $Service -n $Namespace -o jsonpath='{.spec.selector.app}'
$currentVersion = kubectl get svc $Service -n $Namespace -o jsonpath='{.spec.selector.version}'
Write-Host ('  app=' + $currentApp)
Write-Host ('  version=' + $currentVersion)
Write-Host ''

Write-Host ('Patching ' + $Service + ' selector back to blue...') -ForegroundColor Green
cmd /c 'kubectl patch service healthcare-service -n healthcare-devops -p "{\"spec\":{\"selector\":{\"app\":\"healthcare-api\",\"version\":\"blue\"}}}"'
Write-Host ''

Write-Host 'Waiting for endpoints to update...' -ForegroundColor Yellow
Start-Sleep -Seconds 3
Write-Host ''

Write-Host '==========================================' -ForegroundColor Cyan
Write-Host 'Rollback completed' -ForegroundColor Green
Write-Host '==========================================' -ForegroundColor Cyan
Write-Host ''

Write-Host 'New service selector:' -ForegroundColor Yellow
$newApp = kubectl get svc $Service -n $Namespace -o jsonpath='{.spec.selector.app}'
$newVersion = kubectl get svc $Service -n $Namespace -o jsonpath='{.spec.selector.version}'
Write-Host ('  app=' + $newApp)
Write-Host ('  version=' + $newVersion)
Write-Host ''

Write-Host 'Service endpoints:' -ForegroundColor Yellow
kubectl get endpoints $Service -n $Namespace
Write-Host ''
Write-Host ('  kubectl port-forward svc/' + $Service + ' 8080:80 -n ' + $Namespace)
Write-Host '  curl http://localhost:8080/version'
