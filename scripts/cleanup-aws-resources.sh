#!/bin/bash
###############################################################################
# Script para limpiar recursos de AWS creados por Terraform
# Usar cuando Terraform falla y deja recursos huérfanos
###############################################################################

set -e

# Colores
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${YELLOW}=== Limpiando recursos de AWS ===${NC}"
echo ""

AWS_REGION="us-east-1"
PROJECT_NAME="dark-trifid"

# 1. Eliminar Security Group
echo -e "${YELLOW}1. Eliminando Security Group...${NC}"
aws ec2 delete-security-group \
    --group-name ${PROJECT_NAME}-sg \
    --region $AWS_REGION 2>/dev/null && \
    echo -e "${GREEN}✅ Security Group eliminado${NC}" || \
    echo -e "${YELLOW}⚠️  Security Group no existe o ya fue eliminado${NC}"

# 2. Eliminar Instance Profile
echo -e "${YELLOW}2. Eliminando Instance Profile...${NC}"
aws iam remove-role-from-instance-profile \
    --instance-profile-name ${PROJECT_NAME}-ec2-profile \
    --role-name ${PROJECT_NAME}-ec2-ecr-role 2>/dev/null && \
    echo -e "${GREEN}✅ Rol removido del Instance Profile${NC}" || \
    echo -e "${YELLOW}⚠️  Instance Profile no tiene rol asociado${NC}"

aws iam delete-instance-profile \
    --instance-profile-name ${PROJECT_NAME}-ec2-profile 2>/dev/null && \
    echo -e "${GREEN}✅ Instance Profile eliminado${NC}" || \
    echo -e "${YELLOW}⚠️  Instance Profile no existe${NC}"

# 3. Desasociar política del rol
echo -e "${YELLOW}3. Desasociando política IAM...${NC}"
aws iam detach-role-policy \
    --role-name ${PROJECT_NAME}-ec2-ecr-role \
    --policy-arn arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly 2>/dev/null && \
    echo -e "${GREEN}✅ Política desasociada${NC}" || \
    echo -e "${YELLOW}⚠️  Política no estaba asociada${NC}"

# 4. Eliminar IAM Role
echo -e "${YELLOW}4. Eliminando IAM Role...${NC}"
aws iam delete-role \
    --role-name ${PROJECT_NAME}-ec2-ecr-role 2>/dev/null && \
    echo -e "${GREEN}✅ IAM Role eliminado${NC}" || \
    echo -e "${YELLOW}⚠️  IAM Role no existe${NC}"

echo ""
echo -e "${GREEN}=== ✅ Limpieza completada ===${NC}"
echo ""
echo -e "${GREEN}Ahora puedes ejecutar el workflow de nuevo:${NC}"
echo "  GitHub > Actions > Full Stack > create-and-deploy"
echo ""
