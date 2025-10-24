"""
Pydantic schemas for system variables endpoint.
"""
from pydantic import BaseModel, ConfigDict, Field


class SystemVariableDetail(BaseModel):
    """
    Details about a single system variable.
    
    Attributes:
        value: The actual environment variable value (null if withheld for security)
        is_set: Whether the environment variable exists and is non-empty
        hint: Human-friendly message about the variable status
    """
    value: str | None = Field(
        description="The environment variable value, or null if withheld for security"
    )
    is_set: bool = Field(
        description="True if the environment variable exists and is non-empty"
    )
    hint: str = Field(
        description="Human-friendly message about the variable status"
    )


class SystemVariablesResponse(BaseModel):
    """
    Response model for system variables endpoint.
    
    Returns read-only system configuration values that admins need to view.
    Secrets like bot tokens are never exposed - only their presence is indicated.
    """
    monitored_video_page_url: SystemVariableDetail = Field(
        description="The URL of the video page being monitored"
    )
    telegram_channel_id: SystemVariableDetail = Field(
        description="The Telegram channel ID where notifications are sent"
    )
    telegram_bot_token: SystemVariableDetail = Field(
        description="Telegram bot token status (value always withheld for security)"
    )
    
    model_config = ConfigDict(
        json_schema_extra={
            "example": {
                "monitored_video_page_url": {
                    "value": "https://example.com/videos",
                    "is_set": True,
                    "hint": "Currently monitoring this URL"
                },
                "telegram_channel_id": {
                    "value": "@mychannel",
                    "is_set": True,
                    "hint": "Notifications sent to this channel"
                },
                "telegram_bot_token": {
                    "value": None,
                    "is_set": True,
                    "hint": "Set (value withheld for security)"
                }
            }
        }
    )
