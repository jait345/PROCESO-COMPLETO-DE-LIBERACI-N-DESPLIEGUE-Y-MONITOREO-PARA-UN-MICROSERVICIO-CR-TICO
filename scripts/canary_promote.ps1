Param(
  [string]$Namespace = "default",
  [int]$Weight = 5
)

kubectl -n $Namespace annotate ingress transaction-validator-canary nginx.ingress.kubernetes.io/canary-weight="$Weight" --overwrite
