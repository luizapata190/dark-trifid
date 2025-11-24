# Guía de Despliegue Automatizado en AWS EC2

Este documento describe las diferentes formas de automatizar el despliegue de **Dark Trifid** en AWS EC2.

---

## 📋 Tabla de Contenidos

1. [Instalación Manual con Script](#1-instalación-manual-con-script)
2. [Automatización con User Data](#2-automatización-con-user-data)
3. [Automatización con AWS CLI](#3-automatización-con-aws-cli)
4. [Automatización con Terraform](#4-automatización-con-terraform)
5. [Comparación de Métodos](#5-comparación-de-métodos)

---

## 1. Instalación Manual con Script

### Descripción
Lanzas la instancia EC2 manualmente y luego ejecutas un script de instalación.

### Pasos

1. **Lanzar instancia EC2** desde AWS Console
   - AMI: Amazon Linux 2
   - Tipo: t2.micro (o superior)
   - Configurar Security Group (puertos 22, 80, 443, 8000)
   - Crear/seleccionar Key Pair

2. **Conectarse por SSH**
   ```bash
   ssh -i tu-key.pem ec2-user@<IP-PUBLICA>
   ```

3. **Descargar y ejecutar el script**
   ```bash
   curl -O https://raw.githubusercontent.com/luizapata190/dark-trifid/main/setup-ec2.sh
   chmod +x setup-ec2.sh
   ./setup-ec2.sh
   ```

### Ventajas
✅ Control total del proceso  
✅ Fácil de debuggear  
✅ No requiere herramientas adicionales

### Desventajas
❌ Proceso manual  
❌ Requiere conexión SSH  
❌ Más tiempo de configuración

---

## 2. Automatización con User Data

### Descripción
AWS ejecuta automáticamente un script al lanzar la instancia.

### Pasos

1. **Ir a AWS Console > EC2 > Launch Instance**

2. **Configurar la instancia:**
   - **AMI**: Amazon Linux 2
   - **Instance Type**: t2.micro
   - **Key Pair**: Seleccionar o crear uno

3. **En "Advanced Details" > "User Data"**, pegar el contenido de `ec2-user-data.sh`:
   ```bash
   #!/bin/bash
   exec > >(tee /var/log/user-data.log)
   exec 2>&1
   
   yum update -y
   yum install git docker -y
   service docker start
   systemctl enable docker
   usermod -a -G docker ec2-user
   
   mkdir -p /usr/local/lib/docker/cli-plugins
   curl -SL "https://github.com/docker/compose/releases/download/v2.24.5/docker-compose-linux-x86_64" \
       -o /usr/local/lib/docker/cli-plugins/docker-compose
   chmod +x /usr/local/lib/docker/cli-plugins/docker-compose
   
   cd /home/ec2-user
   git clone https://github.com/luizapata190/dark-trifid.git
   chown -R ec2-user:ec2-user /home/ec2-user/dark-trifid
   
   cd /home/ec2-user/dark-trifid
   docker compose up --build -d
   ```

4. **Configurar Security Group** (puertos 22, 80, 443, 8000)

5. **Launch Instance**

6. **Verificar logs** (después de conectarse por SSH):
   ```bash
   ssh -i tu-key.pem ec2-user@<IP-PUBLICA>
   sudo tail -f /var/log/user-data.log
   ```

### Ventajas
✅ Totalmente automatizado  
✅ No requiere SSH para instalación  
✅ Fácil de usar desde AWS Console

### Desventajas
❌ Difícil de debuggear si falla  
❌ Requiere configuración manual en Console

---

## 3. Automatización con AWS CLI

### Descripción
Lanza la instancia EC2 completamente desde la línea de comandos.

### Requisitos Previos

1. **Instalar AWS CLI**
   ```bash
   # Windows (PowerShell)
   msiexec.exe /i https://awscli.amazonaws.com/AWSCLIV2.msi
   
   # macOS
   brew install awscli
   
   # Linux
   curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
   unzip awscliv2.zip
   sudo ./aws/install
   ```

2. **Configurar credenciales**
   ```bash
   aws configure
   ```
   Ingresa:
   - AWS Access Key ID
   - AWS Secret Access Key
   - Default region (ej: us-east-1)
   - Default output format (json)

3. **Crear Key Pair** (si no tienes uno)
   ```bash
   aws ec2 create-key-pair \
       --key-name dark-trifid-key \
       --query 'KeyMaterial' \
       --output text > dark-trifid-key.pem
   
   chmod 400 dark-trifid-key.pem
   ```

### Pasos

1. **Editar el script** `aws-cli-launch.sh`
   ```bash
   # Cambiar estas variables:
   KEY_NAME="tu-key-pair"  # Nombre de tu key pair
   REGION="us-east-1"      # Tu región preferida
   ```

2. **Ejecutar el script**
   ```bash
   chmod +x aws-cli-launch.sh
   ./aws-cli-launch.sh
   ```

3. **El script automáticamente:**
   - Obtiene la AMI más reciente de Amazon Linux 2
   - Crea el Security Group
   - Configura las reglas de firewall
   - Lanza la instancia con User Data
   - Muestra la IP pública y comandos útiles

### Ventajas
✅ Completamente automatizado  
✅ Reproducible y versionable  
✅ Ideal para CI/CD  
✅ No requiere AWS Console

### Desventajas
❌ Requiere AWS CLI configurado  
❌ Curva de aprendizaje inicial

---

## 4. Automatización con Terraform

### Descripción
Infraestructura como código (IaC) para gestionar toda la infraestructura de AWS.

### Requisitos Previos

1. **Instalar Terraform**
   ```bash
   # Windows (Chocolatey)
   choco install terraform
   
   # macOS
   brew install terraform
   
   # Linux
   wget https://releases.hashicorp.com/terraform/1.6.0/terraform_1.6.0_linux_amd64.zip
   unzip terraform_1.6.0_linux_amd64.zip
   sudo mv terraform /usr/local/bin/
   ```

2. **Configurar AWS CLI** (mismo que método anterior)
   ```bash
   aws configure
   ```

3. **Crear Key Pair en AWS Console**
   - AWS Console > EC2 > Key Pairs > Create key pair
   - Guardar el archivo `.pem`

### Pasos

1. **Navegar al directorio de Terraform**
   ```bash
   cd terraform/
   ```

2. **Crear archivo de variables**
   ```bash
   cp terraform.tfvars.example terraform.tfvars
   ```

3. **Editar `terraform.tfvars`**
   ```hcl
   aws_region    = "us-east-1"
   instance_type = "t2.micro"
   key_name      = "tu-key-pair"  # ⚠️ CAMBIAR
   project_name  = "dark-trifid"
   ```

4. **Inicializar Terraform**
   ```bash
   terraform init
   ```

5. **Ver el plan de ejecución**
   ```bash
   terraform plan
   ```

6. **Aplicar la configuración**
   ```bash
   terraform apply
   ```
   - Escribe `yes` para confirmar

7. **Terraform mostrará:**
   - Instance ID
   - IP Pública
   - DNS Público
   - Comando SSH
   - URL de la aplicación

### Comandos Útiles

```bash
# Ver outputs
terraform output

# Ver estado
terraform show

# Destruir infraestructura
terraform destroy

# Formatear código
terraform fmt

# Validar configuración
terraform validate
```

### Ventajas
✅ Infraestructura como código  
✅ Versionable en Git  
✅ Fácil de replicar en múltiples entornos  
✅ Gestión de estado  
✅ Ideal para equipos  
✅ Soporta múltiples proveedores cloud

### Desventajas
❌ Curva de aprendizaje más alta  
❌ Requiere Terraform instalado  
❌ Gestión de archivos de estado

---

## 5. Comparación de Métodos

| Característica | Manual + Script | User Data | AWS CLI | Terraform |
|----------------|----------------|-----------|---------|-----------|
| **Automatización** | ⭐⭐ | ⭐⭐⭐⭐ | ⭐⭐⭐⭐⭐ | ⭐⭐⭐⭐⭐ |
| **Facilidad de uso** | ⭐⭐⭐⭐⭐ | ⭐⭐⭐⭐ | ⭐⭐⭐ | ⭐⭐ |
| **Reproducibilidad** | ⭐⭐ | ⭐⭐⭐ | ⭐⭐⭐⭐⭐ | ⭐⭐⭐⭐⭐ |
| **Control** | ⭐⭐⭐⭐⭐ | ⭐⭐⭐ | ⭐⭐⭐⭐ | ⭐⭐⭐⭐⭐ |
| **Debugging** | ⭐⭐⭐⭐⭐ | ⭐⭐ | ⭐⭐⭐ | ⭐⭐⭐⭐ |
| **Escalabilidad** | ⭐ | ⭐⭐ | ⭐⭐⭐⭐ | ⭐⭐⭐⭐⭐ |
| **CI/CD** | ⭐ | ⭐⭐ | ⭐⭐⭐⭐⭐ | ⭐⭐⭐⭐⭐ |
| **Curva de aprendizaje** | Baja | Baja | Media | Alta |

### Recomendaciones

- **Principiantes**: Usar **Manual + Script** o **User Data**
- **Desarrollo rápido**: Usar **User Data** o **AWS CLI**
- **Producción**: Usar **Terraform**
- **CI/CD**: Usar **AWS CLI** o **Terraform**
- **Equipos**: Usar **Terraform**

---

## 🔧 Troubleshooting

### Verificar logs de User Data
```bash
ssh -i tu-key.pem ec2-user@<IP-PUBLICA>
sudo tail -f /var/log/user-data.log
```

### Verificar estado de Docker
```bash
sudo systemctl status docker
sudo docker ps
```

### Verificar estado de la aplicación
```bash
cd /home/ec2-user/dark-trifid
sudo docker compose ps
sudo docker compose logs -f
```

### Puertos no accesibles
- Verificar Security Group en AWS Console
- Verificar que los puertos estén abiertos: 22, 80, 443, 8000

---

## 📚 Recursos Adicionales

- [AWS EC2 Documentation](https://docs.aws.amazon.com/ec2/)
- [AWS CLI Documentation](https://docs.aws.amazon.com/cli/)
- [Terraform AWS Provider](https://registry.terraform.io/providers/hashicorp/aws/latest/docs)
- [Docker Compose Documentation](https://docs.docker.com/compose/)

---

## 🤝 Contribuciones

Si encuentras algún problema o tienes sugerencias, por favor abre un issue en GitHub.

---

**Autor**: Luis Zapata  
**Proyecto**: Dark Trifid  
**Última actualización**: 2025-11-24
