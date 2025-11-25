# 🗄️ Guía de Bases de Datos: RDS vs Contenedor

## 🎯 La Pregunta Clave

**¿Debo usar Amazon RDS o un contenedor Docker para mi base de datos?**

**Respuesta corta:** Depende del ambiente y la criticidad de los datos.

---

## 📊 Comparación Rápida

| Característica | RDS (AWS) | Contenedor Docker |
|----------------|-----------|-------------------|
| **Costo** | ~$15-50/mes | Incluido en EC2 |
| **Backups** | ✅ Automáticos | ⚠️ Manuales |
| **Escalabilidad** | ✅ Fácil | ⚠️ Limitada |
| **Mantenimiento** | ✅ AWS lo hace | ❌ Tú lo haces |
| **Performance** | ✅ Optimizado | ⚠️ Depende de EC2 |
| **Alta Disponibilidad** | ✅ Multi-AZ | ❌ Single point of failure |
| **Setup** | ⚠️ Más complejo | ✅ Simple |
| **Desarrollo Local** | ⚠️ Difícil | ✅ Fácil |

---

## 🎯 Recomendación por Escenario

### Usa **Contenedor Docker** si:

```
✅ Desarrollo/Testing
✅ Prototipo/MVP
✅ Presupuesto muy limitado
✅ Datos no críticos
✅ Tráfico bajo (<1000 usuarios/día)
✅ Aprendiendo/Experimentando
```

### Usa **Amazon RDS** si:

```
✅ Producción
✅ Datos críticos
✅ Necesitas backups automáticos
✅ Alta disponibilidad requerida
✅ Tráfico medio-alto (>1000 usuarios/día)
✅ Cumplimiento regulatorio
✅ Equipo sin experiencia en DB admin
```

---

## 💰 Análisis de Costos

### Opción 1: Contenedor Docker en EC2

```
EC2 t3.micro:           $8.50/mes
Base de datos:          $0.00 (incluida en EC2)
Backups:                $0.00 (si usas volúmenes)
Total:                  ~$8.50/mes
```

**Ventajas:**
- ✅ Muy económico
- ✅ Todo en un solo servidor
- ✅ Simple para proyectos pequeños

**Desventajas:**
- ❌ Si EC2 falla, pierdes todo
- ❌ Backups manuales
- ❌ Difícil de escalar

### Opción 2: RDS Separado

```
EC2 t3.micro:           $8.50/mes
RDS db.t3.micro:        $15.00/mes
Backups (20GB):         $2.00/mes
Total:                  ~$25.50/mes
```

**Ventajas:**
- ✅ Backups automáticos
- ✅ Alta disponibilidad
- ✅ Fácil de escalar
- ✅ AWS gestiona mantenimiento

**Desventajas:**
- ❌ Más caro (3x)
- ❌ Setup más complejo
- ❌ Desarrollo local diferente

---

## 🏗️ Arquitectura Recomendada

### Desarrollo/Staging: Contenedor Docker

```
┌─────────────────────────────────┐
│  EC2 (t3.micro)                 │
│                                 │
│  ┌──────────┐  ┌─────────────┐ │
│  │ Frontend │  │  Backend    │ │
│  └──────────┘  └─────────────┘ │
│                      ↓          │
│              ┌─────────────┐   │
│              │ PostgreSQL  │   │
│              │ (Contenedor)│   │
│              └─────────────┘   │
│                      ↓          │
│              ┌─────────────┐   │
│              │  Volumen    │   │
│              │ (Persistente)│  │
│              └─────────────┘   │
└─────────────────────────────────┘
```

### Producción: RDS Separado

```
┌─────────────────────────────────┐
│  EC2 (t3.micro)                 │
│                                 │
│  ┌──────────┐  ┌─────────────┐ │
│  │ Frontend │  │  Backend    │ │
│  └──────────┘  └─────────────┘ │
│                      ↓          │
└──────────────────────┼──────────┘
                       ↓
        ┌──────────────────────────┐
        │  Amazon RDS              │
        │  ┌────────────────────┐  │
        │  │  PostgreSQL        │  │
        │  │  (Multi-AZ)        │  │
        │  └────────────────────┘  │
        │         ↓                │
        │  ┌────────────────────┐  │
        │  │  Backups Automáticos│ │
        │  └────────────────────┘  │
        └──────────────────────────┘
```

---

## 🐳 Implementación: Contenedor Docker

### `docker-compose.yml`

```yaml
version: '3.8'

services:
  backend:
    build: ./backend
    ports: ["8000:8000"]
    environment:
      - DATABASE_URL=postgresql://postgres:secreto@database:5432/mydb
    depends_on:
      - database
    networks:
      - app-network
  
  database:
    image: postgres:15
    container_name: mi-postgres
    environment:
      - POSTGRES_USER=postgres
      - POSTGRES_PASSWORD=secreto
      - POSTGRES_DB=mydb
    ports:
      - "5432:5432"
    volumes:
      # Persistencia de datos
      - db-data:/var/lib/postgresql/data
      # Backups (opcional)
      - ./backups:/backups
    networks:
      - app-network
    restart: unless-stopped
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U postgres"]
      interval: 10s
      timeout: 5s
      retries: 5

volumes:
  db-data:
    driver: local

networks:
  app-network:
    driver: bridge
```

### Script de Backup Manual

```bash
#!/bin/bash
# backup-db.sh

DATE=$(date +%Y%m%d_%H%M%S)
BACKUP_DIR="/backups"
CONTAINER="mi-postgres"

# Crear backup
docker exec $CONTAINER pg_dump -U postgres mydb > $BACKUP_DIR/backup_$DATE.sql

# Comprimir
gzip $BACKUP_DIR/backup_$DATE.sql

# Eliminar backups antiguos (más de 7 días)
find $BACKUP_DIR -name "backup_*.sql.gz" -mtime +7 -delete

echo "Backup completado: backup_$DATE.sql.gz"
```

### Cron para Backups Automáticos

```bash
# Agregar a crontab
crontab -e

# Backup diario a las 2 AM
0 2 * * * /home/ec2-user/backup-db.sh
```

---

## ☁️ Implementación: Amazon RDS

### Terraform para RDS

```hcl
# terraform/rds.tf

# Security Group para RDS
resource "aws_security_group" "rds_sg" {
  name        = "${var.project_name}-rds-sg"
  description = "Security group para RDS"
  vpc_id      = aws_default_vpc.default.id

  # Permitir conexiones desde EC2
  ingress {
    description     = "PostgreSQL from EC2"
    from_port       = 5432
    to_port         = 5432
    protocol        = "tcp"
    security_groups = [aws_security_group.dark_trifid_sg.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.project_name}-rds-sg"
  }
}

# Subnet Group para RDS
resource "aws_db_subnet_group" "main" {
  name       = "${var.project_name}-db-subnet"
  subnet_ids = data.aws_subnets.default.ids

  tags = {
    Name = "${var.project_name}-db-subnet"
  }
}

# RDS Instance
resource "aws_db_instance" "postgres" {
  identifier = "${var.project_name}-db"

  # Engine
  engine         = "postgres"
  engine_version = "15.3"

  # Instance
  instance_class    = "db.t3.micro"  # Free tier eligible
  allocated_storage = 20
  storage_type      = "gp3"
  storage_encrypted = true

  # Database
  db_name  = var.db_name
  username = var.db_username
  password = var.db_password

  # Network
  db_subnet_group_name   = aws_db_subnet_group.main.name
  vpc_security_group_ids = [aws_security_group.rds_sg.id]
  publicly_accessible    = false  # Solo accesible desde EC2

  # Backups
  backup_retention_period = 7  # 7 días de backups
  backup_window          = "03:00-04:00"  # 3-4 AM
  maintenance_window     = "Mon:04:00-Mon:05:00"

  # Monitoring
  enabled_cloudwatch_logs_exports = ["postgresql", "upgrade"]
  monitoring_interval             = 60
  monitoring_role_arn            = aws_iam_role.rds_monitoring.arn

  # High Availability (opcional, más caro)
  multi_az = false  # Cambiar a true para producción

  # Performance
  performance_insights_enabled = true

  # Deletion protection
  deletion_protection = true  # Prevenir eliminación accidental
  skip_final_snapshot = false
  final_snapshot_identifier = "${var.project_name}-final-snapshot"

  tags = {
    Name        = "${var.project_name}-db"
    Environment = "production"
  }
}

# IAM Role para Monitoring
resource "aws_iam_role" "rds_monitoring" {
  name = "${var.project_name}-rds-monitoring"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "monitoring.rds.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "rds_monitoring" {
  role       = aws_iam_role.rds_monitoring.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonRDSEnhancedMonitoringRole"
}

# Outputs
output "rds_endpoint" {
  description = "RDS endpoint"
  value       = aws_db_instance.postgres.endpoint
}

output "rds_connection_string" {
  description = "Connection string"
  value       = "postgresql://${var.db_username}:${var.db_password}@${aws_db_instance.postgres.endpoint}/${var.db_name}"
  sensitive   = true
}
```

### Variables para RDS

```hcl
# terraform/variables.tf

variable "db_name" {
  description = "Nombre de la base de datos"
  type        = string
  default     = "mydb"
}

variable "db_username" {
  description = "Usuario de la base de datos"
  type        = string
  default     = "dbadmin"
  sensitive   = true
}

variable "db_password" {
  description = "Contraseña de la base de datos"
  type        = string
  sensitive   = true
}
```

### Usar RDS en la Aplicación

```yaml
# docker-compose.prod.yml

services:
  backend:
    image: ${ECR_REGISTRY}/dark-trifid-backend:latest
    environment:
      # Usar RDS endpoint
      - DATABASE_URL=${RDS_CONNECTION_STRING}
    # No necesitas contenedor de database
```

---

## 🔄 Estrategia Híbrida (Recomendada)

### Desarrollo: Contenedor

```yaml
# docker-compose.yml (local)
services:
  database:
    image: postgres:15
    # Para desarrollo local
```

### Staging: Contenedor

```yaml
# docker-compose.staging.yml
services:
  database:
    image: postgres:15
    volumes:
      - db-data:/var/lib/postgresql/data
    # Para testing
```

### Producción: RDS

```hcl
# terraform/main.tf
resource "aws_db_instance" "postgres" {
  # RDS para producción
}
```

---

## 📊 Tabla de Decisión

### Por Tamaño de Proyecto

| Tamaño | Usuarios/Día | Datos | Recomendación |
|--------|--------------|-------|---------------|
| **Pequeño** | <100 | <1GB | Contenedor Docker |
| **Mediano** | 100-1000 | 1-10GB | Contenedor + Backups |
| **Grande** | 1000-10000 | 10-100GB | RDS db.t3.small |
| **Muy Grande** | >10000 | >100GB | RDS db.t3.medium+ |

### Por Presupuesto

| Presupuesto/Mes | Recomendación |
|-----------------|---------------|
| **<$10** | Contenedor en EC2 |
| **$10-$30** | Contenedor + Backups a S3 |
| **$30-$100** | RDS db.t3.micro |
| **>$100** | RDS db.t3.small+ con Multi-AZ |

### Por Criticidad de Datos

| Criticidad | Recomendación |
|------------|---------------|
| **Baja** (datos de prueba) | Contenedor |
| **Media** (datos recuperables) | Contenedor + Backups |
| **Alta** (datos importantes) | RDS con backups |
| **Crítica** (datos vitales) | RDS Multi-AZ + Réplicas |

---

## 🎯 Migración: Contenedor → RDS

### Paso 1: Crear RDS con Terraform

```bash
cd terraform/
terraform apply
```

### Paso 2: Exportar Datos del Contenedor

```bash
# Backup desde contenedor
docker exec mi-postgres pg_dump -U postgres mydb > backup.sql
```

### Paso 3: Importar a RDS

```bash
# Conectar a RDS
psql -h RDS-ENDPOINT -U dbadmin -d mydb < backup.sql
```

### Paso 4: Actualizar Aplicación

```yaml
# docker-compose.prod.yml
services:
  backend:
    environment:
      - DATABASE_URL=postgresql://dbadmin:pass@RDS-ENDPOINT:5432/mydb
  
  # Eliminar servicio database
  # database:  # Ya no necesario
```

### Paso 5: Deploy

```bash
git push origin main
# Deploy automático usa RDS
```

---

## 💡 Mejores Prácticas

### Para Contenedor Docker:

```
✅ Usar volúmenes para persistencia
✅ Backups automáticos con cron
✅ Monitorear espacio en disco
✅ Logs de PostgreSQL
✅ Health checks
✅ Restart policy
```

### Para RDS:

```
✅ Habilitar backups automáticos
✅ Usar secrets para credenciales
✅ Monitorear con CloudWatch
✅ Habilitar encryption
✅ Multi-AZ para producción
✅ Performance Insights
```

---

## 🚨 Advertencias

### Contenedor Docker:

```
⚠️ Si EC2 falla, pierdes la BD
⚠️ Backups son tu responsabilidad
⚠️ Difícil de escalar verticalmente
⚠️ Requiere experiencia en DB admin
```

### RDS:

```
⚠️ Más caro (3x mínimo)
⚠️ Desarrollo local diferente
⚠️ Vendor lock-in con AWS
⚠️ Menos control sobre configuración
```

---

## ✅ Recomendación Final

### Para Dark Trifid (tu proyecto actual):

**Fase 1: Aprendizaje/Desarrollo**
```
✅ Usar Contenedor Docker
✅ Costo: ~$8/mes
✅ Simple y rápido
```

**Fase 2: MVP/Primeros Usuarios**
```
✅ Contenedor Docker + Backups
✅ Costo: ~$10/mes
✅ Agregar script de backups
```

**Fase 3: Producción Real**
```
✅ Migrar a RDS
✅ Costo: ~$25/mes
✅ Backups automáticos
✅ Alta disponibilidad
```

---

## 📚 Recursos Adicionales

- [AWS RDS Pricing](https://aws.amazon.com/rds/pricing/)
- [PostgreSQL Docker](https://hub.docker.com/_/postgres)
- [RDS Best Practices](https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/CHAP_BestPractices.html)

---

**Última actualización:** 2025-11-25
