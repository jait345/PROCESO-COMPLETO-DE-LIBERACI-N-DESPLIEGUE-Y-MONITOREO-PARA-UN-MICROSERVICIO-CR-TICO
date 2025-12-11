Param(
  [string]$Namespace = "default",
  [string]$CanaryHost = $env:CANARY_HOST,
  [switch]$SkipValidation
)

if (-not $CanaryHost) { $CanaryHost = "http://validator.payflow.local:8080" }

Write-Host "[1/6] Node: install & unit tests" -ForegroundColor Cyan
Push-Location (Join-Path $PSScriptRoot "..\transaction-validator")
npm install --omit=dev --no-audit --no-fund
if ($LASTEXITCODE -ne 0) { throw "npm install failed" }
npm test
if ($LASTEXITCODE -ne 0) { throw "npm test failed" }
Pop-Location

Write-Host "[2/6] Python: install & tests" -ForegroundColor Cyan
python -m pip install --upgrade pip
python -m pip install -r (Join-Path $PSScriptRoot "..\tests\requirements.txt")
python -m unittest (Join-Path $PSScriptRoot "..\tests\test_unit.py")

Write-Host "[3/6] Docker build local image" -ForegroundColor Cyan
docker build -t transaction-validator:local (Join-Path $PSScriptRoot "..\transaction-validator")
if ($LASTEXITCODE -ne 0) { throw "docker build failed" }

Write-Host "[4/6] Kubernetes deploy (simulado prod)" -ForegroundColor Cyan
& (Join-Path $PSScriptRoot "release.ps1") -ImageTag "transaction-validator:local" -Namespace $Namespace

Write-Host "[5/6] Set canary to 5%" -ForegroundColor Cyan
& (Join-Path $PSScriptRoot "..\scripts\canary_promote.ps1") -Namespace $Namespace -Weight 5

if (-not $SkipValidation) {
  Write-Host "[6/6] Validación simple de salud" -ForegroundColor Cyan
  try {
    $health = Invoke-WebRequest -Uri ("{0}/health" -f $CanaryHost) -UseBasicParsing -TimeoutSec 5
    if ($health.StatusCode -ne 200) { throw "Health no 200" }
  } catch {
    Write-Warning "Health check falló: $_"
  }
}

Write-Host "Pipeline local completado" -ForegroundColor Green
