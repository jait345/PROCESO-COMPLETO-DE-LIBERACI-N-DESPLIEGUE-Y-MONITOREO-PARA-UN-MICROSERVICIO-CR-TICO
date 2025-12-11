Param(
  [string]$Namespace = "default"
)

Write-Host "Esperando despliegues listos..." -ForegroundColor Cyan
kubectl -n $Namespace rollout status deploy/transaction-validator --timeout=180s
kubectl -n $Namespace rollout status deploy/transaction-validator-canary --timeout=180s

Write-Host "Validando servicio estable" -ForegroundColor Cyan
kubectl -n $Namespace run tval-validate-stable --restart=Never --rm -i --image=curlimages/curl:8.0.1 -- sh -lc 'set -e; r=$(curl -s -m 5 -w " %{http_code}" http://transaction-validator/health); code=${r##* }; body=${r% *}; echo "$body"; test "$code" = "200" && echo "$body" | grep -q '"channel":"stable"''
if ($LASTEXITCODE -ne 0) { throw "Validación estable falló" }

Write-Host "Validando servicio canario" -ForegroundColor Cyan
kubectl -n $Namespace run tval-validate-canary --restart=Never --rm -i --image=curlimages/curl:8.0.1 -- sh -lc 'set -e; r=$(curl -s -m 5 -w " %{http_code}" http://transaction-validator-canary/health); code=${r##* }; body=${r% *}; echo "$body"; test "$code" = "200" && echo "$body" | grep -q '"channel":"canary"''
if ($LASTEXITCODE -ne 0) { throw "Validación canaria falló" }

Write-Host "Validación in-cluster OK" -ForegroundColor Green
