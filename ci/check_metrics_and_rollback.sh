#!/usr/bin/env bash
set -euo pipefail
if ! command -v k6 >/dev/null 2>&1; then
  echo "k6 is required" >&2
  exit 1
fi
: "${CANARY_HOST:?set CANARY_HOST}"
if k6 run tests/k6-canary.js; then
  echo "canary validated"
else
  echo "canary failed, rolling back"
  kubectl rollout undo deployment transaction-validator || true
  exit 1
fi
