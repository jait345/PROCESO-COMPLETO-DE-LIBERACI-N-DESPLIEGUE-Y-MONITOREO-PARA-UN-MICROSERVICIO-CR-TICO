#!/usr/bin/env bash
set -euo pipefail

NS=${NS:-default}
WEIGHT=${WEIGHT:-5}

kubectl -n "$NS" annotate ingress transaction-validator-canary nginx.ingress.kubernetes.io/canary-weight="$WEIGHT" --overwrite
