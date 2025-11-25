# 🌳 Git Flow Profesional + CI/CD

Esta guía explica el flujo de trabajo profesional con Git, Pull Requests y despliegues automatizados.

---

## 🎯 Estrategia de Branches

```
main (production)
  ↑
  │ Pull Request + Revisión
  │
develop (staging)
  ↑
  │ Pull Request + Revisión
  │
feature/nueva-funcionalidad
```

### Branches Principales:

| Branch | Propósito | Despliegue | Protección |
|--------|-----------|------------|------------|
| `main` | Producción | Automático a EC2 Production | ✅ Protegido |
| `develop` | Staging/Testing | Automático a EC2 Staging | ✅ Protegido |
| `feature/*` | Desarrollo de features | No despliega | ❌ No protegido |
| `hotfix/*` | Correcciones urgentes | No despliega | ❌ No protegido |

---

## 🔄 Flujo de Trabajo Completo

### 1. Desarrollar una Nueva Feature

```bash
# 1. Asegúrate de estar en develop actualizado
git checkout develop
git pull origin develop

# 2. Crear branch de feature
git checkout -b feature/nueva-funcionalidad

# 3. Hacer cambios
vim frontend/index.html

# 4. Commit
git add .
git commit -m "feat: add new homepage section"

# 5. Push a GitHub
git push origin feature/nueva-funcionalidad
```

### 2. Crear Pull Request

1. Ve a GitHub
2. Verás un banner: **"Compare & pull request"**
3. Click en el banner
4. **Base:** `develop` ← **Compare:** `feature/nueva-funcionalidad`
5. Escribe descripción del PR
6. Click en **"Create pull request"**

### 3. Revisión Automática (CI)

GitHub Actions ejecutará automáticamente:

✅ **Validación de código**
- Busca credenciales expuestas
- Valida docker-compose
- Verifica estructura de archivos

✅ **Validación de Terraform**
- Format check
- Terraform validate

✅ **Build Test**
- Construye imágenes Docker
- Verifica que compilen correctamente

✅ **Security Scan**
- Escanea vulnerabilidades con Trivy

**Resultado:** Comentario automático en el PR con el estado de todas las validaciones.

### 4. Code Review

- Espera revisión de compañeros
- Responde a comentarios
- Haz cambios si es necesario
- Push updates (el PR se actualiza automáticamente)

### 5. Merge a Develop

Una vez aprobado:

```bash
# Opción A: Desde GitHub
# Click en "Merge pull request" → "Confirm merge"

# Opción B: Desde terminal
git checkout develop
git merge feature/nueva-funcionalidad
git push origin develop
```

**🚀 Resultado:** Deploy automático a **Staging**

### 6. Probar en Staging

```
http://STAGING-EC2-IP
```

- Verifica que todo funcione
- Haz pruebas de QA
- Si hay problemas, crea un hotfix

### 7. Promover a Production

Cuando staging esté OK:

```bash
# 1. Crear PR de develop a main
git checkout develop
git pull origin develop

# 2. Crear PR en GitHub
# Base: main ← Compare: develop
```

**Revisión final** → **Merge**

**🚀 Resultado:** Deploy automático a **Production**

---

## 📊 Workflows Automatizados

### Workflow 1: PR Checks (`.github/workflows/pr-checks.yml`)

**Trigger:** Pull Request abierto/actualizado

**Qué hace:**
- ✅ Valida código
- ✅ Valida Terraform
- ✅ Build test de Docker
- ✅ Security scan
- ✅ Comenta en el PR con resultados

**No despliega nada**

---

### Workflow 2: Deploy to Staging (`.github/workflows/deploy-staging.yml`)

**Trigger:** Push/Merge a `develop`

**Qué hace:**
- ✅ Build imágenes Docker
- ✅ Push a ECR con tag `staging`
- ✅ Deploy a EC2 Staging

**Despliega a:** Staging Environment

---

### Workflow 3: Deploy to Production (`.github/workflows/deploy.yml`)

**Trigger:** Push/Merge a `main`

**Qué hace:**
- ✅ Build imágenes Docker
- ✅ Push a ECR con tag `latest` y SHA
- ✅ Deploy a EC2 Production

**Despliega a:** Production Environment

---

### Workflow 4: Infrastructure (`.github/workflows/infrastructure.yml`)

**Trigger:** Manual

**Qué hace:**
- ✅ Terraform plan/apply/destroy
- ✅ Crea/modifica infraestructura

**No despliega aplicación**

---

### Workflow 5: Full Stack (`.github/workflows/full-stack.yml`)

**Trigger:** Manual

**Qué hace:**
- ✅ Crea infraestructura con Terraform
- ✅ Despliega aplicación

**Uso:** Primera vez o recrear todo

---

## 🔐 Configuración de Environments en GitHub

### Crear Environments:

1. GitHub > Settings > Environments
2. Click "New environment"

#### Environment: `staging`
- **Deployment branches:** `develop`
- **Secrets:**
  - `STAGING_EC2_HOST` = IP del servidor de staging

#### Environment: `production`
- **Deployment branches:** `main`
- **Required reviewers:** Agregar revisores (opcional)
- **Wait timer:** 5 minutos (opcional)
- **Secrets:**
  - `EC2_HOST` = IP del servidor de producción

---

## 🎯 Convenciones de Commits

Usa [Conventional Commits](https://www.conventionalcommits.org/):

```bash
# Features
git commit -m "feat: add user authentication"

# Bug fixes
git commit -m "fix: resolve login redirect issue"

# Documentation
git commit -m "docs: update README with new setup instructions"

# Refactoring
git commit -m "refactor: simplify database queries"

# Tests
git commit -m "test: add unit tests for auth service"

# Chores
git commit -m "chore: update dependencies"
```

---

## 🚨 Hotfixes (Correcciones Urgentes)

Para bugs críticos en producción:

```bash
# 1. Crear hotfix desde main
git checkout main
git pull origin main
git checkout -b hotfix/critical-bug

# 2. Fix el bug
vim backend/api.py

# 3. Commit
git commit -m "fix: resolve critical API error"

# 4. Push
git push origin hotfix/critical-bug

# 5. Crear PR a main (bypass staging)
# Base: main ← Compare: hotfix/critical-bug

# 6. Merge (deploy inmediato a production)

# 7. Backport a develop
git checkout develop
git merge hotfix/critical-bug
git push origin develop
```

---

## 📋 Checklist de PR

Antes de crear un PR, verifica:

- [ ] Código funciona localmente
- [ ] Docker build exitoso
- [ ] No hay credenciales en el código
- [ ] Commits siguen convenciones
- [ ] Branch actualizado con base branch
- [ ] Descripción clara del PR
- [ ] Screenshots si hay cambios visuales

---

## 🎬 Ejemplo Completo

### Escenario: Agregar nueva página "About"

```bash
# Día 1: Desarrollo
git checkout develop
git pull origin develop
git checkout -b feature/about-page

# Crear archivos
touch frontend/about.html
vim frontend/about.html

# Commit
git add .
git commit -m "feat: add about page with company info"
git push origin feature/about-page

# Crear PR en GitHub
# Base: develop ← Compare: feature/about-page

# GitHub Actions ejecuta checks automáticamente
# ✅ All checks passed

# Día 2: Code Review
# Compañero revisa y aprueba

# Merge a develop
# Click "Merge pull request"

# 🚀 Deploy automático a Staging

# Día 3: Testing en Staging
# QA team prueba en http://staging-ip/about.html
# ✅ Todo OK

# Crear PR a production
# Base: main ← Compare: develop

# Revisión final y merge

# 🚀 Deploy automático a Production

# ✅ Feature en producción!
```

---

## 🔄 Sincronización de Branches

### Mantener develop actualizado con main:

```bash
git checkout develop
git pull origin develop
git merge main
git push origin develop
```

### Actualizar feature branch con develop:

```bash
git checkout feature/mi-feature
git pull origin develop
git push origin feature/mi-feature
```

---

## 📊 Diagrama de Flujo Visual

```
Developer
    │
    ├─ Crea feature branch
    │
    ├─ Hace cambios
    │
    ├─ Push a GitHub
    │
    ▼
Pull Request a develop
    │
    ├─ CI Checks (automático)
    │  ├─ Code validation
    │  ├─ Terraform validation
    │  ├─ Docker build test
    │  └─ Security scan
    │
    ├─ Code Review (manual)
    │
    ├─ Aprobación
    │
    ▼
Merge a develop
    │
    ▼
Deploy a Staging (automático)
    │
    ├─ Build images
    ├─ Push to ECR
    └─ Deploy to EC2 Staging
    │
    ├─ Testing en Staging
    │
    ▼
Pull Request a main
    │
    ├─ Revisión final
    │
    ▼
Merge a main
    │
    ▼
Deploy a Production (automático)
    │
    ├─ Build images
    ├─ Push to ECR
    └─ Deploy to EC2 Production
    │
    ▼
✅ En Producción
```

---

## 🎓 Mejores Prácticas

### ✅ DO:
- Crear PRs pequeños y enfocados
- Escribir descripciones claras
- Responder a comentarios de revisión
- Probar en staging antes de production
- Usar conventional commits
- Mantener branches actualizados

### ❌ DON'T:
- Push directo a main o develop
- PRs gigantes con muchos cambios
- Ignorar checks de CI
- Merge sin revisión
- Commits con mensajes vagos ("fix", "update")
- Dejar branches obsoletos

---

## 🚀 Comandos Útiles

```bash
# Ver branches
git branch -a

# Eliminar branch local
git branch -d feature/mi-feature

# Eliminar branch remoto
git push origin --delete feature/mi-feature

# Ver estado de PR
gh pr status  # Requiere GitHub CLI

# Ver logs de deploy
# GitHub > Actions > Click en workflow

# Rollback (si algo falla)
git revert HEAD
git push origin main
```

---

## ✅ Resumen

**Flujo Normal:**
```
feature → PR → develop → Staging → PR → main → Production
```

**Hotfix:**
```
hotfix → PR → main → Production
       └─────→ develop
```

**Infraestructura:**
```
Manual workflow → Terraform apply
```

---

**¿Preguntas?** Consulta la documentación de GitHub Actions o abre un issue.

**Última actualización:** 2025-11-24
