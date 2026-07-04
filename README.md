# Gelato API

Proyecto independiente del backend NestJS para Gelato. Incluye su propio Dockerfile, CI, Kubernetes, ArgoCD y scripts.

## Desarrollo local

```bash
npm install
npm run build:core
npm run prisma:generate
npm run dev
```

API local:

```txt
http://localhost:3001
http://localhost:3001/api/docs
```

## Producción

La imagen se publica como:

```txt
ghcr.io/94manuel/gelato-api:<tag>
```

El deployment usa el namespace `gelato` y espera el secreto:

```txt
gelato-postgres-secret / DATABASE_URL
```

Crear secreto en VPS:

```bash
export DATABASE_URL='postgresql://gelato_user:CLAVE@postgres.database.svc.cluster.local:5432/gelato?schema=public'
./scripts/deploy.sh db-secret
```

Crear secret de GHCR:

```bash
export GITHUB_USER=94manuel
export GHCR_TOKEN='TOKEN_READ_PACKAGES'
./scripts/deploy.sh ghcr-secret
```

Aplicar ArgoCD:

```bash
./scripts/deploy.sh apply-argocd
./scripts/deploy.sh sync
```

## CI

El workflow está en:

```txt
.github/workflows/gelato-api-ci.yml
```

Si este proyecto vive dentro de un monorepo con carpetas `gelato-api/` y `gelato-web/`, copia el workflow al `.github/workflows/` del root del repositorio para que GitHub Actions lo ejecute.
