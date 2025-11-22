from fastapi import FastAPI
from fastapi.staticfiles import StaticFiles
from web.routes import router as web_router
import uvicorn

app = FastAPI(title="Google Cloud Tech Day 2025")

# Montar archivos estáticos
app.mount("/static", StaticFiles(directory="web/static"), name="static")

# Incluir rutas
app.include_router(web_router)

if __name__ == "__main__":
    uvicorn.run("main:app", host="0.0.0.0", port=8000, reload=True)
