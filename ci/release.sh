#!/usr/bin/env bash
set -euo pipefail
IMG=${IMG:-ghcr.io/your-org/transaction-validator:latest}
sed -i "s|ghcr.io/your-org/transaction-validator:latest|${IMG}|" k8s/deploy.yaml
sed -i "s|ghcr.io/your-org/transaction-validator:latest|${IMG}|" k8s/deployment-canary.yaml || true
kubectl apply -f k8s/deploy.yaml
kubectl apply -f k8s/service.yaml
kubectl apply -f k8s/deployment-canary.yaml || true
kubectl apply -f k8s/service-canary.yaml || true
kubectl apply -f k8s/ingress.yaml
kubectl apply -f k8s/ingress-canary.yaml
