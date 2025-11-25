# 🔒 Elastic IP - IP Fija para tu EC2

## 🎯 ¿Qué es una Elastic IP?

Una **Elastic IP (EIP)** es una dirección IP pública **estática** (fija) que puedes asignar a tu instancia EC2.

### Diferencia con IP Normal:

| Tipo de IP | ¿Cambia al reiniciar? | ¿Cambia al parar/iniciar? | Costo |
|------------|----------------------|---------------------------|-------|
| **IP Pública Normal** | ❌ No | ✅ **SÍ** | Gratis |
| **Elastic IP** | ❌ No | ❌ **NO** | Gratis* |

**Gratis si está asociada a una instancia corriendo. Se cobra si está sin usar.*

---

## ✅ Ventajas de Elastic IP

### 1. **IP Permanente**
```
Sin Elastic IP:
Parar EC2 → Iniciar EC2 → Nueva IP (54.123.45.67 → 3.18.230.112)
❌ Tienes que actualizar DNS, secretos, configuraciones

Con Elastic IP:
Parar EC2 → Iniciar EC2 → Misma IP (3.18.230.112)
✅ No cambias nada
```

### 2. **Failover Rápido**
```
Si tu EC2 falla:
- Creas nueva instancia
- Reasignas la Elastic IP
- Usuarios siguen usando la misma IP
```

### 3. **Mantenimiento Sin Downtime**
```
1. Crear nueva EC2 con actualizaciones
2. Probar que funciona
3. Reasignar Elastic IP a la nueva
4. Eliminar EC2 antigua
```

---

## 🏗️ Implementación en Terraform

### Código Agregado:

```hcl
# Crear Elastic IP
resource "aws_eip" "dark_trifid_eip" {
  domain = "vpc"
  
  tags = {
    Name = "dark-trifid-eip"
  }
}

# Asociar a la instancia
resource "aws_eip_association" "dark_trifid_eip_assoc" {
  instance_id   = aws_instance.dark_trifid.id
  allocation_id = aws_eip.dark_trifid_eip.id
}
```

### Outputs Actualizados:

```hcl
output "public_ip" {
  description = "IP pública FIJA (Elastic IP)"
  value       = aws_eip.dark_trifid_eip.public_ip
}

output "elastic_ip" {
  description = "Elastic IP asignada (no cambia al reiniciar)"
  value       = aws_eip.dark_trifid_eip.public_ip
}
```

---

## 🚀 Cómo Usar

### Primera Vez (Crear Todo):

```bash
# 1. Subir cambios
git add terraform/main.tf
git commit -m "feat: add Elastic IP for static public IP"
git push origin main

# 2. Ejecutar workflow
# GitHub > Actions > Full Stack > create-and-deploy
```

**Resultado:**
- EC2 creado
- Elastic IP creada
- Elastic IP asociada a EC2
- IP nunca cambiará ✅

### Si Ya Tienes EC2 Corriendo:

**Opción A: Recrear (Recomendado)**
```bash
# 1. Destruir infraestructura actual
# GitHub > Actions > Emergency Cleanup > DELETE

# 2. Crear de nuevo con Elastic IP
# GitHub > Actions > Full Stack > create-and-deploy
```

**Opción B: Agregar Elastic IP a EC2 Existente**
```bash
# Desde AWS Console:
# 1. EC2 > Elastic IPs > Allocate Elastic IP address
# 2. Actions > Associate Elastic IP address
# 3. Seleccionar tu instancia
# 4. Associate
```

---

## 💰 Costos

### Elastic IP:

| Escenario | Costo |
|-----------|-------|
| **Asociada a EC2 corriendo** | **$0.00/mes** ✅ |
| **No asociada (sin usar)** | **~$3.60/mes** ⚠️ |
| **Asociada a EC2 parada** | **~$3.60/mes** ⚠️ |

**Conclusión:** Es gratis si la usas, se cobra si la reservas sin usar.

### Recomendación:
- ✅ Usa Elastic IP en producción
- ✅ Siempre asóciala a una instancia
- ✅ Si no la usas, libérala

---

## 🔍 Verificar Elastic IP

### Desde AWS Console:

1. **EC2 > Elastic IPs**
2. Verás tu Elastic IP
3. Estado: "Associated" ✅

### Desde Terraform:

```bash
cd terraform
terraform output elastic_ip
# Output: 3.18.230.112
```

### Desde GitHub Actions:

Después del workflow, verás en el Summary:
```
Elastic IP: 3.18.230.112
Application URL: http://3.18.230.112
```

---

## 🎯 Casos de Uso

### 1. **Reiniciar EC2 (Mantenimiento)**

```bash
# Antes (sin Elastic IP):
# 1. Parar EC2
# 2. Iniciar EC2
# 3. Nueva IP: 54.123.45.67
# 4. Actualizar EC2_HOST en GitHub Secrets ❌
# 5. Actualizar DNS ❌
# 6. Notificar usuarios ❌

# Ahora (con Elastic IP):
# 1. Parar EC2
# 2. Iniciar EC2
# 3. Misma IP: 3.18.230.112 ✅
# 4. ¡Listo! ✅
```

### 2. **Migrar a Nueva Instancia**

```bash
# 1. Crear nueva EC2 (con actualizaciones)
# 2. Probar que funciona
# 3. Desasociar Elastic IP de EC2 antigua
# 4. Asociar Elastic IP a EC2 nueva
# 5. Eliminar EC2 antigua
# Usuarios nunca notan el cambio ✅
```

### 3. **Disaster Recovery**

```bash
# Si EC2 falla:
# 1. Crear nueva instancia
# 2. Reasignar Elastic IP
# 3. Servicio restaurado en minutos
```

---

## 📊 Comparación

### Sin Elastic IP:

```
EC2 Start → IP: 3.18.230.112
EC2 Stop
EC2 Start → IP: 54.123.45.67 ❌ (cambió)

Problemas:
- Actualizar DNS
- Actualizar secretos
- Notificar usuarios
- Downtime
```

### Con Elastic IP:

```
EC2 Start → Elastic IP: 3.18.230.112
EC2 Stop
EC2 Start → Elastic IP: 3.18.230.112 ✅ (igual)

Ventajas:
- No cambias nada
- Sin downtime
- Usuarios no notan
```

---

## 🛡️ Mejores Prácticas

### ✅ DO:
- Usar Elastic IP en producción
- Asociarla siempre a una instancia
- Documentar la IP en tu equipo
- Usar tags para identificarla

### ❌ DON'T:
- Dejar Elastic IPs sin asociar (se cobra)
- Crear múltiples EIPs sin usar
- Olvidar liberarlas al destruir infraestructura

---

## 🔄 Workflow Actualizado

### Nuevo Flujo:

```
1. Terraform crea EC2
   ↓
2. Terraform crea Elastic IP
   ↓
3. Terraform asocia Elastic IP a EC2
   ↓
4. Output: Elastic IP fija
   ↓
5. Aplicación accesible en IP fija
   ↓
6. Reiniciar EC2 → IP no cambia ✅
```

---

## 📋 Checklist

- [ ] Terraform actualizado con Elastic IP
- [ ] Cambios subidos a GitHub
- [ ] Workflow ejecutado
- [ ] Elastic IP creada y asociada
- [ ] IP verificada en AWS Console
- [ ] Aplicación accesible en IP fija
- [ ] Documentar IP en equipo

---

## 🎉 Resultado Final

**Antes:**
```
http://3.18.230.112 (hoy)
http://54.123.45.67 (después de reiniciar) ❌
```

**Ahora:**
```
http://3.18.230.112 (siempre) ✅
```

---

**¿Preguntas?** La Elastic IP es gratis si la usas, y te da una IP permanente para tu aplicación.

**Última actualización:** 2025-11-24
