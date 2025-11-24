from fastapi import APIRouter, Query
from database.repository import get_event_info
from services.catalog_service import get_schedule, get_filtered_speakers

router = APIRouter()

@router.get("/event")
async def get_event():
    """Get event information"""
    return await get_event_info()

@router.get("/schedule")
async def get_schedule_endpoint(q: str = Query(None)):
    """Get event schedule, optionally filtered by query"""
    return await get_schedule(q)

@router.get("/speakers")
async def get_speakers_endpoint(q: str = Query(None)):
    """Get speakers list, optionally filtered by query"""
    return await get_filtered_speakers(q)

@router.get("/health")
async def health_check():
    """Health check endpoint"""
    return {"status": "healthy", "service": "backend-api"}
