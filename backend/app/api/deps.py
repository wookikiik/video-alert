"""
Dependencies for API endpoints.
"""
from typing import Annotated
from fastapi import Header, HTTPException, status


async def get_current_admin(
    x_admin_token: Annotated[str | None, Header()] = None
) -> bool:
    """
    Simple admin authentication dependency.
    
    For now, this is a placeholder that checks for a basic admin token.
    In production, this should be replaced with proper authentication
    (e.g., JWT tokens, OAuth, etc.).
    
    Args:
        x_admin_token: Admin token from request header
        
    Returns:
        True if authenticated
        
    Raises:
        HTTPException: If authentication fails
    """
    # For development/demo: accept any non-empty token
    # In production, validate against secure token storage
    if not x_admin_token or x_admin_token.strip() == "":
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Not authenticated. Admin token required.",
            headers={"WWW-Authenticate": "Bearer"},
        )
    
    # Placeholder: In production, verify token against database/config
    # For now, any non-empty token is accepted for development purposes
    return True
