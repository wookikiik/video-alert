from fastapi import APIRouter
from app.api.endpoints import admin

api_router = APIRouter()

# Include admin router
api_router.include_router(admin.router, prefix="/admin", tags=["admin"])


@api_router.get("/ping")
async def ping():
    return {"message": "pong"}
