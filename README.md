# Google Cloud Tech Week 2028

Sitio web informativo para **Google Cloud Tech Week 2028** - una semana completa dedicada a explorar las últimas innovaciones en Google Cloud Platform.

Construido con **FastAPI** (Python) y una arquitectura en capas profesional.

## 🎯 Características

- **Página de Inicio**: Información del evento, ubicación y fecha
- **Agenda**: Lista de 8 charlas con detalles y ponentes
- **Búsqueda**: Funcionalidad para buscar charlas por título, ponente o categoría
- **Diseño Responsivo**: Adaptado a dispositivos móviles y de escritorio
- **Arquitectura Limpia**: Separación de responsabilidades (Datos, Servicios, Web)

## 📁 Estructura del Proyecto

```text
/
├── database/              # Capa de Datos (Repositorio)
├── services/              # Capa de Negocio (Lógica)
├── web/                   # Capa de Presentación (Rutas, Templates, Static)
├── terraform/             # Infraestructura como código (Terraform)
├── main.py                # Punto de entrada (FastAPI)
├── pyproject.toml         # Gestión de dependencias (Poetry)
├── Dockerfile             # Configuración Docker
├── docker-compose.yml     # Orquestación
├── setup-ec2.sh           # Script de instalación para EC2
├── ec2-user-data.sh       # User Data para EC2
├── aws-cli-launch.sh      # Script de lanzamiento con AWS CLI
└── DEPLOYMENT.md          # Guía completa de despliegue
```

## 📋 Requisitos Previos

- Python 3.9+
- [Poetry](https://python-poetry.org/docs/#installation) (Gestor de paquetes)
- Docker y Docker Compose (Recomendado para deployment)

## 🚀 Ejecución Local (Sin Docker)

### 1. Instalar dependencias

```bash
poetry install
```

### 2. Ejecutar la aplicación

```bash
poetry run uvicorn main:app --reload
```

### 3. Acceder al sitio

- **Aplicación**: http://localhost:8000
- **Documentación API**: http://localhost:8000/docs

## 🐳 Ejecución con Docker

### Comandos principales

```bash
# Construir y levantar (desarrollo)
docker-compose up --build -d

# Ver logs en tiempo real
docker-compose logs -f

# Verificar estado
docker-compose build --no-cache
docker-compose up -d

# Limpiar recursos Docker no utilizados
docker system prune
```

## 🛠️ Desarrollo

### Hacer cambios en el código

1. Edita los archivos necesarios
2. Reconstruye y reinicia Docker:
   ```bash
   docker-compose up --build -d
   ```
3. Refresca el navegador con **Ctrl + Shift + R** (forzar sin caché)

### Estructura de archivos clave

- **`database/repository.py`**: Datos del evento y charlas
- **`services/catalog_service.py`**: Lógica de búsqueda y filtrado
- **`web/routes.py`**: Rutas de la aplicación
- **`web/templates/`**: Plantillas HTML (Jinja2)
- **`web/static/`**: CSS y archivos estáticos

## 📦 Dependencias

- **FastAPI**: Framework web moderno y rápido
- **Uvicorn**: Servidor ASGI de alto rendimiento
- **Jinja2**: Motor de plantillas
- **Python-multipart**: Manejo de formularios

## 🔧 Configuración de Poetry

Este proyecto usa `package-mode = false` porque es una aplicación web, no un paquete distribuible. Requiere **Poetry 1.8.0+**.

## 📝 Notas

- Los datos de charlas y ponentes son ficticios para demostración
- El proyecto está dockerizado para fácil deployment en Rancher Desktop o cualquier entorno Docker
- La aplicación usa FastAPI con templates HTML (no es una SPA)

## ☁️ Despliegue en AWS EC2

Este proyecto incluye múltiples métodos para desplegar en AWS EC2, desde manual hasta completamente automatizado.

### 📚 Documentación Completa

Para instrucciones detalladas de despliegue, consulta **[DEPLOYMENT.md](./DEPLOYMENT.md)** que incluye:

- ✅ Instalación manual con script automatizado
- ✅ Automatización con AWS User Data
- ✅ Despliegue con AWS CLI
- ✅ Infraestructura como código con Terraform
- ✅ Comparación de métodos y recomendaciones

### 🚀 Inicio Rápido

#### Opción 1: Script Automatizado (Recomendado para principiantes)

```bash
# Conectarse a EC2
ssh -i tu-key.pem ec2-user@<IP-PUBLICA>

# Descargar y ejecutar script
curl -O https://raw.githubusercontent.com/luizapata190/dark-trifid/main/setup-ec2.sh
chmod +x setup-ec2.sh
./setup-ec2.sh
```

#### Opción 2: User Data (Completamente automatizado)

Al crear la instancia EC2, pega el contenido de [`ec2-user-data.sh`](./ec2-user-data.sh) en la sección **User Data** de AWS Console.

#### Opción 3: AWS CLI (Para desarrolladores)

```bash
# Editar variables en el script
nano aws-cli-launch.sh

# Ejecutar
chmod +x aws-cli-launch.sh
./aws-cli-launch.sh
```

#### Opción 4: Terraform (Para producción)

```bash
cd terraform/
cp terraform.tfvars.example terraform.tfvars
# Editar terraform.tfvars con tus valores
terraform init
terraform plan
terraform apply
```

### 📋 Requisitos Previos para AWS

- Cuenta de AWS activa
- Key Pair creado en AWS EC2
- Security Group configurado (puertos: 22, 80, 443, 8000)
- AWS CLI configurado (para opciones 3 y 4)

### 🔍 Verificar Despliegue

```bash
# Ver logs de instalación
ssh -i tu-key.pem ec2-user@<IP-PUBLICA>
sudo tail -f /var/log/user-data.log

# Verificar contenedores
sudo docker compose ps
sudo docker compose logs -f
```

### 📖 Más Información

Consulta **[DEPLOYMENT.md](./DEPLOYMENT.md)** para guías paso a paso, troubleshooting y mejores prácticas.

## 🤝 Contribuir

Este es un proyecto de demostración. Siéntete libre de usarlo como base para tus propios eventos.

---

**Desarrollado con ❤️ usando FastAPI y Docker**

**Despliegue en EC2 de AWS**

**Paso 1 
**Actualziar  yum
sudo yum update -y

**Paso 2
**Instalamos Git y utils de yum
sudo yum install -y yum-utils git

**Paso 3 
**Instalamos Docker 
sudo yum install docker -y


**Paso 4 
**Instalamos Docker Compose 
sudo mkdir -p /usr/local/lib/docker/cli-plugins

sudo curl -SL https://github.com/docker/compose/releases/download/v2.24.5/docker-compose-linux-x86_64 -o /usr/local/lib/docker/cli-plugins/docker-compose
sudo chmod +x /usr/local/lib/docker/cli-plugins/docker-compose

sudo systemctl start docker
sudo systemctl enable docker
sudo usermod -aG docker ec2-user
newgrp docker

docker compose version

**Paso 5 
**Clonar el proyecto 
git clone https://github.com/luizapata190/dark-trifid.git

**Paso6
**Nos paramos en el proyecto
cd dark-trifid/

**Paso 7
**Ejecutamos Docker Compose
docker compose up --build -d