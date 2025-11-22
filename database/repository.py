# Datos ficticios del evento
EVENT_INFO = {
    "title": "Google Cloud Tech Day 2025",
    "date": "15 de Noviembre, 2025",
    "location": "Centro de Convenciones Tech, Ciudad de México",
    "description": "Un día completo dedicado a explorar las últimas innovaciones en Google Cloud Platform."
}

# Datos ficticios de los ponentes
SPEAKERS = {
    "s1": {"name": "Ana García", "role": "Cloud Architect", "linkedin": "https://linkedin.com/in/fake-ana-garcia"},
    "s2": {"name": "Carlos López", "role": "Data Engineer", "linkedin": "https://linkedin.com/in/fake-carlos-lopez"},
    "s3": {"name": "María Rodríguez", "role": "ML Specialist", "linkedin": "https://linkedin.com/in/fake-maria-rodriguez"},
    "s4": {"name": "Javier Martínez", "role": "DevOps Engineer", "linkedin": "https://linkedin.com/in/fake-javier-martinez"},
    "s5": {"name": "Sofia Hernández", "role": "Security Expert", "linkedin": "https://linkedin.com/in/fake-sofia-hernandez"},
    "s6": {"name": "Miguel Torres", "role": "Product Manager", "linkedin": "https://linkedin.com/in/fake-miguel-torres"},
    "s7": {"name": "Laura Díaz", "role": "Software Engineer", "linkedin": "https://linkedin.com/in/fake-laura-diaz"},
    "s8": {"name": "David Ruiz", "role": "CTO", "linkedin": "https://linkedin.com/in/fake-david-ruiz"},
}

# Datos ficticios de las charlas
TALKS = [
    {
        "id": "t1",
        "title": "Keynote: El Futuro de la Nube",
        "speakers": ["s8"],
        "category": "General",
        "description": "Visión general de las tendencias y el futuro de Google Cloud.",
        "time": "09:00 - 10:00"
    },
    {
        "id": "t2",
        "title": "Arquitecturas Serverless Escalables",
        "speakers": ["s1", "s7"],
        "category": "Infraestructura",
        "description": "Cómo construir aplicaciones que escalan automáticamente con Cloud Run y Functions.",
        "time": "10:15 - 11:00"
    },
    {
        "id": "t3",
        "title": "BigQuery para Analítica en Tiempo Real",
        "speakers": ["s2"],
        "category": "Data",
        "description": "Estrategias para procesar y analizar grandes volúmenes de datos al instante.",
        "time": "11:15 - 12:00"
    },
    {
        "id": "t4",
        "title": "Machine Learning con Vertex AI",
        "speakers": ["s3"],
        "category": "AI/ML",
        "description": "Desarrollo y despliegue de modelos de ML simplificado.",
        "time": "12:15 - 13:00"
    },
    {
        "id": "lunch",
        "title": "Almuerzo y Networking",
        "speakers": [],
        "category": "Break",
        "description": "Tiempo libre para comer y conectar con otros asistentes.",
        "time": "13:00 - 14:00"
    },
    {
        "id": "t5",
        "title": "Seguridad en la Nube: Mejores Prácticas",
        "speakers": ["s5"],
        "category": "Seguridad",
        "description": "Protegiendo tus cargas de trabajo en GCP.",
        "time": "14:00 - 14:45"
    },
    {
        "id": "t6",
        "title": "Kubernetes: De Cero a Héroe",
        "speakers": ["s4", "s1"],
        "category": "Infraestructura",
        "description": "Domina la orquestación de contenedores con GKE.",
        "time": "15:00 - 15:45"
    },
    {
        "id": "t7",
        "title": "Innovación con Generative AI",
        "speakers": ["s3", "s6"],
        "category": "AI/ML",
        "description": "Casos de uso prácticos de IA generativa en empresas.",
        "time": "16:00 - 16:45"
    },
    {
        "id": "t8",
        "title": "Cierre y Conclusiones",
        "speakers": ["s6"],
        "category": "General",
        "description": "Resumen del día y pasos a seguir.",
        "time": "17:00 - 17:30"
    }
]

async def get_event_info():
    return EVENT_INFO

async def get_all_talks():
    return TALKS

async def get_speaker_by_id(speaker_id):
    return SPEAKERS.get(speaker_id)

async def get_all_speakers():
    return list(SPEAKERS.values())
