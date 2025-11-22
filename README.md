# Google Cloud Tech Week 2028

Sitio web informativo para **Google Cloud Tech Week 2028** - una semana completa dedicada a explorar las últimas innovaciones en Google Cloud Platform.

Construido con **FastAPI** (Python) y una arquitectura en capas profesional.

## 🎯 Características

- **Página de Inicio**: Información del evento, ubicación y fecha
- **Agenda**: Lista de 8 charlas con detalles y ponentes
- **Búsqueda**: Funcionalidad para buscar charlas por título, ponente o categoría
- **Diseño Responsivo**: Adaptado a dispositivos móviles y de escritorio
- **Arquitectura Limpia**: Separación de responsabilidades (Datos, Servicios, Web)

## 📁 Estructura del Proyecto

```text
/
├── database/              # Capa de Datos (Repositorio)
├── services/              # Capa de Negocio (Lógica)
├── web/                   # Capa de Presentación (Rutas, Templates, Static)
├── main.py                # Punto de entrada (FastAPI)
├── pyproject.toml         # Gestión de dependencias (Poetry)
├── Dockerfile             # Configuración Docker
└── docker-compose.yml     # Orquestación
```

## 📋 Requisitos Previos

- Python 3.9+
- [Poetry](https://python-poetry.org/docs/#installation) (Gestor de paquetes)
- Docker y Docker Compose (Recomendado para deployment)

## 🚀 Ejecución Local (Sin Docker)

### 1. Instalar dependencias

```bash
poetry install
```

### 2. Ejecutar la aplicación

```bash
poetry run uvicorn main:app --reload
```

### 3. Acceder al sitio

- **Aplicación**: http://localhost:8000
- **Documentación API**: http://localhost:8000/docs

## 🐳 Ejecución con Docker

### Comandos principales

```bash
# Construir y levantar (desarrollo)
docker-compose up --build -d

# Ver logs en tiempo real
docker-compose logs -f

# Verificar estado
docker-compose ps

# Parar y eliminar contenedores
docker-compose down
```

### Acceder al sitio

- **URL**: http://localhost:8001

> **Nota**: El puerto está mapeado a 8001 en el host para evitar conflictos.

### Solución de problemas

```bash
# Reconstruir desde cero (sin caché)
docker-compose down
docker-compose build --no-cache
docker-compose up -d

# Limpiar recursos Docker no utilizados
docker system prune
```

## 🛠️ Desarrollo

### Hacer cambios en el código

1. Edita los archivos necesarios
2. Reconstruye y reinicia Docker:
   ```bash
   docker-compose up --build -d
   ```
3. Refresca el navegador con **Ctrl + Shift + R** (forzar sin caché)

### Estructura de archivos clave

- **`database/repository.py`**: Datos del evento y charlas
- **`services/catalog_service.py`**: Lógica de búsqueda y filtrado
- **`web/routes.py`**: Rutas de la aplicación
- **`web/templates/`**: Plantillas HTML (Jinja2)
- **`web/static/`**: CSS y archivos estáticos

## 📦 Dependencias

- **FastAPI**: Framework web moderno y rápido
- **Uvicorn**: Servidor ASGI de alto rendimiento
- **Jinja2**: Motor de plantillas
- **Python-multipart**: Manejo de formularios

## 🔧 Configuración de Poetry

Este proyecto usa `package-mode = false` porque es una aplicación web, no un paquete distribuible. Requiere **Poetry 1.8.0+**.

## 📝 Notas

- Los datos de charlas y ponentes son ficticios para demostración
- El proyecto está dockerizado para fácil deployment en Rancher Desktop o cualquier entorno Docker
- La aplicación usa FastAPI con templates HTML (no es una SPA)

## 🤝 Contribuir

Este es un proyecto de demostración. Siéntete libre de usarlo como base para tus propios eventos.

---

**Desarrollado con ❤️ usando FastAPI y Docker**
