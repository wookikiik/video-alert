"""
Dependencies for API endpoints.
"""
import os
from typing import Annotated
from fastapi import Header, HTTPException, status


async def get_current_admin(
    x_admin_token: Annotated[str | None, Header()] = None
) -> bool:
    """
    Simple admin authentication dependency.
    
    Validates admin token against environment variable.
    
    Args:
        x_admin_token: Admin token from request header
        
    Returns:
        True if authenticated
        
    Raises:
        HTTPException: If authentication fails
    """
    if not x_admin_token or x_admin_token.strip() == "":
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Not authenticated. Admin token required.",
            headers={"WWW-Authenticate": "Bearer"},
        )
    
    expected_token = os.getenv("X_ADMIN_TOKEN", "")
    if x_admin_token != expected_token:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Invalid admin token.",
            headers={"WWW-Authenticate": "Bearer"},
        )
    
    return True
