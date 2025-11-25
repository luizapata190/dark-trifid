#!/bin/bash
###############################################################################
# Script para crear repositorios ECR en AWS
# Ejecutar ANTES de configurar GitHub Actions
###############################################################################

set -e

# Colores
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${GREEN}=== Configuración de AWS ECR para Dark Trifid ===${NC}"
echo ""

# Variables
AWS_REGION="us-east-1"
FRONTEND_REPO="dark-trifid-frontend"
BACKEND_REPO="dark-trifid-backend"

# Verificar AWS CLI
if ! command -v aws &> /dev/null; then
    echo -e "${RED}❌ AWS CLI no está instalado${NC}"
    echo "Instala AWS CLI: https://aws.amazon.com/cli/"
    exit 1
fi

# Verificar credenciales
echo -e "${YELLOW}Verificando credenciales de AWS...${NC}"
if ! aws sts get-caller-identity &> /dev/null; then
    echo -e "${RED}❌ No hay credenciales de AWS configuradas${NC}"
    echo "Ejecuta: aws configure"
    exit 1
fi

echo -e "${GREEN}✅ Credenciales de AWS verificadas${NC}"
echo ""

# Crear repositorio para Frontend
echo -e "${YELLOW}Creando repositorio ECR para Frontend...${NC}"
if aws ecr describe-repositories --repository-names $FRONTEND_REPO --region $AWS_REGION &> /dev/null; then
    echo -e "${YELLOW}⚠️  Repositorio $FRONTEND_REPO ya existe${NC}"
else
    aws ecr create-repository \
        --repository-name $FRONTEND_REPO \
        --region $AWS_REGION \
        --image-scanning-configuration scanOnPush=true \
        --encryption-configuration encryptionType=AES256
    echo -e "${GREEN}✅ Repositorio $FRONTEND_REPO creado${NC}"
fi

# Crear repositorio para Backend
echo -e "${YELLOW}Creando repositorio ECR para Backend...${NC}"
if aws ecr describe-repositories --repository-names $BACKEND_REPO --region $AWS_REGION &> /dev/null; then
    echo -e "${YELLOW}⚠️  Repositorio $BACKEND_REPO ya existe${NC}"
else
    aws ecr create-repository \
        --repository-name $BACKEND_REPO \
        --region $AWS_REGION \
        --image-scanning-configuration scanOnPush=true \
        --encryption-configuration encryptionType=AES256
    echo -e "${GREEN}✅ Repositorio $BACKEND_REPO creado${NC}"
fi

echo ""
echo -e "${GREEN}=== ✅ Configuración de ECR completada ===${NC}"
echo ""

# Obtener información de los repositorios
ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)
ECR_REGISTRY="${ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com"

echo -e "${GREEN}📋 Información de los repositorios:${NC}"
echo ""
echo "Registry: $ECR_REGISTRY"
echo "Frontend: $ECR_REGISTRY/$FRONTEND_REPO"
echo "Backend:  $ECR_REGISTRY/$BACKEND_REPO"
echo ""

# Configurar política de lifecycle (opcional)
echo -e "${YELLOW}Configurando política de lifecycle (mantener últimas 10 imágenes)...${NC}"

LIFECYCLE_POLICY='{
  "rules": [
    {
      "rulePriority": 1,
      "description": "Keep last 10 images",
      "selection": {
        "tagStatus": "any",
        "countType": "imageCountMoreThan",
        "countNumber": 10
      },
      "action": {
        "type": "expire"
      }
    }
  ]
}'

aws ecr put-lifecycle-policy \
    --repository-name $FRONTEND_REPO \
    --lifecycle-policy-text "$LIFECYCLE_POLICY" \
    --region $AWS_REGION &> /dev/null

aws ecr put-lifecycle-policy \
    --repository-name $BACKEND_REPO \
    --lifecycle-policy-text "$LIFECYCLE_POLICY" \
    --region $AWS_REGION &> /dev/null

echo -e "${GREEN}✅ Políticas de lifecycle configuradas${NC}"
echo ""

echo -e "${GREEN}=== 🎯 Próximos pasos ===${NC}"
echo ""
echo "1. Configura los siguientes secretos en GitHub:"
echo "   - AWS_ACCESS_KEY_ID"
echo "   - AWS_SECRET_ACCESS_KEY"
echo "   - EC2_HOST (IP de tu instancia EC2)"
echo "   - EC2_USER (ec2-user)"
echo "   - EC2_SSH_KEY (contenido de tu archivo .pem)"
echo ""
echo "2. Configura tu EC2 para usar ECR:"
echo "   - Ejecuta: ./scripts/setup-ec2-for-ecr.sh"
echo ""
echo "3. Haz push a GitHub y el pipeline se ejecutará automáticamente"
echo ""
