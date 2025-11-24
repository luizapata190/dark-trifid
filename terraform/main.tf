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
  default     = "t2.micro"  # Free tier eligible
}

variable "key_name" {
  description = "Nombre del key pair para SSH"
  type        = string
  # Debes crear este key pair en AWS Console primero
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

  # Puerto personalizado (ajustar según tu aplicación)
  ingress {
    description = "Application Port"
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

# User Data Script
data "template_file" "user_data" {
  template = file("${path.module}/ec2-user-data.sh")
}

# EC2 Instance
resource "aws_instance" "dark_trifid" {
  ami           = data.aws_ami.amazon_linux_2.id
  instance_type = var.instance_type
  key_name      = var.key_name

  vpc_security_group_ids = [aws_security_group.dark_trifid_sg.id]

  user_data = data.template_file.user_data.rendered

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
  value       = "ssh -i ${var.key_name}.pem ec2-user@${aws_instance.dark_trifid.public_ip}"
}

output "application_url" {
  description = "URL de la aplicación"
  value       = "http://${aws_instance.dark_trifid.public_ip}"
}
