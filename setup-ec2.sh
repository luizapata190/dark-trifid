#!/bin/bash
###############################################################################
# Script de instalación automatizada para Dark Trifid en AWS EC2
# Sistema Operativo: Amazon Linux 2
# Descripción: Instala Docker, Docker Compose, clona el proyecto y lo ejecuta
###############################################################################

set -e  # Detener el script si hay algún error

# Colores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Función para logging
log_info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

###############################################################################
# PASO 1: Actualizar el sistema
###############################################################################
log_info "Paso 1: Actualizando el sistema..."
sudo yum update -y

###############################################################################
# PASO 2: Instalar Git
###############################################################################
log_info "Paso 2: Instalando Git..."
sudo yum install git -y
git --version

###############################################################################
# PASO 3: Instalar Docker
###############################################################################
log_info "Paso 3: Instalando Docker..."
sudo yum install docker -y

# Iniciar el servicio de Docker
log_info "Iniciando el servicio de Docker..."
sudo service docker start

# Habilitar Docker para que inicie automáticamente al arrancar
sudo systemctl enable docker

# Agregar el usuario actual al grupo docker
log_info "Agregando usuario al grupo docker..."
sudo usermod -a -G docker ec2-user

# Verificar instalación de Docker
docker --version

###############################################################################
# PASO 4: Instalar Docker Compose Plugin (v2)
###############################################################################
log_info "Paso 4: Instalando Docker Compose Plugin..."

# Crear directorio para plugins de Docker
sudo mkdir -p /usr/local/lib/docker/cli-plugins

# Descargar Docker Compose
DOCKER_COMPOSE_VERSION="v2.24.5"
log_info "Descargando Docker Compose ${DOCKER_COMPOSE_VERSION}..."
sudo curl -SL "https://github.com/docker/compose/releases/download/${DOCKER_COMPOSE_VERSION}/docker-compose-linux-x86_64" \
    -o /usr/local/lib/docker/cli-plugins/docker-compose

# Dar permisos de ejecución
sudo chmod +x /usr/local/lib/docker/cli-plugins/docker-compose

# Verificar instalación
sudo docker compose version

###############################################################################
# PASO 5: Clonar el proyecto
###############################################################################
log_info "Paso 5: Clonando el proyecto Dark Trifid..."

# Definir directorio de trabajo
WORK_DIR="/home/ec2-user/dark-trifid"

# Eliminar directorio si ya existe (para reinstalaciones)
if [ -d "$WORK_DIR" ]; then
    log_warning "El directorio $WORK_DIR ya existe. Eliminando..."
    sudo rm -rf "$WORK_DIR"
fi

# Clonar el repositorio
cd /home/ec2-user
git clone https://github.com/luizapata190/dark-trifid.git

###############################################################################
# PASO 6: Navegar al proyecto
###############################################################################
log_info "Paso 6: Navegando al directorio del proyecto..."
cd "$WORK_DIR"

###############################################################################
# PASO 7: Ejecutar Docker Compose
###############################################################################
log_info "Paso 7: Ejecutando Docker Compose..."

# Nota: Usamos 'sudo' porque el usuario necesita cerrar sesión para que 
# los permisos del grupo docker surtan efecto
sudo docker compose up --build -d

###############################################################################
# PASO 8: Verificar estado de los contenedores
###############################################################################
log_info "Paso 8: Verificando estado de los contenedores..."
sleep 5  # Esperar a que los contenedores inicien
sudo docker compose ps

###############################################################################
# Información final
###############################################################################
echo ""
log_info "=============================================="
log_info "✅ Instalación completada exitosamente!"
log_info "=============================================="
echo ""
log_info "El proyecto Dark Trifid está corriendo en Docker."
log_info "Directorio del proyecto: $WORK_DIR"
echo ""
log_info "🌐 Acceso a la aplicación:"
echo "  - URL: http://$(curl -s ifconfig.me)"
echo "  - Puerto: 80 (HTTP estándar)"
echo ""
log_info "Comandos útiles:"
echo "  - Ver logs:              sudo docker compose logs -f"
echo "  - Detener contenedores:  sudo docker compose down"
echo "  - Reiniciar:             sudo docker compose restart"
echo "  - Ver estado:            sudo docker compose ps"
echo ""
log_warning "IMPORTANTE: Cierra sesión y vuelve a conectarte para usar Docker sin 'sudo'"
log_warning "Comando: exit (luego vuelve a conectarte por SSH)"
echo ""

