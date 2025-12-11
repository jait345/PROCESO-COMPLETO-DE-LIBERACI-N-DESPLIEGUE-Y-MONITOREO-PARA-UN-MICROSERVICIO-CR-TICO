Param(
  [Parameter(Mandatory=$true)][string]$ImageTag,
  [string]$Namespace = "default"
)

$deployPath = Join-Path $PSScriptRoot "..\k8s\deploy.yaml"
$deployCanaryPath = Join-Path $PSScriptRoot "..\k8s\deployment-canary.yaml"
$svcPath    = Join-Path $PSScriptRoot "..\k8s\service.yaml"
$svcCanaryPath = Join-Path $PSScriptRoot "..\k8s\service-canary.yaml"
$ingPath    = Join-Path $PSScriptRoot "..\k8s\ingress.yaml"
$ingCanPath = Join-Path $PSScriptRoot "..\k8s\ingress-canary.yaml"

$content = Get-Content $deployPath -Raw
$updated = $content -replace "ghcr.io/your-org/transaction-validator:latest", $ImageTag
Set-Content -Path $deployPath -Value $updated -Encoding UTF8

if (Test-Path $deployCanaryPath) {
  $content2 = Get-Content $deployCanaryPath -Raw
  $updated2 = $content2 -replace "ghcr.io/your-org/transaction-validator:latest", $ImageTag
  Set-Content -Path $deployCanaryPath -Value $updated2 -Encoding UTF8
}

kubectl apply --validate=false -f $deployPath -n $Namespace
kubectl apply --validate=false -f $svcPath -n $Namespace
if (Test-Path $deployCanaryPath) { kubectl apply --validate=false -f $deployCanaryPath -n $Namespace }
if (Test-Path $svcCanaryPath) { kubectl apply --validate=false -f $svcCanaryPath -n $Namespace }
kubectl apply --validate=false -f $ingPath -n $Namespace
kubectl apply --validate=false -f $ingCanPath -n $Namespace
