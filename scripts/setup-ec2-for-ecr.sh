#!/bin/bash
###############################################################################
# Script para configurar EC2 para usar imágenes de ECR
# Ejecutar DENTRO de la instancia EC2
###############################################################################

set -e

# Colores
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${GREEN}=== Configurando EC2 para usar ECR ===${NC}"
echo ""

# Variables
AWS_REGION="us-east-1"
ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text 2>/dev/null || echo "")

if [ -z "$ACCOUNT_ID" ]; then
    echo -e "${YELLOW}⚠️  Configurando AWS CLI...${NC}"
    echo "Por favor, ingresa tus credenciales de AWS:"
    aws configure
    ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)
fi

ECR_REGISTRY="${ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com"

echo -e "${GREEN}✅ AWS Account ID: $ACCOUNT_ID${NC}"
echo -e "${GREEN}✅ ECR Registry: $ECR_REGISTRY${NC}"
echo ""

# Instalar AWS CLI si no está instalado
if ! command -v aws &> /dev/null; then
    echo -e "${YELLOW}Instalando AWS CLI...${NC}"
    curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
    unzip awscliv2.zip
    sudo ./aws/install
    rm -rf aws awscliv2.zip
    echo -e "${GREEN}✅ AWS CLI instalado${NC}"
fi

# Login a ECR
echo -e "${YELLOW}Autenticando con ECR...${NC}"
aws ecr get-login-password --region $AWS_REGION | sudo docker login --username AWS --password-stdin $ECR_REGISTRY
echo -e "${GREEN}✅ Autenticado con ECR${NC}"
echo ""

# Crear archivo .env para docker-compose
echo -e "${YELLOW}Creando archivo de configuración...${NC}"
cat > ~/dark-trifid/.env << EOF
ECR_REGISTRY=$ECR_REGISTRY
AWS_REGION=$AWS_REGION
EOF

echo -e "${GREEN}✅ Archivo .env creado${NC}"
echo ""

# Actualizar docker-compose para usar imágenes de ECR
echo -e "${YELLOW}Configurando docker-compose para usar ECR...${NC}"
cd ~/dark-trifid

# Usar docker-compose.prod.yml si existe
if [ -f "docker-compose.prod.yml" ]; then
    echo -e "${GREEN}✅ Usando docker-compose.prod.yml${NC}"
    sudo docker compose -f docker-compose.prod.yml pull
    sudo docker compose -f docker-compose.prod.yml up -d
else
    echo -e "${YELLOW}⚠️  docker-compose.prod.yml no encontrado${NC}"
    echo "Asegúrate de hacer git pull para obtener la última versión"
fi

echo ""
echo -e "${GREEN}=== ✅ Configuración completada ===${NC}"
echo ""
echo -e "${GREEN}📋 Información:${NC}"
echo "ECR Registry: $ECR_REGISTRY"
echo "Proyecto: ~/dark-trifid"
echo ""
echo -e "${GREEN}🎯 Comandos útiles:${NC}"
echo "  - Actualizar desde ECR: aws ecr get-login-password --region $AWS_REGION | sudo docker login --username AWS --password-stdin $ECR_REGISTRY"
echo "  - Ver imágenes: sudo docker images"
echo "  - Ver contenedores: sudo docker compose ps"
echo ""
