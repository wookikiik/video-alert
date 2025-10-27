"""
Admin endpoints for system configuration and management.
"""
from fastapi import APIRouter

from app.core.config import settings
from app.schemas.system_variables import SystemVariablesResponse, SystemVariableDetail


router = APIRouter()


def _get_system_variable_detail(
    env_var_name: str,
) -> SystemVariableDetail:
    """
    Get details about a system environment variable.

    Args:
        env_var_name: The name of the environment variable in settings
        is_secret: Whether this variable contains secret data

    Returns:
        SystemVariableDetail with value, is_set status, and hint
    """
    value = getattr(settings, env_var_name, None)
    if value is not None:
        value = str(value)
    
    # Check if the variable is set (exists and non-empty)
    is_set = value is not None and value.strip() != ""
    
    # For non-secret variables, return the value if set
    if is_set:
        return SystemVariableDetail(
            value=value,
            is_set=True,
            hint="Currently configured"
        )
    else:
        return SystemVariableDetail(
            value=None,
            is_set=False,
            hint="Not set — update server .env file"
        )


@router.get(
    "/system-variables",
    response_model=SystemVariablesResponse,
    summary="Get system variables",
    description=(
        "Returns read-only system configuration values including monitored URL "
        "and Telegram settings. Secret values (like bot tokens) are never exposed, "
        "only their presence is indicated."
    )
)
async def get_system_variables() -> SystemVariablesResponse:
    """
    Get current system variables for admin dashboard.

    Returns configuration values that are set via environment variables:
    - Monitored video page URL
    - Telegram channel ID
    - Telegram bot token status (value never exposed)
    """
    return SystemVariablesResponse(
        monitored_video_page_url=_get_system_variable_detail("MONITORED_URL"),
        telegram_channel_id=_get_system_variable_detail("TELEGRAM_CHANNEL_ID"),
        telegram_bot_token=_get_system_variable_detail("TELEGRAM_BOT_TOKEN")
    )
