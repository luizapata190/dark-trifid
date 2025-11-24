#!/bin/bash
###############################################################################
# Script para lanzar EC2 usando AWS CLI
# Requisitos: AWS CLI instalado y configurado (aws configure)
###############################################################################

set -e

# Variables configurables
REGION="us-east-1"
INSTANCE_TYPE="t2.micro"
KEY_NAME="mi-key-pair"  # ⚠️ CAMBIAR por tu key pair
PROJECT_NAME="dark-trifid"
SECURITY_GROUP_NAME="${PROJECT_NAME}-sg"

# Colores
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${GREEN}=== Lanzando instancia EC2 para ${PROJECT_NAME} ===${NC}"

# 1. Obtener la AMI más reciente de Amazon Linux 2
echo "Obteniendo AMI de Amazon Linux 2..."
AMI_ID=$(aws ec2 describe-images \
    --owners amazon \
    --filters "Name=name,Values=amzn2-ami-hvm-*-x86_64-gp2" \
              "Name=state,Values=available" \
    --query 'sort_by(Images, &CreationDate)[-1].ImageId' \
    --output text \
    --region $REGION)

echo "AMI seleccionada: $AMI_ID"

# 2. Crear Security Group
echo "Creando Security Group..."
SG_ID=$(aws ec2 create-security-group \
    --group-name $SECURITY_GROUP_NAME \
    --description "Security group para ${PROJECT_NAME}" \
    --region $REGION \
    --output text 2>/dev/null || \
    aws ec2 describe-security-groups \
        --group-names $SECURITY_GROUP_NAME \
        --query 'SecurityGroups[0].GroupId' \
        --output text \
        --region $REGION)

echo "Security Group ID: $SG_ID"

# 3. Configurar reglas del Security Group
echo "Configurando reglas de firewall..."

# SSH
aws ec2 authorize-security-group-ingress \
    --group-id $SG_ID \
    --protocol tcp \
    --port 22 \
    --cidr 0.0.0.0/0 \
    --region $REGION 2>/dev/null || true

# HTTP
aws ec2 authorize-security-group-ingress \
    --group-id $SG_ID \
    --protocol tcp \
    --port 80 \
    --cidr 0.0.0.0/0 \
    --region $REGION 2>/dev/null || true

# HTTPS
aws ec2 authorize-security-group-ingress \
    --group-id $SG_ID \
    --protocol tcp \
    --port 443 \
    --cidr 0.0.0.0/0 \
    --region $REGION 2>/dev/null || true

# Puerto 8000 (ajustar según tu aplicación)
aws ec2 authorize-security-group-ingress \
    --group-id $SG_ID \
    --protocol tcp \
    --port 8000 \
    --cidr 0.0.0.0/0 \
    --region $REGION 2>/dev/null || true

# 4. Lanzar instancia EC2
echo "Lanzando instancia EC2..."
INSTANCE_ID=$(aws ec2 run-instances \
    --image-id $AMI_ID \
    --instance-type $INSTANCE_TYPE \
    --key-name $KEY_NAME \
    --security-group-ids $SG_ID \
    --user-data file://ec2-user-data.sh \
    --block-device-mappings '[{"DeviceName":"/dev/xvda","Ebs":{"VolumeSize":20,"VolumeType":"gp3","Encrypted":true}}]' \
    --tag-specifications "ResourceType=instance,Tags=[{Key=Name,Value=${PROJECT_NAME}},{Key=ManagedBy,Value=AWS-CLI}]" \
    --region $REGION \
    --query 'Instances[0].InstanceId' \
    --output text)

echo "Instancia creada: $INSTANCE_ID"

# 5. Esperar a que la instancia esté corriendo
echo "Esperando a que la instancia esté corriendo..."
aws ec2 wait instance-running \
    --instance-ids $INSTANCE_ID \
    --region $REGION

# 6. Obtener IP pública
PUBLIC_IP=$(aws ec2 describe-instances \
    --instance-ids $INSTANCE_ID \
    --query 'Reservations[0].Instances[0].PublicIpAddress' \
    --output text \
    --region $REGION)

PUBLIC_DNS=$(aws ec2 describe-instances \
    --instance-ids $INSTANCE_ID \
    --query 'Reservations[0].Instances[0].PublicDnsName' \
    --output text \
    --region $REGION)

# 7. Mostrar información
echo ""
echo -e "${GREEN}=== ✅ Instancia EC2 lanzada exitosamente ===${NC}"
echo ""
echo "Instance ID:  $INSTANCE_ID"
echo "Public IP:    $PUBLIC_IP"
echo "Public DNS:   $PUBLIC_DNS"
echo ""
echo -e "${YELLOW}Comandos útiles:${NC}"
echo "  SSH:        ssh -i ${KEY_NAME}.pem ec2-user@${PUBLIC_IP}"
echo "  Ver logs:   ssh -i ${KEY_NAME}.pem ec2-user@${PUBLIC_IP} 'sudo tail -f /var/log/user-data.log'"
echo "  App URL:    http://${PUBLIC_IP}"
echo ""
echo -e "${YELLOW}NOTA:${NC} La aplicación tardará unos minutos en estar lista."
echo "      Verifica el progreso con: ssh -i ${KEY_NAME}.pem ec2-user@${PUBLIC_IP} 'sudo tail -f /var/log/user-data.log'"
echo ""
