import re
from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from app.core.config import settings
from app.api import api_router

app = FastAPI(
    title=settings.PROJECT_NAME,
    version=settings.VERSION,
    description="Video Alert API"
)

# Configure CORS with support for Replit wildcard domains
class CustomCORSMiddleware(CORSMiddleware):
    def is_allowed_origin(self, origin: str) -> bool:
        for allowed_origin in self.allow_origins:
            if allowed_origin == "*":
                return True
            if allowed_origin.startswith("https://*."):
                domain = allowed_origin.replace("https://*.", "")
                if re.match(rf"^https://.*\.{re.escape(domain)}$", origin):
                    return True
            elif origin == allowed_origin:
                return True
        return False

app.add_middleware(
    CustomCORSMiddleware,
    allow_origins=settings.ALLOWED_ORIGINS,
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Include API router
app.include_router(api_router, prefix=settings.API_V1_PREFIX)


@app.get("/")
async def root():
    return {
        "message": "Welcome to Video Alert API",
        "version": settings.VERSION,
        "docs": "/docs"
    }


@app.get("/health")
async def health_check():
    return {"status": "healthy"}
