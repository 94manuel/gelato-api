# ArgoCD - gelato-api

Aplica esta aplicación desde la raíz del repositorio que contiene `gelato-api/` y `gelato-web/`:

```bash
kubectl apply -f gelato-api/argocd/application.yaml
```

La ruta GitOps configurada es:

```txt
gelato-api/k8s/overlays/prod
```
