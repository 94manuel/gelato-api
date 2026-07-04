#!/usr/bin/env bash
set -euo pipefail
APP_NS="${APP_NS:-gelato}"
ARGO_NS="${ARGO_NS:-argocd}"
APP="${APP:-gelato-api}"

usage(){ cat <<USAGE
Gelato API CLI

Commands:
  ghcr-secret       Create/update GHCR pull secret. Requires GITHUB_USER and GHCR_TOKEN.
  db-secret         Create/update DATABASE_URL secret. Requires DATABASE_URL.
  apply-argocd      Apply ArgoCD app for API.
  sync              Sync API app.
  status            Show API resources.
  logs              Follow API logs.
  migrate-logs      Show migration job logs.
  restart           Restart API deployment.
  local-build       Build local Docker image gelato-api:local.
  local-apply       Apply local kustomize overlay.
USAGE
}

case "${1:-help}" in
  ghcr-secret)
    : "${GITHUB_USER:?Set GITHUB_USER=94manuel}"; : "${GHCR_TOKEN:?Set GHCR_TOKEN}"
    kubectl create namespace "$APP_NS" --dry-run=client -o yaml | kubectl apply -f -
    kubectl -n "$APP_NS" delete secret ghcr-secret --ignore-not-found
    kubectl -n "$APP_NS" create secret docker-registry ghcr-secret --docker-server=ghcr.io --docker-username="$GITHUB_USER" --docker-password="$GHCR_TOKEN" --docker-email="${GITHUB_EMAIL:-devnull@example.com}"
    ;;
  db-secret)
    : "${DATABASE_URL:?Set DATABASE_URL}"
    kubectl create namespace "$APP_NS" --dry-run=client -o yaml | kubectl apply -f -
    kubectl -n "$APP_NS" delete secret gelato-postgres-secret --ignore-not-found
    kubectl -n "$APP_NS" create secret generic gelato-postgres-secret --from-literal=DATABASE_URL="$DATABASE_URL"
    ;;
  apply-argocd) kubectl apply -f argocd/application.yaml ;;
  sync) argocd app sync "$APP" && argocd app wait "$APP" --health --sync --timeout 300 ;;
  status) kubectl get applications -n "$ARGO_NS" || true; kubectl get pods,deploy,svc,job -n "$APP_NS" -l app.kubernetes.io/name=gelato-api || true ;;
  logs) kubectl logs -n "$APP_NS" deployment/gelato-api -f --tail=120 ;;
  migrate-logs) kubectl logs -n "$APP_NS" job/gelato-api-migrate --tail=200 ;;
  restart) kubectl rollout restart deployment/gelato-api -n "$APP_NS"; kubectl rollout status deployment/gelato-api -n "$APP_NS" --timeout=300s ;;
  local-build) docker build -t gelato-api:local . ;;
  local-apply) kubectl apply -k k8s/overlays/local ;;
  help|--help|-h) usage ;;
  *) echo "Unknown command: $1" >&2; usage; exit 1 ;;
esac
