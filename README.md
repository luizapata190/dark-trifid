# Sitio Web de Conferencia Google Cloud

Este proyecto es un sitio web informativo para una conferencia técnica de un día sobre tecnologías de Google Cloud. 
Construido con **FastAPI** (Python) y una arquitectura en capas profesional.

## Características

- **Página de Inicio**: Muestra información del evento, ubicación y fecha.
- **Agenda**: Lista de 8 charlas con detalles y ponentes.
- **Búsqueda**: Funcionalidad para buscar charlas por título, ponente o categoría.
- **Diseño Responsivo**: Adaptado a dispositivos móviles y de escritorio.
- **Arquitectura Limpia**: Separación de responsabilidades (Datos, Servicios, Web).

## Estructura del Proyecto

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

## Requisitos Previos

- Python 3.9+
- [Poetry](https://python-poetry.org/docs/#installation) (Gestor de paquetes)
- Docker y Docker Compose (Opcional, recomendado para Rancher Desktop)

## Configuración y Ejecución Local (Sin Docker)

1.  **Instalar dependencias con Poetry:**

    ```bash
    poetry install
    ```

2.  **Ejecutar la aplicación:**

    ```bash
    poetry run uvicorn main:app --reload
    ```

3.  **Acceder al sitio:**
    Abre tu navegador y visita `http://localhost:8000`.
    
    *Nota: También puedes ver la documentación automática de la API en `http://localhost:8000/docs`.*

## Ejecución con Docker (Rancher Desktop)

1.  **Construir y levantar el contenedor:**

    ```bash
    docker-compose up --build
    ```

2.  **Acceder al sitio:**
    Visita `http://localhost:8000` en tu navegador.

3.  **Detener el contenedor:**
    Presiona `Ctrl+C` o ejecuta:

    ```bash
    docker-compose down
    ```
