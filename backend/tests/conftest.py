"""
Pytest configuration and fixtures for testing.
"""
import pytest
from fastapi.testclient import TestClient
from app.main import app


@pytest.fixture
def client():
    """
    Test client for making requests to the API.
    """
    return TestClient(app)


@pytest.fixture
def admin_headers():
    """
    Headers with admin authentication token.
    """
    return {"X-Admin-Token": "test-admin-token"}
