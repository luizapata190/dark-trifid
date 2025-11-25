# 🎓 Guía de Aprendizaje: CI/CD y Docker

## 📚 Índice

1. [¿Qué son los archivos .yml?](#qué-son-los-archivos-yml)
2. [Docker Compose (.yml)](#docker-compose-yml)
3. [GitHub Actions Workflows (.yml)](#github-actions-workflows-yml)
4. [Terraform (.tf vs .yml)](#terraform-tf-vs-yml)
5. [Adaptación a Otros Proyectos](#adaptación-a-otros-proyectos)
6. [Ejemplos Prácticos](#ejemplos-prácticos)

---

## 🔍 ¿Qué son los archivos .yml?

### Definición

**YAML** = "YAML Ain't Markup Language" (YAML no es un lenguaje de marcado)

Es un formato de **configuración legible por humanos** usado para:
- Configurar aplicaciones
- Definir workflows
- Describir infraestructura
- Especificar dependencias

### Sintaxis Básica

```yaml
# Comentario (línea que empieza con #)

# Clave-Valor simple
nombre: Juan
edad: 30

# Lista (array)
frutas:
  - manzana
  - banana
  - naranja

# Objeto anidado
persona:
  nombre: María
  edad: 25
  ciudad: Bogotá

# Lista de objetos
empleados:
  - nombre: Pedro
    cargo: Developer
  - nombre: Ana
    cargo: Designer

# Booleanos
activo: true
verificado: false

# Números
precio: 99.99
cantidad: 5

# Strings multilínea
descripcion: |
  Esta es una descripción
  que ocupa múltiples líneas
  y mantiene los saltos de línea
```

### Reglas Importantes

```yaml
# ✅ CORRECTO - Indentación con espacios (2 o 4)
persona:
  nombre: Juan
  edad: 30

# ❌ INCORRECTO - No mezclar espacios y tabs
persona:
	nombre: Juan  # Tab
  edad: 30      # Espacios

# ✅ CORRECTO - Comillas opcionales para strings
nombre: Juan
ciudad: "Bogotá"

# ✅ CORRECTO - Listas con guión
frutas:
  - manzana
  - banana

# ✅ CORRECTO - Listas inline
frutas: [manzana, banana, naranja]
```

---

## 🐳 Docker Compose (.yml)

### ¿Qué es Docker Compose?

Herramienta para **definir y ejecutar aplicaciones multi-contenedor**.

### Estructura de `docker-compose.yml`

```yaml
version: '3.8'  # Versión de Docker Compose

services:  # Lista de contenedores
  
  # Servicio 1: Base de datos
  database:
    image: postgres:15  # Imagen de Docker Hub
    container_name: mi-postgres
    environment:
      - POSTGRES_PASSWORD=secreto
      - POSTGRES_DB=midb
    ports:
      - "5432:5432"  # Puerto host:contenedor
    volumes:
      - db-data:/var/lib/postgresql/data  # Persistencia
    networks:
      - app-network
    restart: unless-stopped  # Auto-reinicio
  
  # Servicio 2: Backend
  backend:
    build:  # Construir desde Dockerfile
      context: ./backend
      dockerfile: Dockerfile
    container_name: mi-backend
    ports:
      - "8000:8000"
    environment:
      - DATABASE_URL=postgresql://user:pass@database:5432/midb
    depends_on:  # Espera a que database inicie
      - database
    volumes:
      - ./backend:/app  # Hot reload (desarrollo)
    networks:
      - app-network
  
  # Servicio 3: Frontend
  frontend:
    build:
      context: ./frontend
    container_name: mi-frontend
    ports:
      - "80:80"
    depends_on:
      - backend
    networks:
      - app-network

# Volúmenes (persistencia de datos)
volumes:
  db-data:

# Redes (comunicación entre contenedores)
networks:
  app-network:
    driver: bridge
```

### Comandos Docker Compose

```bash
# Iniciar todos los servicios
docker compose up

# Iniciar en background
docker compose up -d

# Reconstruir imágenes
docker compose up --build

# Ver logs
docker compose logs
docker compose logs -f  # Seguir logs en tiempo real
docker compose logs backend  # Logs de un servicio

# Ver estado
docker compose ps

# Parar servicios
docker compose stop

# Parar y eliminar
docker compose down

# Parar, eliminar y limpiar volúmenes
docker compose down -v

# Reiniciar un servicio
docker compose restart backend

# Ejecutar comando en contenedor
docker compose exec backend bash
```

### Diferencias: Desarrollo vs Producción

#### `docker-compose.yml` (Desarrollo)

```yaml
services:
  backend:
    build: ./backend  # Construye desde código
    volumes:
      - ./backend:/app  # Hot reload
    environment:
      - DEBUG=true
      - LOG_LEVEL=debug
```

#### `docker-compose.prod.yml` (Producción)

```yaml
services:
  backend:
    image: registry.com/backend:latest  # Usa imagen pre-construida
    # Sin volúmenes (código en la imagen)
    environment:
      - DEBUG=false
      - LOG_LEVEL=error
    restart: unless-stopped  # Auto-reinicio
```

---

## ⚙️ GitHub Actions Workflows (.yml)

### ¿Qué son GitHub Actions?

Sistema de **CI/CD integrado en GitHub** para automatizar:
- Build
- Tests
- Deploy
- Validaciones

### Estructura de un Workflow

```yaml
name: CI/CD Pipeline  # Nombre del workflow

# Cuándo se ejecuta
on:
  push:
    branches: [main]  # En push a main
  pull_request:
    branches: [main]  # En PR a main
  workflow_dispatch:  # Manual

# Variables de entorno globales
env:
  NODE_VERSION: '18'
  AWS_REGION: us-east-1

# Jobs (trabajos)
jobs:
  
  # Job 1: Build
  build:
    runs-on: ubuntu-latest  # Máquina virtual
    
    steps:  # Pasos del job
      
      # Paso 1: Checkout código
      - name: Checkout code
        uses: actions/checkout@v4  # Acción pre-construida
      
      # Paso 2: Setup Node.js
      - name: Setup Node.js
        uses: actions/setup-node@v4
        with:
          node-version: ${{ env.NODE_VERSION }}
      
      # Paso 3: Instalar dependencias
      - name: Install dependencies
        run: npm install  # Comando shell
      
      # Paso 4: Build
      - name: Build
        run: npm run build
      
      # Paso 5: Upload artifact
      - name: Upload build
        uses: actions/upload-artifact@v4
        with:
          name: build-files
          path: dist/
  
  # Job 2: Test (corre en paralelo con build)
  test:
    runs-on: ubuntu-latest
    
    steps:
      - uses: actions/checkout@v4
      
      - name: Setup Node.js
        uses: actions/setup-node@v4
        with:
          node-version: ${{ env.NODE_VERSION }}
      
      - name: Install dependencies
        run: npm install
      
      - name: Run tests
        run: npm test
  
  # Job 3: Deploy (espera a build y test)
  deploy:
    needs: [build, test]  # Dependencias
    runs-on: ubuntu-latest
    if: github.ref == 'refs/heads/main'  # Solo en main
    
    steps:
      - uses: actions/checkout@v4
      
      - name: Download build
        uses: actions/download-artifact@v4
        with:
          name: build-files
          path: dist/
      
      - name: Deploy to server
        env:
          SSH_KEY: ${{ secrets.SSH_KEY }}  # Secret de GitHub
        run: |
          echo "Deploying to production..."
          # Comandos de deploy
```

### Conceptos Clave

#### 1. Triggers (on)

```yaml
# Push a ramas específicas
on:
  push:
    branches: [main, develop]

# Pull Request
on:
  pull_request:
    branches: [main]

# Manual
on:
  workflow_dispatch:

# Scheduled (cron)
on:
  schedule:
    - cron: '0 0 * * *'  # Diario a medianoche

# Múltiples triggers
on:
  push:
    branches: [main]
  pull_request:
    branches: [main]
  workflow_dispatch:
```

#### 2. Jobs y Steps

```yaml
jobs:
  mi-job:
    runs-on: ubuntu-latest
    
    steps:
      # Usar acción pre-construida
      - uses: actions/checkout@v4
      
      # Ejecutar comando
      - name: Run command
        run: echo "Hello World"
      
      # Ejecutar múltiples comandos
      - name: Multiple commands
        run: |
          echo "Line 1"
          echo "Line 2"
          npm install
      
      # Condicional
      - name: Only on main
        if: github.ref == 'refs/heads/main'
        run: echo "This is main branch"
```

#### 3. Secrets

```yaml
steps:
  - name: Use secret
    env:
      API_KEY: ${{ secrets.API_KEY }}
      DB_PASSWORD: ${{ secrets.DB_PASSWORD }}
    run: |
      echo "Using secrets..."
      # Los secrets NO se muestran en logs
```

#### 4. Artifacts

```yaml
# Subir artifact
- name: Upload
  uses: actions/upload-artifact@v4
  with:
    name: my-artifact
    path: dist/

# Descargar artifact (en otro job)
- name: Download
  uses: actions/download-artifact@v4
  with:
    name: my-artifact
    path: dist/
```

#### 5. Outputs

```yaml
jobs:
  job1:
    runs-on: ubuntu-latest
    outputs:
      version: ${{ steps.get-version.outputs.version }}
    
    steps:
      - id: get-version
        run: echo "version=1.0.0" >> $GITHUB_OUTPUT
  
  job2:
    needs: job1
    runs-on: ubuntu-latest
    steps:
      - run: echo "Version is ${{ needs.job1.outputs.version }}"
```

---

## 🏗️ Terraform (.tf vs .yml)

### ¿Por qué Terraform usa .tf y no .yml?

**Terraform** usa su propio lenguaje: **HCL** (HashiCorp Configuration Language)

```hcl
# Terraform (.tf)
resource "aws_instance" "web" {
  ami           = "ami-12345678"
  instance_type = "t3.micro"
  
  tags = {
    Name = "WebServer"
  }
}
```

**Ventajas de HCL:**
- Más expresivo para infraestructura
- Soporta variables y funciones
- Mejor para lógica compleja

**Algunos usan YAML con Terraform:**
```yaml
# terraform.tfvars.yml (no estándar)
instance_type: t3.micro
region: us-east-1
```

---

## 🔄 Adaptación a Otros Proyectos

### Principios Universales

```
1. Dockerfile → Define cómo construir la imagen
2. docker-compose.yml → Define cómo ejecutar localmente
3. .github/workflows/*.yml → Define CI/CD
4. Terraform → Define infraestructura en AWS
```

**Estos 4 elementos se adaptan a CUALQUIER proyecto.**

---

## 📦 Ejemplos Prácticos

### 1. API REST en Python (FastAPI)

#### Estructura del Proyecto

```
mi-api-python/
├── app/
│   ├── main.py
│   ├── models.py
│   └── routes.py
├── requirements.txt
├── Dockerfile
├── docker-compose.yml
└── .github/
    └── workflows/
        └── deploy.yml
```

#### `Dockerfile`

```dockerfile
FROM python:3.11-slim

WORKDIR /app

COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

COPY app/ ./app/

CMD ["uvicorn", "app.main:app", "--host", "0.0.0.0", "--port", "8000"]
```

#### `docker-compose.yml`

```yaml
version: '3.8'

services:
  api:
    build: .
    container_name: mi-api
    ports:
      - "8000:8000"
    environment:
      - DATABASE_URL=postgresql://user:pass@db:5432/mydb
    depends_on:
      - db
    volumes:
      - ./app:/app/app  # Hot reload
    networks:
      - api-network
  
  db:
    image: postgres:15
    container_name: mi-db
    environment:
      - POSTGRES_PASSWORD=secreto
      - POSTGRES_DB=mydb
    ports:
      - "5432:5432"
    volumes:
      - db-data:/var/lib/postgresql/data
    networks:
      - api-network

volumes:
  db-data:

networks:
  api-network:
```

#### `.github/workflows/deploy.yml`

```yaml
name: Deploy API

on:
  push:
    branches: [main]

env:
  AWS_REGION: us-east-1
  ECR_REPOSITORY: mi-api

jobs:
  deploy:
    runs-on: ubuntu-latest
    
    steps:
      - uses: actions/checkout@v4
      
      - name: Configure AWS
        uses: aws-actions/configure-aws-credentials@v4
        with:
          aws-access-key-id: ${{ secrets.AWS_ACCESS_KEY_ID }}
          aws-secret-access-key: ${{ secrets.AWS_SECRET_ACCESS_KEY }}
          aws-region: ${{ env.AWS_REGION }}
      
      - name: Login to ECR
        id: login-ecr
        uses: aws-actions/amazon-ecr-login@v2
      
      - name: Build and Push
        env:
          ECR_REGISTRY: ${{ steps.login-ecr.outputs.registry }}
        run: |
          docker build -t $ECR_REGISTRY/$ECR_REPOSITORY:latest .
          docker push $ECR_REGISTRY/$ECR_REPOSITORY:latest
      
      - name: Deploy to EC2
        run: |
          # SSH a EC2 y actualizar contenedor
          # (similar a dark-trifid)
```

---

### 2. Juego en Unity

#### Estructura

```
mi-juego-unity/
├── Assets/
├── ProjectSettings/
├── Dockerfile (para build server)
├── docker-compose.yml (servidor de juego)
└── .github/
    └── workflows/
        ├── build-game.yml
        └── deploy-server.yml
```

#### `docker-compose.yml` (Servidor de Juego)

```yaml
version: '3.8'

services:
  game-server:
    build:
      context: .
      dockerfile: Dockerfile.server
    container_name: unity-server
    ports:
      - "7777:7777/udp"  # Puerto del juego
      - "8080:8080"      # API/Dashboard
    environment:
      - SERVER_NAME=Mi Servidor
      - MAX_PLAYERS=20
    volumes:
      - ./server-data:/data
    restart: unless-stopped
```

#### `.github/workflows/build-game.yml`

```yaml
name: Build Unity Game

on:
  push:
    branches: [main]
    tags: ['v*']

jobs:
  build-windows:
    runs-on: windows-latest
    
    steps:
      - uses: actions/checkout@v4
      
      - name: Cache Library
        uses: actions/cache@v3
        with:
          path: Library
          key: Library-${{ hashFiles('Assets/**') }}
      
      - name: Build Windows
        uses: game-ci/unity-builder@v4
        with:
          targetPlatform: StandaloneWindows64
          unityVersion: 2022.3.0f1
      
      - name: Upload Build
        uses: actions/upload-artifact@v4
        with:
          name: windows-build
          path: build/StandaloneWindows64/
  
  build-linux-server:
    runs-on: ubuntu-latest
    
    steps:
      - uses: actions/checkout@v4
      
      - name: Build Linux Server
        uses: game-ci/unity-builder@v4
        with:
          targetPlatform: StandaloneLinux64
          unityVersion: 2022.3.0f1
      
      - name: Build Docker Image
        run: |
          docker build -t game-server:latest .
          # Push a registry
```

---

### 3. Juego en Unreal Engine

#### Estructura

```
mi-juego-unreal/
├── Content/
├── Source/
├── Config/
├── Dockerfile.server
├── docker-compose.yml
└── .github/
    └── workflows/
        └── build-and-deploy.yml
```

#### `docker-compose.yml`

```yaml
version: '3.8'

services:
  unreal-server:
    build:
      context: .
      dockerfile: Dockerfile.server
    container_name: unreal-dedicated-server
    ports:
      - "7777:7777/udp"  # Game port
      - "27015:27015/udp"  # Steam port
    environment:
      - SERVER_PASSWORD=secreto
      - MAX_PLAYERS=32
      - MAP_NAME=MyMap
    volumes:
      - ./server-config:/config
      - ./server-logs:/logs
    restart: unless-stopped
```

#### `Dockerfile.server`

```dockerfile
FROM ubuntu:22.04

# Instalar dependencias de Unreal
RUN apt-get update && apt-get install -y \
    wget \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

# Copiar binarios del servidor
COPY Server/ /server/

WORKDIR /server

# Exponer puertos
EXPOSE 7777/udp 27015/udp

# Comando de inicio
CMD ["./MyGameServer.sh", "-log"]
```

#### `.github/workflows/build-and-deploy.yml`

```yaml
name: Build Unreal Server

on:
  push:
    branches: [main]

jobs:
  build:
    runs-on: windows-latest  # Unreal requiere Windows para build
    
    steps:
      - uses: actions/checkout@v4
      
      - name: Setup Unreal Engine
        run: |
          # Configurar UE (requiere licencia)
          # Esto es complejo, normalmente se usa un runner self-hosted
      
      - name: Build Dedicated Server
        run: |
          # Comando de build de UE
          RunUAT.bat BuildCookRun -project=MyGame.uproject -platform=Linux -configuration=Development -cook -server -serverconfig=Development -build -stage -pak -archive -archivedirectory=Server
      
      - name: Upload Server Build
        uses: actions/upload-artifact@v4
        with:
          name: linux-server
          path: Server/
  
  deploy:
    needs: build
    runs-on: ubuntu-latest
    
    steps:
      - uses: actions/checkout@v4
      
      - name: Download Server Build
        uses: actions/download-artifact@v4
        with:
          name: linux-server
          path: Server/
      
      - name: Build Docker Image
        run: |
          docker build -t unreal-server:latest -f Dockerfile.server .
      
      - name: Push to Registry
        run: |
          docker push registry.com/unreal-server:latest
      
      - name: Deploy to EC2
        run: |
          # Deploy similar a dark-trifid
```

---

## 🎯 Tabla Comparativa: Adaptación por Tipo de Proyecto

| Tipo de Proyecto | Dockerfile | docker-compose.yml | GitHub Actions | Terraform |
|------------------|------------|-------------------|----------------|-----------|
| **Web App (React/Vue)** | ✅ Nginx + Build | ✅ Frontend + Backend | ✅ Build + Deploy | ✅ EC2 + S3 |
| **API REST (Python/Node)** | ✅ Python/Node | ✅ API + DB | ✅ Tests + Deploy | ✅ EC2 + RDS |
| **Juego Unity** | ✅ Server Build | ✅ Game Server | ✅ Build Game | ✅ EC2 Gaming |
| **Juego Unreal** | ✅ Dedicated Server | ✅ Server + Config | ✅ Build (Windows) | ✅ EC2 Gaming |
| **Mobile App** | ❌ No necesario | ❌ No necesario | ✅ Build APK/IPA | ❌ Solo S3/CDN |
| **Machine Learning** | ✅ Python + GPU | ✅ Jupyter + GPU | ✅ Train + Deploy | ✅ EC2 GPU |

---

## 📚 Recursos de Aprendizaje

### Docker
- [Docker Docs](https://docs.docker.com/)
- [Docker Compose Docs](https://docs.docker.com/compose/)

### GitHub Actions
- [GitHub Actions Docs](https://docs.github.com/en/actions)
- [Awesome Actions](https://github.com/sdras/awesome-actions)

### Terraform
- [Terraform Docs](https://www.terraform.io/docs)
- [Terraform AWS Provider](https://registry.terraform.io/providers/hashicorp/aws/latest/docs)

### YAML
- [YAML Tutorial](https://www.cloudbees.com/blog/yaml-tutorial-everything-you-need-get-started)
- [YAML Validator](https://www.yamllint.com/)

---

## 🎓 Ejercicios Prácticos

### Ejercicio 1: Crear API Simple

1. Crear API REST en Python con FastAPI
2. Crear Dockerfile
3. Crear docker-compose.yml con PostgreSQL
4. Crear workflow de GitHub Actions
5. Desplegar a AWS EC2

### Ejercicio 2: Modificar Dark Trifid

1. Agregar Redis para caché
2. Agregar servicio de email
3. Crear workflow de staging
4. Implementar tests automáticos

### Ejercicio 3: Proyecto Nuevo

1. Elegir un tipo de proyecto (API, juego, etc.)
2. Adaptar los archivos .yml
3. Configurar CI/CD
4. Desplegar a AWS

---

**Última actualización:** 2025-11-25
