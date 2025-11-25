#!/bin/bash
###############################################################################
# User Data Script for Terraform-managed EC2
# This script runs automatically when the instance is created
###############################################################################

exec > >(tee /var/log/user-data.log)
exec 2>&1

echo "=== Starting Dark Trifid Setup ==="
date

# Update system
yum update -y

# Install Git
yum install git -y

# Install Docker
yum install docker -y
service docker start
systemctl enable docker
usermod -a -G docker ec2-user

# Install Docker Compose Plugin
mkdir -p /usr/local/lib/docker/cli-plugins
curl -SL "https://github.com/docker/compose/releases/download/v2.24.5/docker-compose-linux-x86_64" \
    -o /usr/local/lib/docker/cli-plugins/docker-compose
chmod +x /usr/local/lib/docker/cli-plugins/docker-compose

# Install AWS CLI (if not already installed)
if ! command -v aws &> /dev/null; then
    curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
    unzip awscliv2.zip
    ./aws/install
    rm -rf aws awscliv2.zip
fi

# Clone the project
cd /home/ec2-user
git clone https://github.com/luizapata190/dark-trifid.git
chown -R ec2-user:ec2-user /home/ec2-user/dark-trifid

# Get AWS account ID and region
ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)
REGION=$(ec2-metadata --availability-zone | sed 's/placement: \(.*\).$/\1/')

# Create .env file for docker-compose
cat > /home/ec2-user/dark-trifid/.env << EOF
ECR_REGISTRY=${ACCOUNT_ID}.dkr.ecr.us-east-1.amazonaws.com
AWS_REGION=us-east-1
EOF

chown ec2-user:ec2-user /home/ec2-user/dark-trifid/.env

echo "=== Setup completed ==="
date
echo "Instance is ready. Waiting for images to be pushed to ECR..."
echo "Application will be deployed via GitHub Actions."
