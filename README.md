# 🌐 Dark Trifid - Google Cloud Tech Week 2028

Aplicación web full-stack para **Google Cloud Tech Week 2028** con CI/CD automatizado y despliegue en AWS.

## 🎯 Características

- ✅ **Frontend:** Nginx con HTML/CSS/JavaScript
- ✅ **Backend:** FastAPI (Python) con arquitectura en capas
- ✅ **Contenedores:** Docker y Docker Compose
- ✅ **CI/CD:** GitHub Actions automatizado
- ✅ **Infraestructura:** Terraform + AWS (EC2, ECR, Elastic IP)
- ✅ **Deploy:** Automático via SSM (sin SSH keys)

---

## 📚 Documentación Completa

**👉 [DOCUMENTATION-INDEX.md](DOCUMENTATION-INDEX.md)** - Índice maestro de toda la documentación

### Guías Principales:

| Guía | Descripción |
|------|-------------|
| **[DEPLOYMENT.md](DEPLOYMENT.md)** | Métodos de despliegue |
| **[CI-CD-GUIDE.md](CI-CD-GUIDE.md)** | CI/CD con GitHub Actions |
| **[INFRASTRUCTURE-GUIDE.md](INFRASTRUCTURE-GUIDE.md)** | Infraestructura AWS con Terraform |
| **[LEARNING-GUIDE.md](LEARNING-GUIDE.md)** | Aprender conceptos fundamentales |
| **[ADAPTATION-GUIDE.md](ADAPTATION-GUIDE.md)** | Adaptar a otros proyectos |

---

## 🚀 Inicio Rápido

### Desarrollo Local

```bash
# 1. Clonar proyecto
git clone https://github.com/luizapata190/dark-trifid.git
cd dark-trifid

# 2. Iniciar con Docker Compose
docker compose up -d

# 3. Acceder
http://localhost:8888  # Frontend
http://localhost:8000  # Backend API
```

### Producción (AWS)

```bash
# 1. Configurar secrets en GitHub
AWS_ACCESS_KEY_ID
AWS_SECRET_ACCESS_KEY

# 2. Ejecutar workflow "Full Stack"
GitHub > Actions > Full Stack > create-and-deploy

# 3. Acceder
http://ELASTIC-IP  # IP fija que nunca cambia
```

---

## 🏗️ Arquitectura

### Local (Desarrollo)

```
Docker Compose
├── Frontend (Nginx) → localhost:8888
└── Backend (FastAPI) → localhost:8000
```

### Producción (AWS)

```
GitHub Actions (CI/CD)
    ↓
Amazon ECR (Imágenes Docker)
    ↓
AWS EC2 (Elastic IP)
├── Frontend → http://ELASTIC-IP
└── Backend → http://ELASTIC-IP/api
```

---

## 📋 Estructura del Proyecto

```
dark-trifid/
├── frontend/              # Frontend (Nginx)
│   ├── static/           # HTML, CSS, JS
│   └── Dockerfile
├── backend/              # Backend (FastAPI)
│   ├── main.py          # Punto de entrada
│   ├── database/        # Datos
│   ├── services/        # Lógica de negocio
│   └── Dockerfile
├── terraform/            # Infraestructura como código
│   ├── main.tf
│   ├── variables.tf
│   └── user-data.sh
├── .github/workflows/    # CI/CD
│   ├── full-stack.yml   # Infraestructura + Deploy
│   ├── deploy.yml       # Deploy automático
│   └── emergency-cleanup.yml
├── docker-compose.yml    # Local
├── docker-compose.prod.yml  # Producción
└── docs/                 # Documentación
```

---

## 🔄 Workflow de Desarrollo

### Día a Día:

```bash
# 1. Desarrollar localmente
docker compose up -d
# Editar archivos...
http://localhost:8888

# 2. Commit y push
git add .
git commit -m "feat: nueva funcionalidad"
git push origin main

# 3. Deploy automático
# GitHub Actions despliega a AWS automáticamente

# 4. Verificar en producción
http://ELASTIC-IP
```

---

## 🛠️ Tecnologías

### Frontend
- HTML5, CSS3, JavaScript
- Nginx (servidor web)

### Backend
- Python 3.11
- FastAPI (framework web)
- Uvicorn (servidor ASGI)

### DevOps
- Docker & Docker Compose
- GitHub Actions (CI/CD)
- Terraform (IaC)
- AWS (EC2, ECR, IAM, Elastic IP)

---

## 📊 Workflows Disponibles

| Workflow | Trigger | Propósito |
|----------|---------|-----------|
| **Full Stack** | Manual | Crear infraestructura + Deploy |
| **CD - Deploy to Production** | Push a `main` | Deploy automático |
| **CI - Pull Request Checks** | Pull Request | Validar código |
| **Emergency Cleanup** | Manual | Limpiar recursos AWS |

---

## 🌐 URLs

### Local:
- Frontend: `http://localhost:8888`
- Backend: `http://localhost:8000`
- API Docs: `http://localhost:8000/docs`

### Producción:
- Aplicación: `http://34.234.152.61` (Elastic IP)
- Repositorio: `https://github.com/luizapata190/dark-trifid`
- Actions: `https://github.com/luizapata190/dark-trifid/actions`

---

## 💡 Comandos Útiles

### Docker Compose (Local)

```bash
# Iniciar
docker compose up -d

# Ver logs
docker compose logs -f

# Parar
docker compose down

# Rebuild
docker compose up -d --build
```

### GitHub Actions

```bash
# Ver workflows
gh workflow list

# Ejecutar workflow
gh workflow run "Full Stack"

# Ver logs
gh run view <run-id> --log
```

### Terraform

```bash
# Inicializar
terraform init

# Planear cambios
terraform plan

# Aplicar cambios
terraform apply

# Destruir infraestructura
terraform destroy
```

---

## 📖 Documentación Detallada

Para información completa, consulta:

- **[DOCUMENTATION-INDEX.md](DOCUMENTATION-INDEX.md)** - Índice maestro
- **[LEARNING-GUIDE.md](LEARNING-GUIDE.md)** - Aprender conceptos
- **[ADAPTATION-GUIDE.md](ADAPTATION-GUIDE.md)** - Adaptar a otros proyectos
- **[CI-CD-GUIDE.md](CI-CD-GUIDE.md)** - CI/CD completo
- **[INFRASTRUCTURE-GUIDE.md](INFRASTRUCTURE-GUIDE.md)** - Infraestructura AWS

---

## 🤝 Contribuir

Este proyecto es una demostración de CI/CD profesional. Siéntete libre de:

- Usarlo como base para tus proyectos
- Adaptarlo a tus necesidades
- Aprender de la arquitectura
- Compartir mejoras

---

## 📝 Licencia

Este es un proyecto de demostración educativo.

---

## 🎓 Aprendizaje

Este proyecto demuestra:

✅ **Infraestructura como Código** (Terraform)  
✅ **CI/CD Automatizado** (GitHub Actions)  
✅ **Contenedores** (Docker)  
✅ **Cloud Computing** (AWS)  
✅ **DevOps Best Practices**  
✅ **Arquitectura Multi-Contenedor**  

---

**Desarrollado con ❤️ usando FastAPI, Docker y AWS**

**Última actualización:** 2025-11-25