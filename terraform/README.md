# Terraform - Infraestructura como Código para Dark Trifid

Este directorio contiene la configuración de Terraform para desplegar automáticamente la aplicación Dark Trifid en AWS EC2.

## 📋 Requisitos Previos

1. **Terraform instalado** (v1.0+)
   ```bash
   # Verificar instalación
   terraform version
   ```

2. **AWS CLI configurado**
   ```bash
   aws configure
   # Ingresa: Access Key ID, Secret Access Key, Region, Output format
   ```

3. **Key Pair creado en AWS**
   - Ve a AWS Console > EC2 > Key Pairs
   - Crea un nuevo key pair o usa uno existente
   - Descarga el archivo `.pem` y guárdalo en un lugar seguro

## 🚀 Uso Rápido

### 1. Configurar Variables

```bash
# Copiar el archivo de ejemplo
cp terraform.tfvars.example terraform.tfvars

# Editar con tus valores
nano terraform.tfvars
```

**Edita `terraform.tfvars`:**
```hcl
aws_region    = "us-east-1"           # Tu región preferida
instance_type = "t2.micro"            # Tipo de instancia
key_name      = "mi-key-pair"         # ⚠️ CAMBIAR por tu key pair
project_name  = "dark-trifid"
```

### 2. Inicializar Terraform

```bash
terraform init
```

Esto descargará los providers necesarios (AWS).

### 3. Revisar el Plan

```bash
terraform plan
```

Esto mostrará qué recursos se crearán sin ejecutar cambios.

### 4. Aplicar la Configuración

```bash
terraform apply
```

- Revisa los cambios propuestos
- Escribe `yes` para confirmar
- Espera a que Terraform cree los recursos (2-3 minutos)

### 5. Obtener Información de la Instancia

```bash
# Ver todos los outputs
terraform output

# Ver IP pública
terraform output public_ip

# Ver comando SSH
terraform output ssh_connection
```

## 📊 Recursos Creados

Terraform creará automáticamente:

- ✅ **EC2 Instance** (Amazon Linux 2)
- ✅ **Security Group** con reglas para:
  - Puerto 22 (SSH)
  - Puerto 80 (HTTP)
  - Puerto 443 (HTTPS)
  - Puerto 8000 (Aplicación)
- ✅ **User Data Script** (instalación automática)
- ✅ **Tags** para organización

## 🔧 Comandos Útiles

```bash
# Ver estado actual
terraform show

# Ver outputs
terraform output

# Formatear código
terraform fmt

# Validar configuración
terraform validate

# Ver estado en formato JSON
terraform show -json

# Listar recursos
terraform state list

# Actualizar infraestructura (si cambias main.tf)
terraform apply

# Destruir toda la infraestructura
terraform destroy
```

## 📝 Archivos Importantes

| Archivo | Descripción |
|---------|-------------|
| `main.tf` | Configuración principal de infraestructura |
| `terraform.tfvars.example` | Plantilla de variables |
| `terraform.tfvars` | Tus variables (NO versionado en Git) |
| `.gitignore` | Archivos excluidos de Git |

## 🔐 Seguridad

### ⚠️ IMPORTANTE

- **NUNCA** subas `terraform.tfvars` a Git (contiene información sensible)
- **NUNCA** subas archivos `.tfstate` a Git (contienen secretos)
- Restringe el acceso SSH a tu IP específica:

```hcl
# En main.tf, cambiar:
cidr_blocks = ["0.0.0.0/0"]  # ❌ Inseguro
# Por:
cidr_blocks = ["TU.IP.PUBLICA/32"]  # ✅ Seguro
```

### Obtener tu IP pública

```bash
curl ifconfig.me
```

## 🐛 Troubleshooting

### Error: "No valid credential sources"

```bash
# Configurar AWS CLI
aws configure
```

### Error: "InvalidKeyPair.NotFound"

El key pair especificado no existe. Verifica:
```bash
# Listar key pairs disponibles
aws ec2 describe-key-pairs --query 'KeyPairs[*].KeyName'
```

### Error: "UnauthorizedOperation"

Tu usuario de AWS no tiene permisos suficientes. Necesitas permisos para:
- EC2 (crear instancias, security groups)
- Describe AMIs

### La aplicación no responde

```bash
# Conectarse a la instancia
ssh -i tu-key.pem ec2-user@$(terraform output -raw public_ip)

# Ver logs de instalación
sudo tail -f /var/log/user-data.log

# Ver estado de Docker
sudo docker compose ps
sudo docker compose logs -f
```

## 🔄 Actualizar la Infraestructura

Si modificas `main.tf`:

```bash
# Ver cambios propuestos
terraform plan

# Aplicar cambios
terraform apply
```

Terraform solo modificará los recursos que cambiaron.

## 🗑️ Destruir la Infraestructura

```bash
# Ver qué se eliminará
terraform plan -destroy

# Eliminar todo
terraform destroy
```

⚠️ **ADVERTENCIA**: Esto eliminará permanentemente todos los recursos creados.

## 📚 Variables Disponibles

| Variable | Descripción | Default | Requerido |
|----------|-------------|---------|-----------|
| `aws_region` | Región de AWS | `us-east-1` | No |
| `instance_type` | Tipo de instancia EC2 | `t2.micro` | No |
| `key_name` | Nombre del key pair | - | **Sí** |
| `project_name` | Nombre del proyecto | `dark-trifid` | No |

## 🎯 Mejores Prácticas

1. **Usa workspaces** para múltiples entornos:
   ```bash
   terraform workspace new production
   terraform workspace new staging
   terraform workspace select production
   ```

2. **Guarda el estado remotamente** (S3 + DynamoDB):
   ```hcl
   terraform {
     backend "s3" {
       bucket = "mi-terraform-state"
       key    = "dark-trifid/terraform.tfstate"
       region = "us-east-1"
     }
   }
   ```

3. **Versiona tu código** en Git (excepto archivos sensibles)

4. **Usa variables de entorno** para secretos:
   ```bash
   export TF_VAR_key_name="mi-key-pair"
   terraform apply
   ```

## 📖 Recursos Adicionales

- [Terraform AWS Provider](https://registry.terraform.io/providers/hashicorp/aws/latest/docs)
- [Terraform CLI Documentation](https://www.terraform.io/cli)
- [AWS EC2 Documentation](https://docs.aws.amazon.com/ec2/)

---

**¿Necesitas ayuda?** Consulta [DEPLOYMENT.md](../DEPLOYMENT.md) en el directorio raíz.
