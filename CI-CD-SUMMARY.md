# 🚀 Pipeline CI/CD - Resumen Ejecutivo

## ✅ ¿Qué se ha creado?

Se ha configurado un **pipeline completo de CI/CD** para automatizar el despliegue de tu aplicación en AWS EC2 usando GitHub Actions y Amazon ECR.

---

## 📦 Archivos Creados

### 1. GitHub Actions Workflow
- **`.github/workflows/deploy.yml`**
  - Pipeline automatizado que se ejecuta en cada push a `main`
  - Construye imágenes Docker
  - Sube a Amazon ECR
  - Despliega automáticamente en EC2

### 2. Docker Compose para Producción
- **`docker-compose.prod.yml`**
  - Usa imágenes de ECR en lugar de build local
  - Configuración optimizada para producción
  - Restart policies configuradas

### 3. Scripts de Automatización
- **`scripts/setup-ecr.sh`**
  - Crea repositorios en Amazon ECR
  - Configura políticas de lifecycle
  - Habilita escaneo de seguridad

- **`scripts/setup-ec2-for-ecr.sh`**
  - Configura EC2 para usar ECR
  - Instala AWS CLI
  - Autentica Docker con ECR

- **`scripts/build-and-push.sh`**
  - Build y push manual a ECR
  - Útil para testing

### 4. Documentación
- **`CI-CD-GUIDE.md`**
  - Guía completa paso a paso
  - Configuración de secretos
  - Troubleshooting
  - Mejores prácticas

---

## 🎯 Flujo de Trabajo Automatizado

```
┌──────────────┐
│ Developer    │
│ git push     │
└──────┬───────┘
       │
       ▼
┌──────────────────┐
│ GitHub Actions   │
│ 1. Build images  │
│ 2. Push to ECR   │
│ 3. Deploy to EC2 │
└──────┬───────────┘
       │
       ▼
┌──────────────┐
│ EC2 Instance │
│ App Running  │
└──────────────┘
```

---

## 🔧 Configuración Requerida (5 pasos)

### Paso 1: Crear Repositorios ECR

```bash
chmod +x scripts/setup-ecr.sh
./scripts/setup-ecr.sh
```

### Paso 2: Configurar Secretos en GitHub

Ve a: **GitHub Repo > Settings > Secrets > Actions**

Crear 5 secretos:

| Secret | Valor | Cómo obtenerlo |
|--------|-------|----------------|
| `AWS_ACCESS_KEY_ID` | Tu Access Key | AWS Console > IAM > Users > Security credentials |
| `AWS_SECRET_ACCESS_KEY` | Tu Secret Key | Se muestra al crear Access Key |
| `EC2_HOST` | IP de tu EC2 | `3.18.230.112` |
| `EC2_USER` | Usuario SSH | `ec2-user` |
| `EC2_SSH_KEY` | Contenido .pem | `cat tu-key.pem` (todo el contenido) |

### Paso 3: Configurar EC2

```bash
# Conectarse a EC2
ssh -i tu-key.pem ec2-user@TU-IP

# Ir al proyecto
cd dark-trifid

# Actualizar código
git pull origin main

# Ejecutar configuración
chmod +x scripts/setup-ec2-for-ecr.sh
./scripts/setup-ec2-for-ecr.sh
```

### Paso 4: Primer Despliegue Manual (Opcional)

```bash
# Desde tu máquina local
chmod +x scripts/build-and-push.sh
./scripts/build-and-push.sh v1.0
```

### Paso 5: Activar Pipeline

```bash
# Hacer cualquier cambio y push
git add .
git commit -m "Enable CI/CD pipeline"
git push origin main
```

¡El pipeline se ejecutará automáticamente! 🎉

---

## 🌟 Beneficios

### Antes (Manual)
```bash
# 1. Conectarse a EC2
ssh -i key.pem ec2-user@IP

# 2. Actualizar código
cd dark-trifid
git pull

# 3. Reconstruir
sudo docker compose down
sudo docker compose up --build -d
```

### Ahora (Automatizado)
```bash
git push origin main
# ✅ ¡Listo! Todo se despliega automáticamente
```

---

## 📊 Comparación

| Aspecto | Antes | Ahora |
|---------|-------|-------|
| **Despliegue** | Manual (5-10 min) | Automático (2-3 min) |
| **Errores** | Posibles errores humanos | Proceso consistente |
| **Rollback** | Difícil | Fácil (cambiar tag de imagen) |
| **Versionado** | Solo código | Código + Imágenes Docker |
| **Seguridad** | Código en servidor | Solo imágenes |
| **Escalabilidad** | Limitada | Alta |

---

## 🎬 Cómo Usar

### Despliegue Automático (Recomendado)

```bash
# 1. Hacer cambios en tu código
vim frontend/index.html

# 2. Commit y push
git add .
git commit -m "Update homepage"
git push origin main

# 3. ¡Listo! GitHub Actions se encarga del resto
```

### Despliegue Manual desde GitHub

1. Ve a tu repo en GitHub
2. Click en **Actions**
3. Selecciona **Deploy to AWS EC2**
4. Click en **Run workflow**
5. Selecciona `main` branch
6. Click en **Run workflow**

---

## 📈 Monitoreo

### Ver Progreso del Pipeline

1. GitHub > Actions > Click en el workflow en ejecución
2. Verás cada paso en tiempo real:
   - ✅ Checkout code
   - ✅ Configure AWS credentials
   - ✅ Login to ECR
   - ✅ Build Frontend
   - ✅ Build Backend
   - ✅ Push to ECR
   - ✅ Deploy to EC2
   - ✅ Verify deployment

### Ver Logs en EC2

```bash
ssh -i tu-key.pem ec2-user@TU-IP
cd ~/dark-trifid
sudo docker compose logs -f
```

---

## 🔐 Seguridad

### Imágenes Docker
- ✅ Almacenadas en ECR privado
- ✅ Escaneo de vulnerabilidades automático
- ✅ Encriptación AES256
- ✅ Lifecycle policy (mantiene últimas 10 imágenes)

### Credenciales
- ✅ Secretos en GitHub (encriptados)
- ✅ No expuestos en código
- ✅ Acceso vía IAM roles

### Código
- ✅ No se expone en servidor
- ✅ Solo imágenes Docker compiladas
- ✅ Versionado completo

---

## 🚀 Próximos Pasos Sugeridos

### 1. Ambientes Separados
Crear workflows para staging y production:
```
.github/workflows/
├── deploy-staging.yml   # Deploy a staging
└── deploy-production.yml # Deploy a production
```

### 2. Tests Automatizados
Agregar tests antes del deploy:
```yaml
- name: Run tests
  run: |
    docker compose run backend pytest
```

### 3. Notificaciones
Agregar notificaciones de Slack/Email:
```yaml
- name: Notify Slack
  uses: slackapi/slack-github-action@v1
  with:
    webhook-url: ${{ secrets.SLACK_WEBHOOK }}
```

### 4. Migrar a ECS Fargate
Para producción seria, considera migrar a ECS Fargate (serverless).

---

## 📚 Documentación

- **Guía Completa**: [CI-CD-GUIDE.md](./CI-CD-GUIDE.md)
- **Despliegue Manual**: [DEPLOYMENT.md](./DEPLOYMENT.md)
- **Terraform**: [terraform/README.md](./terraform/README.md)

---

## ✅ Checklist de Implementación

- [ ] Repositorios ECR creados (`./scripts/setup-ecr.sh`)
- [ ] 5 secretos configurados en GitHub
- [ ] EC2 configurado para ECR (`./scripts/setup-ec2-for-ecr.sh`)
- [ ] Primer build manual exitoso (opcional)
- [ ] Push a GitHub realizado
- [ ] Pipeline ejecutado exitosamente
- [ ] Aplicación accesible en http://TU-IP
- [ ] Logs verificados

---

## 🎉 ¡Felicitaciones!

Ahora tienes un pipeline profesional de CI/CD que:

✅ **Automatiza** todo el proceso de despliegue  
✅ **Versiona** tus imágenes Docker  
✅ **Asegura** consistencia en cada despliegue  
✅ **Facilita** rollbacks rápidos  
✅ **Mejora** la seguridad  
✅ **Escala** fácilmente  

**Cada vez que hagas `git push`, tu aplicación se desplegará automáticamente en producción.** 🚀

---

**Última actualización:** 2025-11-24  
**Autor:** Luis Zapata  
**Proyecto:** Dark Trifid
