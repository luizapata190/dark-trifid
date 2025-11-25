# 🚀 Guía Completa: Infraestructura + CI/CD Automatizado

Esta guía te muestra cómo usar el sistema profesional completo donde **Terraform gestiona la infraestructura** y **GitHub Actions automatiza el despliegue**.

---

## 🎯 Arquitectura del Sistema

```
┌─────────────────────────────────────────────────────────┐
│  INFRAESTRUCTURA (Terraform via GitHub Actions)         │
│  Ejecutar: Una vez o cuando cambies infraestructura     │
├─────────────────────────────────────────────────────────┤
│                                                          │
│  GitHub Actions ejecuta Terraform                        │
│  ├── Crea VPC & Security Groups                         │
│  ├── Crea EC2 Instance                                  │
│  ├── Configura IAM Roles (acceso a ECR)                 │
│  └── Ejecuta User Data (instala Docker, Git, AWS CLI)   │
│                                                          │
│  Output: IP pública del servidor                         │
└─────────────────────────────────────────────────────────┘
                        ↓
┌─────────────────────────────────────────────────────────┐
│  DESPLIEGUE DE APLICACIÓN (GitHub Actions)              │
│  Ejecutar: Automáticamente en cada git push             │
├─────────────────────────────────────────────────────────┤
│                                                          │
│  GitHub Actions automáticamente:                         │
│  ├── Build Docker images (Frontend + Backend)           │
│  ├── Push images to Amazon ECR                          │
│  ├── SSH to EC2                                         │
│  ├── Pull images from ECR                               │
│  └── Deploy with docker-compose                         │
│                                                          │
└─────────────────────────────────────────────────────────┘
```

---

## 📦 Archivos Creados

### Workflows de GitHub Actions:
1. **`.github/workflows/infrastructure.yml`** - Gestión de infraestructura (plan/apply/destroy)
2. **`.github/workflows/full-stack.yml`** - Pipeline completo (crear + desplegar)
3. **`.github/workflows/deploy.yml`** - Solo despliegue de aplicación

### Terraform:
4. **`terraform/main.tf`** - Configuración de infraestructura mejorada
5. **`terraform/user-data.sh`** - Script de inicialización de EC2

---

## 🔧 Configuración Inicial (Una Sola Vez)

### Paso 1: Crear Repositorios ECR

```bash
# Desde tu máquina local
cd d:\Antigravity\dark-trifid
chmod +x scripts/setup-ecr.sh
./scripts/setup-ecr.sh
```

### Paso 2: Configurar Secretos en GitHub

Ve a: `https://github.com/luizapata190/dark-trifid/settings/secrets/actions`

Crea **SOLO 2 secretos** (los demás son opcionales):

| Secret | Valor | ¿Obligatorio? |
|--------|-------|---------------|
| `AWS_ACCESS_KEY_ID` | Tu AWS Access Key | ✅ SÍ |
| `AWS_SECRET_ACCESS_KEY` | Tu AWS Secret Key | ✅ SÍ |
| `EC2_HOST` | IP de EC2 | ❌ NO (se obtiene de Terraform) |
| `EC2_USER` | `ec2-user` | ❌ NO (opcional para deploy manual) |
| `EC2_SSH_KEY` | Contenido .pem | ❌ NO (opcional para SSH) |

**Nota:** Con el nuevo sistema, `EC2_HOST` se obtiene automáticamente de Terraform.

### Paso 3: Subir Código a GitHub

```bash
git add .
git commit -m "Add Terraform + GitHub Actions infrastructure automation"
git push origin main
```

---

## 🚀 Uso del Sistema

### Opción 1: Crear TODO Desde Cero (Recomendado)

**Usa el workflow `Full Stack`:**

1. Ve a GitHub > Actions
2. Selecciona **"Full Stack - Infrastructure + Deployment"**
3. Click en **"Run workflow"**
4. Selecciona: **`create-and-deploy`**
5. Click en **"Run workflow"**

**Qué hace:**
- ✅ Crea la infraestructura EC2 con Terraform
- ✅ Espera 90 segundos a que EC2 esté listo
- ✅ Construye imágenes Docker
- ✅ Sube a ECR
- ✅ Despliega en EC2
- ✅ Te da la IP pública al final

**Tiempo:** ~5-7 minutos

---

### Opción 2: Solo Gestionar Infraestructura

**Usa el workflow `Manage Infrastructure`:**

#### A. Ver Plan (sin crear nada)
1. GitHub > Actions > **"Manage Infrastructure with Terraform"**
2. Run workflow > Action: **`plan`**
3. Revisa qué se creará

#### B. Crear Infraestructura
1. GitHub > Actions > **"Manage Infrastructure with Terraform"**
2. Run workflow > Action: **`apply`**
3. Espera a que termine
4. Copia la IP pública del output

#### C. Destruir Infraestructura
1. GitHub > Actions > **"Manage Infrastructure with Terraform"**
2. Run workflow > Action: **`destroy`**
3. Confirma

---

### Opción 3: Solo Desplegar Aplicación

**Usa el workflow `Deploy to AWS EC2`:**

**Requisito:** Ya debes tener una instancia EC2 corriendo.

1. GitHub > Actions > **"Deploy to AWS EC2"**
2. Click en **"Run workflow"**
3. O simplemente haz `git push` (se ejecuta automáticamente)

---

## 📊 Comparación de Workflows

| Workflow | Cuándo Usar | Qué Hace | Frecuencia |
|----------|-------------|----------|------------|
| **Full Stack** | Primera vez o recrear todo | Crea EC2 + Despliega app | Raramente |
| **Infrastructure** | Gestionar servidores | Solo crea/modifica/destruye EC2 | Ocasionalmente |
| **Deploy** | Actualizar código | Solo despliega nueva versión | Constantemente |

---

## 🎬 Flujo de Trabajo Típico

### Primera Vez (Setup Inicial):

```bash
# 1. Crear repositorios ECR
./scripts/setup-ecr.sh

# 2. Configurar secretos en GitHub
# (AWS_ACCESS_KEY_ID y AWS_SECRET_ACCESS_KEY)

# 3. Subir código
git push origin main

# 4. Ejecutar Full Stack workflow
# GitHub > Actions > Full Stack > create-and-deploy
```

### Desarrollo Diario:

```bash
# 1. Hacer cambios en tu código
vim frontend/index.html

# 2. Commit y push
git add .
git commit -m "Update homepage"
git push origin main

# 3. ¡Listo! Se despliega automáticamente
```

### Cuando Necesites Cambiar Infraestructura:

```bash
# 1. Editar terraform/main.tf
vim terraform/main.tf

# 2. Commit y push
git push origin main

# 3. Ejecutar Infrastructure workflow
# GitHub > Actions > Infrastructure > apply
```

---

## 🔍 Monitoreo y Verificación

### Ver Progreso en GitHub

1. GitHub > Actions
2. Click en el workflow en ejecución
3. Verás cada paso en tiempo real

### Obtener IP de la Instancia

**Después de ejecutar el workflow:**
1. Ve al workflow completado
2. Busca en el Summary
3. Verás: "Public IP: `X.X.X.X`"

**O desde terminal:**
```bash
cd terraform
terraform output public_ip
```

### Verificar la Aplicación

```bash
# Acceder a la app
http://IP-PUBLICA

# Ver logs en EC2 (si configuraste SSH)
ssh -i tu-key.pem ec2-user@IP-PUBLICA
cd ~/dark-trifid
sudo docker compose logs -f
```

---

## 🎯 Ventajas del Nuevo Sistema

### Antes (Manual):
```
1. Crear EC2 manualmente en AWS Console
2. SSH a EC2
3. Instalar Docker, Git, etc.
4. Clonar proyecto
5. Configurar todo
6. Desplegar
```
⏱️ **Tiempo:** 30-45 minutos

### Ahora (Automatizado):
```
1. Click en "Run workflow"
2. Seleccionar "create-and-deploy"
3. ¡Listo!
```
⏱️ **Tiempo:** 5-7 minutos (sin intervención)

---

## 🔐 Seguridad Mejorada

### IAM Roles
- ✅ EC2 tiene rol IAM para acceder a ECR
- ✅ No necesitas credenciales en el servidor
- ✅ Acceso controlado por políticas

### Secrets
- ✅ Solo necesitas 2 secretos (AWS keys)
- ✅ EC2_HOST se obtiene automáticamente
- ✅ SSH key es opcional

### Infraestructura
- ✅ Security Groups configurados automáticamente
- ✅ Volúmenes encriptados
- ✅ Todo versionado en Git

---

## 🐛 Troubleshooting

### Error: "No valid credential sources"
**Solución:** Verifica que `AWS_ACCESS_KEY_ID` y `AWS_SECRET_ACCESS_KEY` estén configurados en GitHub Secrets.

### Error: "Error creating Security Group"
**Causa:** Ya existe un Security Group con ese nombre.
**Solución:** 
```bash
# Opción 1: Destruir infraestructura anterior
# GitHub > Actions > Infrastructure > destroy

# Opción 2: Cambiar nombre en terraform/terraform.tfvars
project_name = "dark-trifid-v2"
```

### La aplicación no responde
**Solución:**
1. Espera 2-3 minutos después del despliegue
2. Verifica que el workflow terminó exitosamente
3. Verifica Security Group (puerto 80 abierto)

### No puedo conectarme por SSH
**Causa:** No configuraste `key_name` en Terraform.
**Solución:** 
```bash
# Editar terraform/terraform.tfvars
key_name = "tu-key-pair"

# Re-ejecutar Infrastructure workflow
```

---

## 📚 Comandos Útiles

### Terraform Local (Opcional)

```bash
cd terraform

# Ver plan
terraform plan

# Aplicar cambios
terraform apply

# Ver outputs
terraform output

# Destruir todo
terraform destroy
```

### Ver Estado de la Infraestructura

```bash
# Listar recursos
terraform state list

# Ver detalles de EC2
terraform state show aws_instance.dark_trifid
```

---

## 🎓 Próximos Pasos

### 1. Múltiples Ambientes
Crea ambientes separados (staging, production):
```
terraform/
├── environments/
│   ├── staging/
│   │   └── terraform.tfvars
│   └── production/
│       └── terraform.tfvars
```

### 2. Remote State
Guarda el estado de Terraform en S3:
```hcl
terraform {
  backend "s3" {
    bucket = "mi-terraform-state"
    key    = "dark-trifid/terraform.tfstate"
    region = "us-east-1"
  }
}
```

### 3. Migrar a ECS Fargate
Para producción seria, considera ECS Fargate (serverless).

---

## ✅ Checklist

- [ ] Repositorios ECR creados
- [ ] Secretos AWS configurados en GitHub
- [ ] Código subido a GitHub
- [ ] Workflow "Full Stack" ejecutado exitosamente
- [ ] IP pública obtenida
- [ ] Aplicación accesible en http://IP
- [ ] Workflow "Deploy" probado con un cambio

---

## 🎉 ¡Felicitaciones!

Ahora tienes un sistema profesional donde:
- ✅ **Terraform** gestiona toda tu infraestructura
- ✅ **GitHub Actions** automatiza todo el proceso
- ✅ **Un click** crea y despliega todo
- ✅ **Git push** actualiza la aplicación automáticamente
- ✅ **Versionado completo** de infraestructura y código

**¿Necesitas ayuda?** Consulta los otros archivos de documentación o abre un issue en GitHub.

---

**Última actualización:** 2025-11-24  
**Autor:** Luis Zapata  
**Proyecto:** Dark Trifid
