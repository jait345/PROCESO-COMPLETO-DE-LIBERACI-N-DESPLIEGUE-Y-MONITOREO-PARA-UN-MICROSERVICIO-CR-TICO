#!/usr/bin/env bash
set -euo pipefail

NS=${NS:-default}

echo "Waiting for stable deployment to be ready..."
kubectl -n "$NS" rollout status deploy/transaction-validator --timeout=180s
echo "Waiting for canary deployment to be ready..."
kubectl -n "$NS" rollout status deploy/transaction-validator-canary --timeout=180s

echo "Validating stable service"
kubectl -n "$NS" run tval-validate-stable --restart=Never --rm -i \
  --image=curlimages/curl:8.0.1 -- \
  sh -lc 'set -e; r=$(curl -s -m 5 -w " %{http_code}" http://transaction-validator/health); code=${r##* }; body=${r% *}; echo "$body"; test "$code" = "200" && echo "$body" | grep -q '"channel":"stable"''

echo "Validating canary service"
kubectl -n "$NS" run tval-validate-canary --restart=Never --rm -i \
  --image=curlimages/curl:8.0.1 -- \
  sh -lc 'set -e; r=$(curl -s -m 5 -w " %{http_code}" http://transaction-validator-canary/health); code=${r##* }; body=${r% *}; echo "$body"; test "$code" = "200" && echo "$body" | grep -q '"channel":"canary"''

echo "In-cluster validation succeeded"
