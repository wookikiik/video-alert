from pydantic_settings import BaseSettings, SettingsConfigDict
from typing import List


class Settings(BaseSettings):
    model_config = SettingsConfigDict(
        env_file=".env",
        case_sensitive=True,
        extra="allow"
    )
    PROJECT_NAME: str = "Video Alert API"
    VERSION: str = "1.0.0"
    API_V1_PREFIX: str = "/api/v1"

    # Database
    DATABASE_URL: str = "sqlite:///./dev.db"

    # Monitoring
    MONITORED_URL: str = "https://example.com/videos"

    # Telegram
    TELEGRAM_BOT_TOKEN: str = "your_bot_token_here"
    TELEGRAM_CHANNEL_ID: str = "@your_channel_id"

    # Scheduler
    SCHEDULER_ENABLED: bool = True
    SCHEDULER_INTERVAL: int = 300

    # Environment
    ENVIRONMENT: str = "development"
    DEBUG: bool = True

    # CORS
    ALLOWED_ORIGINS: List[str] = [
        "http://localhost:3000",
        "http://localhost:3001",
        "http://127.0.0.1:3000",
        "http://127.0.0.1:3001",
    ]


settings = Settings()
