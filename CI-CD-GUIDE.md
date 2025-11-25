# 🚀 CI/CD con GitHub Actions + AWS ECR

Esta guía te ayudará a configurar un pipeline completo de CI/CD para desplegar automáticamente tu aplicación en AWS EC2 usando GitHub Actions y Amazon ECR.

---

## 📋 Tabla de Contenidos

1. [Arquitectura del Pipeline](#arquitectura-del-pipeline)
2. [Requisitos Previos](#requisitos-previos)
3. [Configuración Paso a Paso](#configuración-paso-a-paso)
4. [Uso del Pipeline](#uso-del-pipeline)
5. [Troubleshooting](#troubleshooting)

---

## 🏗️ Arquitectura del Pipeline

```
┌─────────────┐      ┌──────────────┐      ┌─────────┐      ┌─────────┐
│   GitHub    │─────▶│GitHub Actions│─────▶│   ECR   │─────▶│   EC2   │
│  (git push) │      │   (CI/CD)    │      │(Images) │      │ (Deploy)│
└─────────────┘      └──────────────┘      └─────────┘      └─────────┘
```

### Flujo de Trabajo:

1. **Developer** hace `git push` a la rama `main`
2. **GitHub Actions** se activa automáticamente
3. **Build**: Construye imágenes Docker del frontend y backend
4. **Push**: Sube las imágenes a Amazon ECR
5. **Deploy**: Se conecta a EC2 vía SSH y actualiza los contenedores
6. **Verify**: Verifica que el despliegue fue exitoso

---

## 📋 Requisitos Previos

### 1. AWS Account
- Cuenta de AWS activa
- AWS CLI instalado y configurado localmente

### 2. EC2 Instance
- Instancia EC2 corriendo (Amazon Linux 2 o similar)
- Docker y Docker Compose instalados
- SSH habilitado

### 3. GitHub Repository
- Repositorio con tu código
- Permisos de administrador para configurar secrets

---

## 🔧 Configuración Paso a Paso

### Paso 1: Crear Repositorios ECR en AWS

Ejecuta el script de configuración:

```bash
# Desde tu máquina local
cd dark-trifid
chmod +x scripts/setup-ecr.sh
./scripts/setup-ecr.sh
```

Este script:
- ✅ Crea 2 repositorios en ECR (frontend y backend)
- ✅ Configura políticas de lifecycle (mantiene últimas 10 imágenes)
- ✅ Habilita escaneo de seguridad automático

**Output esperado:**
```
Registry: 123456789.dkr.ecr.us-east-1.amazonaws.com
Frontend: 123456789.dkr.ecr.us-east-1.amazonaws.com/dark-trifid-frontend
Backend:  123456789.dkr.ecr.us-east-1.amazonaws.com/dark-trifid-backend
```

---

### Paso 2: Configurar Secretos en GitHub

Ve a tu repositorio en GitHub: **Settings > Secrets and variables > Actions > New repository secret**

Crea los siguientes secretos:

#### 1. `AWS_ACCESS_KEY_ID`
```
Tu AWS Access Key ID
```
**Cómo obtenerlo:**
```bash
aws configure get aws_access_key_id
```
O créalo en: AWS Console > IAM > Users > Security credentials > Create access key

#### 2. `AWS_SECRET_ACCESS_KEY`
```
Tu AWS Secret Access Key
```
**Nota:** Solo se muestra al crear el access key. Guárdalo de forma segura.

#### 3. `EC2_HOST`
```
3.18.230.112
```
La IP pública de tu instancia EC2.

#### 4. `EC2_USER`
```
ec2-user
```
Usuario SSH (generalmente `ec2-user` en Amazon Linux 2).

#### 5. `EC2_SSH_KEY`
```
-----BEGIN RSA PRIVATE KEY-----
MIIEpAIBAAKCAQEA...
(contenido completo de tu archivo .pem)
...
-----END RSA PRIVATE KEY-----
```

**Cómo obtenerlo:**
```bash
# Windows
type tu-key.pem

# Linux/Mac
cat tu-key.pem
```

**⚠️ IMPORTANTE:** Copia TODO el contenido, incluyendo las líneas BEGIN y END.

---

### Paso 3: Configurar EC2 para usar ECR

Conéctate a tu EC2 y ejecuta:

```bash
# 1. Conectarse a EC2
ssh -i tu-key.pem ec2-user@TU-IP-PUBLICA

# 2. Ir al proyecto
cd dark-trifid

# 3. Actualizar código
git pull origin main

# 4. Ejecutar script de configuración
chmod +x scripts/setup-ec2-for-ecr.sh
./scripts/setup-ec2-for-ecr.sh
```

Este script:
- ✅ Instala/configura AWS CLI en EC2
- ✅ Autentica Docker con ECR
- ✅ Crea archivo `.env` con configuración
- ✅ Configura docker-compose para usar imágenes de ECR

---

### Paso 4: Configurar Permisos IAM (Importante)

Tu usuario de AWS necesita estos permisos:

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "ecr:GetAuthorizationToken",
        "ecr:BatchCheckLayerAvailability",
        "ecr:GetDownloadUrlForLayer",
        "ecr:BatchGetImage",
        "ecr:PutImage",
        "ecr:InitiateLayerUpload",
        "ecr:UploadLayerPart",
        "ecr:CompleteLayerUpload"
      ],
      "Resource": "*"
    }
  ]
}
```

**Cómo aplicarlo:**
1. AWS Console > IAM > Users > Tu usuario
2. Add permissions > Attach policies directly
3. Busca y selecciona: `AmazonEC2ContainerRegistryPowerUser`

---

### Paso 5: Primer Despliegue Manual (Opcional pero Recomendado)

Antes de usar GitHub Actions, prueba el proceso manualmente:

```bash
# Desde tu máquina local
chmod +x scripts/build-and-push.sh
./scripts/build-and-push.sh v1.0
```

Luego en EC2:
```bash
cd ~/dark-trifid
sudo docker compose -f docker-compose.prod.yml pull
sudo docker compose -f docker-compose.prod.yml up -d
```

Si esto funciona, ¡el pipeline automático también funcionará! ✅

---

## 🚀 Uso del Pipeline

### Despliegue Automático

Simplemente haz push a la rama `main`:

```bash
git add .
git commit -m "Update application"
git push origin main
```

**GitHub Actions automáticamente:**
1. ✅ Construye las imágenes Docker
2. ✅ Las sube a ECR
3. ✅ Se conecta a EC2
4. ✅ Actualiza los contenedores
5. ✅ Verifica el despliegue

### Despliegue Manual desde GitHub

1. Ve a tu repositorio en GitHub
2. Click en **Actions**
3. Selecciona **Deploy to AWS EC2**
4. Click en **Run workflow**
5. Selecciona la rama `main`
6. Click en **Run workflow**

---

## 📊 Monitoreo del Pipeline

### Ver el progreso en GitHub

1. Ve a **Actions** en tu repositorio
2. Click en el workflow en ejecución
3. Verás cada paso en tiempo real

### Logs disponibles:

- ✅ Build Frontend
- ✅ Build Backend
- ✅ Push to ECR
- ✅ Deploy to EC2
- ✅ Verification

### Ver logs en EC2

```bash
# Conectarse a EC2
ssh -i tu-key.pem ec2-user@TU-IP

# Ver logs de contenedores
cd ~/dark-trifid
sudo docker compose logs -f

# Ver logs específicos
sudo docker compose logs -f frontend
sudo docker compose logs -f backend
```

---

## 🐛 Troubleshooting

### Error: "Unable to locate credentials"

**Problema:** GitHub Actions no puede acceder a AWS.

**Solución:**
1. Verifica que los secretos `AWS_ACCESS_KEY_ID` y `AWS_SECRET_ACCESS_KEY` estén configurados
2. Asegúrate de que no tengan espacios al inicio/final
3. Verifica que el usuario IAM tenga permisos de ECR

---

### Error: "Permission denied (publickey)"

**Problema:** GitHub Actions no puede conectarse a EC2.

**Solución:**
1. Verifica que `EC2_SSH_KEY` contenga TODO el contenido del archivo .pem
2. Incluye las líneas `-----BEGIN RSA PRIVATE KEY-----` y `-----END RSA PRIVATE KEY-----`
3. Verifica que `EC2_HOST` sea la IP pública correcta
4. Asegúrate de que el Security Group permita SSH desde cualquier IP (0.0.0.0/0)

---

### Error: "no basic auth credentials"

**Problema:** EC2 no puede autenticarse con ECR.

**Solución:**
```bash
# En EC2, ejecuta:
aws ecr get-login-password --region us-east-1 | sudo docker login --username AWS --password-stdin $(aws sts get-caller-identity --query Account --output text).dkr.ecr.us-east-1.amazonaws.com
```

---

### Error: "repository does not exist"

**Problema:** Los repositorios ECR no existen.

**Solución:**
```bash
# Ejecuta el script de setup:
./scripts/setup-ecr.sh
```

---

### Las imágenes se construyen pero no se despliegan

**Problema:** El paso de deploy falla.

**Solución:**
1. Verifica que AWS CLI esté instalado en EC2:
   ```bash
   aws --version
   ```
2. Verifica que docker-compose.prod.yml exista:
   ```bash
   ls -la ~/dark-trifid/docker-compose.prod.yml
   ```
3. Verifica permisos:
   ```bash
   sudo usermod -aG docker ec2-user
   newgrp docker
   ```

---

## 📁 Archivos del Pipeline

| Archivo | Descripción |
|---------|-------------|
| `.github/workflows/deploy.yml` | Workflow principal de GitHub Actions |
| `docker-compose.prod.yml` | Docker Compose para producción (usa ECR) |
| `scripts/setup-ecr.sh` | Crea repositorios ECR |
| `scripts/setup-ec2-for-ecr.sh` | Configura EC2 para usar ECR |
| `scripts/build-and-push.sh` | Build y push manual a ECR |

---

## 🎯 Mejores Prácticas

### 1. Versionado de Imágenes

El pipeline usa el SHA del commit como tag:
```
dark-trifid-frontend:abc123def456
dark-trifid-frontend:latest
```

### 2. Rollback Rápido

Si algo falla, puedes volver a una versión anterior:

```bash
# En EC2
cd ~/dark-trifid
export ECR_REGISTRY="123456789.dkr.ecr.us-east-1.amazonaws.com"

# Cambiar a una versión específica
sudo docker pull $ECR_REGISTRY/dark-trifid-frontend:VERSION_ANTERIOR
sudo docker compose up -d
```

### 3. Ambientes Separados

Puedes crear workflows diferentes para staging y production:

```yaml
# .github/workflows/deploy-staging.yml
on:
  push:
    branches:
      - develop

# .github/workflows/deploy-production.yml
on:
  push:
    branches:
      - main
```

### 4. Notificaciones

Agrega notificaciones de Slack o email al final del workflow:

```yaml
- name: Notify Slack
  if: success()
  uses: slackapi/slack-github-action@v1
  with:
    webhook-url: ${{ secrets.SLACK_WEBHOOK }}
    payload: |
      {
        "text": "✅ Deployment successful!"
      }
```

---

## 🔐 Seguridad

### Secretos
- ✅ Nunca commits secretos en el código
- ✅ Usa GitHub Secrets para información sensible
- ✅ Rota las access keys periódicamente

### ECR
- ✅ Escaneo de vulnerabilidades habilitado
- ✅ Encriptación AES256 habilitada
- ✅ Lifecycle policy para limpiar imágenes antiguas

### EC2
- ✅ Restringe SSH a IPs específicas cuando sea posible
- ✅ Usa IAM roles en lugar de access keys cuando sea posible
- ✅ Mantén el sistema actualizado

---

## 📚 Recursos Adicionales

- [GitHub Actions Documentation](https://docs.github.com/en/actions)
- [AWS ECR Documentation](https://docs.aws.amazon.com/ecr/)
- [Docker Best Practices](https://docs.docker.com/develop/dev-best-practices/)

---

## ✅ Checklist de Configuración

- [ ] Repositorios ECR creados
- [ ] Secretos de GitHub configurados (5 secretos)
- [ ] EC2 configurado para usar ECR
- [ ] Permisos IAM correctos
- [ ] Primer despliegue manual exitoso
- [ ] Pipeline automático probado
- [ ] Logs verificados
- [ ] Aplicación accesible

---

**¿Necesitas ayuda?** Abre un issue en GitHub o consulta la documentación de AWS.

**Última actualización:** 2025-11-24
