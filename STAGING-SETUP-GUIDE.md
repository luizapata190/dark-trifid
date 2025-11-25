# 🎭 Guía de Implementación de Staging

## 🎯 ¿Qué es Staging?

**Staging** es un ambiente de pruebas que replica producción antes de desplegar a usuarios reales.

```
Desarrollo → Staging → Production
   (Local)   (Pruebas)  (Usuarios)
```

---

## 📊 Opciones de Implementación

### Opción 1: Staging en EC2 Separado (Profesional) ⭐

**Arquitectura:**
```
AWS Account
├── EC2 Staging
│   ├── Tag: dark-trifid-staging
│   ├── Rama: develop
│   ├── IP: Variable (sin Elastic IP)
│   └── Costo: ~$8/mes
│
└── EC2 Production
    ├── Tag: dark-trifid
    ├── Rama: main
    ├── Elastic IP: Fija
    └── Costo: ~$8/mes
```

**Ventajas:**
- ✅ Ambiente real de pruebas
- ✅ No afecta producción
- ✅ Pruebas de infraestructura
- ✅ Múltiples desarrolladores pueden probar

**Desventajas:**
- ❌ Costo adicional (~$8/mes)
- ❌ Más complejo de gestionar

**Cuándo usar:**
- Equipo de desarrollo
- Aplicación crítica
- Necesitas probar antes de producción

---

### Opción 2: Staging en Local (Económico) 💰

**Arquitectura:**
```
Tu PC (Docker Compose)
├── Frontend: localhost:8888
├── Backend: localhost:8000
└── Gratis

AWS (Solo Production)
└── EC2 Production
    └── Elastic IP: 34.234.152.61
```

**Ventajas:**
- ✅ Gratis
- ✅ Rápido para desarrollar
- ✅ Simple

**Desventajas:**
- ❌ No replica producción
- ❌ Solo para ti
- ❌ No pruebas infraestructura real

**Cuándo usar:**
- Desarrollador solo
- Presupuesto limitado
- Aplicación simple

---

### Opción 3: Staging On-Demand (Híbrido) 🔄

**Arquitectura:**
```
Crear EC2 Staging solo cuando necesites
├── Crear con workflow
├── Probar
├── Destruir cuando termines
└── Costo: ~$0.01/hora (solo cuando usas)
```

**Ventajas:**
- ✅ Ambiente real cuando lo necesitas
- ✅ Muy económico
- ✅ Flexible

**Desventajas:**
- ❌ Toma tiempo crear/destruir
- ❌ No siempre disponible

**Cuándo usar:**
- Pruebas ocasionales
- Presupuesto limitado
- No necesitas staging 24/7

---

## 🚀 Implementación: Opción 1 (EC2 Separado)

### Paso 1: Crear Terraform para Staging

Crea `terraform/staging.tf`:

```hcl
# Staging EC2 Instance (sin Elastic IP para ahorrar)
resource "aws_instance" "dark_trifid_staging" {
  count = var.create_staging ? 1 : 0  # Opcional

  ami           = data.aws_ami.amazon_linux_2.id
  instance_type = var.instance_type
  key_name      = var.key_name != "" ? var.key_name : null

  vpc_security_group_ids = [aws_security_group.dark_trifid_sg.id]
  iam_instance_profile   = aws_iam_instance_profile.ec2_profile.name

  user_data = file("${path.module}/user-data.sh")

  root_block_device {
    volume_size = 20
    volume_type = "gp3"
    encrypted   = true
  }

  tags = {
    Name        = "${var.project_name}-staging"
    Environment = "staging"
    ManagedBy   = "Terraform"
  }
}

# Variable para controlar si crear staging
variable "create_staging" {
  description = "Crear ambiente de staging"
  type        = bool
  default     = false  # Por defecto no crear
}

# Output de staging
output "staging_public_ip" {
  description = "IP pública de staging"
  value       = var.create_staging ? aws_instance.dark_trifid_staging[0].public_ip : "Staging not created"
}
```

### Paso 2: Actualizar Workflow de Staging

El workflow ya existe en `.github/workflows/deploy-staging.yml`. Solo necesitas:

1. **Crear el EC2 de staging:**
   ```bash
   # Editar terraform/terraform.tfvars
   create_staging = true
   
   # Ejecutar Full Stack
   # Esto creará AMBOS EC2 (production + staging)
   ```

2. **Configurar secret en GitHub:**
   ```
   STAGING_EC2_HOST = IP del EC2 staging
   ```

3. **Push a develop:**
   ```bash
   git checkout -b develop
   git push origin develop
   # Deploy automático a staging ✅
   ```

---

## 🚀 Implementación: Opción 2 (Local)

### Paso 1: Usar Docker Compose Local

Ya tienes `docker-compose.yml` para local:

```bash
# Desarrollo local
docker compose up

# Acceder
http://localhost        # Frontend
http://localhost:8000   # Backend
```

### Paso 2: Workflow de Desarrollo

```
1. Hacer cambios
2. Probar en local: docker compose up
3. Si funciona: git push origin main
4. Deploy automático a producción
```

**No necesitas workflow de staging**, solo pruebas locales.

---

## 🚀 Implementación: Opción 3 (On-Demand)

### Crear Workflow para Staging Temporal

```yaml
name: Create Temporary Staging

on:
  workflow_dispatch:
    inputs:
      action:
        description: 'Action'
        required: true
        type: choice
        options:
          - create
          - destroy

jobs:
  manage-staging:
    runs-on: ubuntu-latest
    steps:
      - name: Create Staging
        if: github.event.inputs.action == 'create'
        run: |
          # Crear EC2 temporal
          # Desplegar aplicación
          # Mostrar IP
          
      - name: Destroy Staging
        if: github.event.inputs.action == 'destroy'
        run: |
          # Destruir EC2 temporal
```

**Uso:**
```
1. Ejecutar workflow: create
2. Probar en IP temporal
3. Ejecutar workflow: destroy
4. Costo: ~$0.01 por hora de uso
```

---

## 📋 Comparación de Opciones

| Característica | EC2 Separado | Local | On-Demand |
|----------------|--------------|-------|-----------|
| **Costo/mes** | ~$8 | Gratis | ~$1-2 |
| **Replica producción** | ✅ Sí | ❌ No | ✅ Sí |
| **Disponibilidad** | 24/7 | Solo cuando trabajas | Cuando creas |
| **Setup** | Complejo | Simple | Medio |
| **Para equipo** | ✅ Sí | ❌ No | ⚠️ Limitado |
| **Recomendado para** | Empresas | Desarrollador solo | Presupuesto limitado |

---

## 🎯 Recomendación

### Para tu caso actual:

**Opción 2: Local (por ahora)**
```bash
# Desarrollo
docker compose up

# Producción
git push origin main
```

**Razones:**
- Estás aprendiendo
- Desarrollador solo
- Presupuesto limitado
- Producción ya funciona bien

### Cuando crezcas:

**Opción 1: EC2 Separado**
- Cuando tengas equipo
- Cuando la app sea crítica
- Cuando el presupuesto lo permita

---

## 🔄 Git Flow con Staging

### Con EC2 Staging:

```bash
# 1. Crear feature
git checkout -b feature/nueva-cosa

# 2. Desarrollar y probar local
docker compose up

# 3. Merge a develop
git checkout develop
git merge feature/nueva-cosa
git push origin develop
# → Deploy automático a STAGING ✅

# 4. Probar en staging
http://STAGING-IP

# 5. Si funciona, merge a main
git checkout main
git merge develop
git push origin main
# → Deploy automático a PRODUCTION ✅
```

### Sin EC2 Staging (Local):

```bash
# 1. Crear feature
git checkout -b feature/nueva-cosa

# 2. Desarrollar y probar local
docker compose up

# 3. Si funciona, merge a main
git checkout main
git merge feature/nueva-cosa
git push origin main
# → Deploy automático a PRODUCTION ✅
```

---

## 💰 Análisis de Costos

### Opción 1: EC2 Separado

```
EC2 Staging (t3.micro):     $8.50/mes
EC2 Production (t3.micro):  $8.50/mes
Elastic IP (production):    $0.00/mes (asociada)
Total:                      $17/mes
```

### Opción 2: Local

```
EC2 Production (t3.micro):  $8.50/mes
Elastic IP:                 $0.00/mes
Total:                      $8.50/mes
```

### Opción 3: On-Demand

```
EC2 Production:             $8.50/mes
EC2 Staging (10h/mes):      $0.12/mes
Total:                      $8.62/mes
```

---

## ✅ Próximos Pasos

### Si quieres implementar Staging en EC2:

1. **Dime y creo los archivos necesarios:**
   - `terraform/staging.tf`
   - Workflow actualizado
   - Scripts de gestión

2. **Configuración:**
   - Crear EC2 staging
   - Configurar secrets
   - Probar deploy

3. **Uso diario:**
   - Push a `develop` → Staging
   - Push a `main` → Production

### Si prefieres quedarte con Local:

1. **Ya está listo:**
   - `docker compose up` para local
   - `git push origin main` para production

2. **Sin cambios necesarios**

---

## 🎓 Mejores Prácticas

### Con Staging:

```
✅ Probar en staging antes de production
✅ Usar ramas: develop → main
✅ Code review en PRs
✅ Tests automáticos en CI
✅ Monitorear staging
```

### Sin Staging:

```
✅ Probar bien en local
✅ Tests automáticos en CI
✅ Deploys pequeños y frecuentes
✅ Rollback rápido si falla
✅ Monitorear production
```

---

## 📝 Resumen

**Staging = Ambiente de pruebas antes de producción**

**Opciones:**
1. EC2 Separado (~$8/mes) - Profesional
2. Local (Gratis) - Simple
3. On-Demand (~$1/mes) - Económico

**Recomendación actual:**
- Usa **Local** por ahora
- Cuando crezcas, implementa **EC2 Separado**

**¿Quieres implementar staging en EC2?**
- Dime y creo todos los archivos
- Te guío paso a paso

---

**Última actualización:** 2025-11-25
