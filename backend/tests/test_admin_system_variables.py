"""
Tests for admin system variables endpoint.
"""
import os
import pytest
from unittest.mock import patch


class TestSystemVariablesEndpoint:
    """Tests for GET /api/v1/admin/system-variables endpoint."""

    def test_get_system_variables_with_all_vars_set(self, client):
        """Test endpoint when all environment variables are set."""
        with patch.dict(os.environ, {
            "MONITORED_URL": "https://example.com/videos",
            "TELEGRAM_CHANNEL_ID": "@testchannel",
            "TELEGRAM_BOT_TOKEN": "123456:ABCdefGHIjkl"
        }):
            response = client.get("/api/v1/admin/system-variables")
            
            assert response.status_code == 200
            data = response.json()
            
            # Check structure
            assert "monitored_video_page_url" in data
            assert "telegram_channel_id" in data
            assert "telegram_bot_token" in data
            
            # Check monitored URL
            assert data["monitored_video_page_url"]["value"] == "https://example.com/videos"
            assert data["monitored_video_page_url"]["is_set"] is True
            assert "configured" in data["monitored_video_page_url"]["hint"].lower()
            
            # Check channel ID
            assert data["telegram_channel_id"]["value"] == "@testchannel"
            assert data["telegram_channel_id"]["is_set"] is True
            assert "configured" in data["telegram_channel_id"]["hint"].lower()
            
            # Check bot token (should be withheld)
            assert data["telegram_bot_token"]["value"] is None
            assert data["telegram_bot_token"]["is_set"] is True
            assert "withheld" in data["telegram_bot_token"]["hint"].lower()
    
    def test_get_system_variables_with_no_vars_set(self, client):
        """Test endpoint when no environment variables are set."""
        with patch.dict(os.environ, {}, clear=True):
            response = client.get("/api/v1/admin/system-variables")
            
            assert response.status_code == 200
            data = response.json()
            
            # All should be not set
            assert data["monitored_video_page_url"]["value"] is None
            assert data["monitored_video_page_url"]["is_set"] is False
            assert ".env" in data["monitored_video_page_url"]["hint"].lower()
            
            assert data["telegram_channel_id"]["value"] is None
            assert data["telegram_channel_id"]["is_set"] is False
            assert ".env" in data["telegram_channel_id"]["hint"].lower()
            
            assert data["telegram_bot_token"]["value"] is None
            assert data["telegram_bot_token"]["is_set"] is False
            assert ".env" in data["telegram_bot_token"]["hint"].lower()
    
    def test_get_system_variables_with_empty_string_vars(self, client):
        """Test endpoint when environment variables are empty strings."""
        with patch.dict(os.environ, {
            "MONITORED_URL": "",
            "TELEGRAM_CHANNEL_ID": "   ",  # whitespace only
            "TELEGRAM_BOT_TOKEN": ""
        }):
            response = client.get("/api/v1/admin/system-variables")
            
            assert response.status_code == 200
            data = response.json()
            
            # Empty strings should be treated as not set
            assert data["monitored_video_page_url"]["is_set"] is False
            assert data["telegram_channel_id"]["is_set"] is False
            assert data["telegram_bot_token"]["is_set"] is False
    
    def test_get_system_variables_partial_configuration(self, client):
        """Test endpoint with some variables set and others missing."""
        with patch.dict(os.environ, {
            "MONITORED_URL": "https://videos.example.com",
            # TELEGRAM_CHANNEL_ID not set
            "TELEGRAM_BOT_TOKEN": "secret-token-value"
        }, clear=True):
            response = client.get("/api/v1/admin/system-variables")
            
            assert response.status_code == 200
            data = response.json()
            
            # URL should be set and visible
            assert data["monitored_video_page_url"]["value"] == "https://videos.example.com"
            assert data["monitored_video_page_url"]["is_set"] is True
            
            # Channel ID should not be set
            assert data["telegram_channel_id"]["value"] is None
            assert data["telegram_channel_id"]["is_set"] is False
            
            # Bot token should be set but value withheld
            assert data["telegram_bot_token"]["value"] is None
            assert data["telegram_bot_token"]["is_set"] is True
    
    def test_bot_token_never_exposed(self, client):
        """Test that bot token value is NEVER exposed regardless of its value."""
        test_cases = [
            "short",
            "very-long-secret-token-value-that-should-never-be-returned",
            "123456:ABCdefGHIjklMNOpqrsTUVwxyz"
        ]
        
        for token_value in test_cases:
            with patch.dict(os.environ, {"TELEGRAM_BOT_TOKEN": token_value}):
                response = client.get("/api/v1/admin/system-variables")
                
                assert response.status_code == 200
                data = response.json()
                
                # Token value should NEVER be in the response
                assert data["telegram_bot_token"]["value"] is None
                assert data["telegram_bot_token"]["is_set"] is True
                assert token_value not in str(response.json())
    
    def test_response_schema_structure(self, client):
        """Test that response follows the expected schema structure."""
        with patch.dict(os.environ, {
            "MONITORED_URL": "https://test.com",
            "TELEGRAM_CHANNEL_ID": "@test",
            "TELEGRAM_BOT_TOKEN": "token123"
        }):
            response = client.get("/api/v1/admin/system-variables")
            
            assert response.status_code == 200
            data = response.json()
            
            # Each variable should have the required fields
            for var_name in ["monitored_video_page_url", "telegram_channel_id", "telegram_bot_token"]:
                assert var_name in data
                assert "value" in data[var_name]
                assert "is_set" in data[var_name]
                assert "hint" in data[var_name]
                
                # Check types
                assert isinstance(data[var_name]["is_set"], bool)
                assert isinstance(data[var_name]["hint"], str)
                # value can be string or None
                assert data[var_name]["value"] is None or isinstance(data[var_name]["value"], str)
    
    def test_numeric_channel_id_format(self, client):
        """Test that numeric channel IDs are returned correctly."""
        with patch.dict(os.environ, {
            "TELEGRAM_CHANNEL_ID": "-1001234567890"
        }):
            response = client.get("/api/v1/admin/system-variables")
            
            assert response.status_code == 200
            data = response.json()
            
            # Numeric channel ID should be returned as-is
            assert data["telegram_channel_id"]["value"] == "-1001234567890"
            assert data["telegram_channel_id"]["is_set"] is True
    
    def test_special_characters_in_values(self, client):
        """Test that special characters in URLs and channel IDs are handled correctly."""
        with patch.dict(os.environ, {
            "MONITORED_URL": "https://example.com/path?param=value&other=123",
            "TELEGRAM_CHANNEL_ID": "@channel_with_underscore"
        }):
            response = client.get("/api/v1/admin/system-variables")
            
            assert response.status_code == 200
            data = response.json()
            
            # Values with special characters should be preserved
            assert data["monitored_video_page_url"]["value"] == "https://example.com/path?param=value&other=123"
            assert data["telegram_channel_id"]["value"] == "@channel_with_underscore"
