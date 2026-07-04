param([string]$Command = "help")
$AppNs = if ($env:APP_NS) { $env:APP_NS } else { "gelato" }
$App = if ($env:APP) { $env:APP } else { "gelato-api" }
switch ($Command) {
  "ghcr-secret" {
    if (-not $env:GITHUB_USER -or -not $env:GHCR_TOKEN) { throw "Set GITHUB_USER and GHCR_TOKEN" }
    kubectl create namespace $AppNs --dry-run=client -o yaml | kubectl apply -f -
    kubectl -n $AppNs delete secret ghcr-secret --ignore-not-found
    kubectl -n $AppNs create secret docker-registry ghcr-secret --docker-server=ghcr.io --docker-username=$env:GITHUB_USER --docker-password=$env:GHCR_TOKEN --docker-email=devnull@example.com
  }
  "db-secret" {
    if (-not $env:DATABASE_URL) { throw "Set DATABASE_URL" }
    kubectl create namespace $AppNs --dry-run=client -o yaml | kubectl apply -f -
    kubectl -n $AppNs delete secret gelato-postgres-secret --ignore-not-found
    kubectl -n $AppNs create secret generic gelato-postgres-secret --from-literal="DATABASE_URL=$env:DATABASE_URL"
  }
  "apply-argocd" { kubectl apply -f argocd/application.yaml }
  "sync" { argocd app sync $App; argocd app wait $App --health --sync --timeout 300 }
  "status" { kubectl get pods,deploy,svc,job -n $AppNs }
  "logs" { kubectl logs -n $AppNs deployment/gelato-api -f --tail=120 }
  "restart" { kubectl rollout restart deployment/gelato-api -n $AppNs; kubectl rollout status deployment/gelato-api -n $AppNs --timeout=300s }
  "local-build" { docker build -t gelato-api:local . }
  "local-apply" { kubectl apply -k k8s/overlays/local }
  default { Write-Host "Commands: ghcr-secret, db-secret, apply-argocd, sync, status, logs, restart, local-build, local-apply" }
}
