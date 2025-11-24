#!/bin/bash
###############################################################################
# AWS EC2 User Data Script
# Este script se ejecuta automáticamente al lanzar una instancia EC2
# Uso: Pegar este contenido en la sección "User Data" al crear la instancia
###############################################################################

# Redirigir output a un archivo de log
exec > >(tee /var/log/user-data.log)
exec 2>&1

echo "=== Iniciando configuración automática de Dark Trifid ==="
date

# Actualizar el sistema
yum update -y

# Instalar Git
yum install git -y

# Instalar Docker
yum install docker -y
service docker start
systemctl enable docker
usermod -a -G docker ec2-user

# Instalar Docker Compose Plugin
mkdir -p /usr/local/lib/docker/cli-plugins
curl -SL "https://github.com/docker/compose/releases/download/v2.24.5/docker-compose-linux-x86_64" \
    -o /usr/local/lib/docker/cli-plugins/docker-compose
chmod +x /usr/local/lib/docker/cli-plugins/docker-compose

# Clonar el proyecto
cd /home/ec2-user
git clone https://github.com/luizapata190/dark-trifid.git
chown -R ec2-user:ec2-user /home/ec2-user/dark-trifid

# Ejecutar Docker Compose
cd /home/ec2-user/dark-trifid
docker compose up --build -d

echo "=== Configuración completada ==="
date
echo "La aplicación está corriendo. Verifica los logs en /var/log/user-data.log"
