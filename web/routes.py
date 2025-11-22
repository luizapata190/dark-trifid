from fastapi import APIRouter, Request, Query
from fastapi.templating import Jinja2Templates
from database.repository import get_event_info
from services.catalog_service import get_schedule, get_filtered_speakers

router = APIRouter()
templates = Jinja2Templates(directory="web/templates")

@router.get("/")
async def index(request: Request, q: str = Query(None)):
    event_info = await get_event_info()
    schedule = await get_schedule(q)
    speakers = await get_filtered_speakers(q)
    
    return templates.TemplateResponse(
        "index.html", 
        {
            "request": request, 
            "event": event_info, 
            "schedule": schedule,
            "speakers": speakers,
            "query": q or ""
        }
    )
