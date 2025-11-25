terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

# Variables
variable "aws_region" {
  description = "Región de AWS"
  type        = string
  default     = "us-east-1"
}

variable "instance_type" {
  description = "Tipo de instancia EC2"
  type        = string
  default     = "t3.micro"  # Free tier eligible (nuevo estándar)
}

variable "key_name" {
  description = "Nombre del key pair para SSH (opcional)"
  type        = string
  default     = ""  # Dejar vacío si no necesitas SSH
}

variable "project_name" {
  description = "Nombre del proyecto"
  type        = string
  default     = "dark-trifid"
}

# Obtener la AMI más reciente de Amazon Linux 2
data "aws_ami" "amazon_linux_2" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

# Security Group
resource "aws_security_group" "dark_trifid_sg" {
  name        = "${var.project_name}-sg"
  description = "Security group para ${var.project_name}"

  # SSH
  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  # ⚠️ Cambiar a tu IP para mayor seguridad
  }

  # HTTP
  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # HTTPS
  ingress {
    description = "HTTPS"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Puerto del backend
  ingress {
    description = "Backend API Port"
    from_port   = 8000
    to_port     = 8000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Permitir todo el tráfico saliente
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.project_name}-sg"
  }
}

# IAM Role para EC2 (permite acceso a ECR)
resource "aws_iam_role" "ec2_ecr_role" {
  name = "${var.project_name}-ec2-ecr-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })

  tags = {
    Name = "${var.project_name}-ec2-role"
  }
}

# Attach policy para ECR
resource "aws_iam_role_policy_attachment" "ecr_policy" {
  role       = aws_iam_role.ec2_ecr_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
}

# Instance Profile
resource "aws_iam_instance_profile" "ec2_profile" {
  name = "${var.project_name}-ec2-profile"
  role = aws_iam_role.ec2_ecr_role.name
}

# User Data Script
locals {
  user_data = file("${path.module}/user-data.sh")
}

# EC2 Instance
resource "aws_instance" "dark_trifid" {
  ami           = data.aws_ami.amazon_linux_2.id
  instance_type = var.instance_type
  key_name      = var.key_name != "" ? var.key_name : null

  vpc_security_group_ids = [aws_security_group.dark_trifid_sg.id]
  iam_instance_profile   = aws_iam_instance_profile.ec2_profile.name

  user_data = local.user_data

  # Configuración del volumen raíz
  root_block_device {
    volume_size = 20  # GB
    volume_type = "gp3"
    encrypted   = true
  }

  tags = {
    Name        = var.project_name
    Environment = "production"
    ManagedBy   = "Terraform"
  }

  # Esperar a que la instancia esté completamente inicializada
  provisioner "local-exec" {
    command = "echo 'Instancia creada. IP Pública: ${self.public_ip}'"
  }
}

# Outputs
output "instance_id" {
  description = "ID de la instancia EC2"
  value       = aws_instance.dark_trifid.id
}

output "public_ip" {
  description = "IP pública de la instancia"
  value       = aws_instance.dark_trifid.public_ip
}

output "public_dns" {
  description = "DNS público de la instancia"
  value       = aws_instance.dark_trifid.public_dns
}

output "ssh_connection" {
  description = "Comando para conectarse por SSH"
  value       = var.key_name != "" ? "ssh -i ${var.key_name}.pem ec2-user@${aws_instance.dark_trifid.public_ip}" : "SSH key not configured"
}

output "application_url" {
  description = "URL de la aplicación"
  value       = "http://${aws_instance.dark_trifid.public_ip}"
}
