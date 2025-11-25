#!/bin/bash
###############################################################################
# Script para construir y subir imágenes a ECR manualmente
# Útil para el primer despliegue o testing
###############################################################################

set -e

# Colores
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${GREEN}=== Build y Push a ECR ===${NC}"
echo ""

# Variables
AWS_REGION="us-east-1"
ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)
ECR_REGISTRY="${ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com"
IMAGE_TAG="${1:-latest}"

echo -e "${BLUE}Registry: $ECR_REGISTRY${NC}"
echo -e "${BLUE}Tag: $IMAGE_TAG${NC}"
echo ""

# Login a ECR
echo -e "${YELLOW}1. Autenticando con ECR...${NC}"
aws ecr get-login-password --region $AWS_REGION | docker login --username AWS --password-stdin $ECR_REGISTRY
echo -e "${GREEN}✅ Autenticado${NC}"
echo ""

# Build Frontend
echo -e "${YELLOW}2. Construyendo imagen Frontend...${NC}"
docker build -t dark-trifid-frontend:$IMAGE_TAG -f frontend/Dockerfile .
echo -e "${GREEN}✅ Frontend construido${NC}"
echo ""

# Build Backend
echo -e "${YELLOW}3. Construyendo imagen Backend...${NC}"
docker build -t dark-trifid-backend:$IMAGE_TAG -f backend/Dockerfile backend/
echo -e "${GREEN}✅ Backend construido${NC}"
echo ""

# Tag Frontend
echo -e "${YELLOW}4. Etiquetando Frontend...${NC}"
docker tag dark-trifid-frontend:$IMAGE_TAG $ECR_REGISTRY/dark-trifid-frontend:$IMAGE_TAG
docker tag dark-trifid-frontend:$IMAGE_TAG $ECR_REGISTRY/dark-trifid-frontend:latest
echo -e "${GREEN}✅ Frontend etiquetado${NC}"
echo ""

# Tag Backend
echo -e "${YELLOW}5. Etiquetando Backend...${NC}"
docker tag dark-trifid-backend:$IMAGE_TAG $ECR_REGISTRY/dark-trifid-backend:$IMAGE_TAG
docker tag dark-trifid-backend:$IMAGE_TAG $ECR_REGISTRY/dark-trifid-backend:latest
echo -e "${GREEN}✅ Backend etiquetado${NC}"
echo ""

# Push Frontend
echo -e "${YELLOW}6. Subiendo Frontend a ECR...${NC}"
docker push $ECR_REGISTRY/dark-trifid-frontend:$IMAGE_TAG
docker push $ECR_REGISTRY/dark-trifid-frontend:latest
echo -e "${GREEN}✅ Frontend subido${NC}"
echo ""

# Push Backend
echo -e "${YELLOW}7. Subiendo Backend a ECR...${NC}"
docker push $ECR_REGISTRY/dark-trifid-backend:$IMAGE_TAG
docker push $ECR_REGISTRY/dark-trifid-backend:latest
echo -e "${GREEN}✅ Backend subido${NC}"
echo ""

echo -e "${GREEN}=== ✅ Build y Push completados ===${NC}"
echo ""
echo -e "${GREEN}📋 Imágenes creadas:${NC}"
echo "  - $ECR_REGISTRY/dark-trifid-frontend:$IMAGE_TAG"
echo "  - $ECR_REGISTRY/dark-trifid-frontend:latest"
echo "  - $ECR_REGISTRY/dark-trifid-backend:$IMAGE_TAG"
echo "  - $ECR_REGISTRY/dark-trifid-backend:latest"
echo ""
echo -e "${GREEN}🎯 Próximo paso:${NC}"
echo "  Despliega en EC2 ejecutando en tu servidor:"
echo "  cd ~/dark-trifid && sudo docker compose -f docker-compose.prod.yml pull && sudo docker compose -f docker-compose.prod.yml up -d"
echo ""
