from fastapi import APIRouter

api_router = APIRouter()

# Import and include routers here
# Example:
# from app.api.endpoints import videos
# api_router.include_router(videos.router, prefix="/videos", tags=["videos"])


@api_router.get("/ping")
async def ping():
    return {"message": "pong"}
