# System Variables API Documentation

## Overview

The System Variables API provides a secure, read-only endpoint for admin users to view environment configuration values. This endpoint is designed to allow the frontend admin dashboard to display current system configuration without exposing sensitive secrets.

## Endpoint

### GET /api/v1/admin/system-variables

Returns current system environment variable values for:
- Monitored video page URL
- Telegram channel ID  
- Telegram bot token status (presence only, value never exposed)

## Authentication

All requests must include an admin authentication token in the request header:

```
X-Admin-Token: your-admin-token-here
```

**Note:** The current implementation uses a simple token-based authentication for development. In production, this should be replaced with a more robust authentication mechanism (JWT, OAuth, etc.).

## Request Example

```bash
curl -H "X-Admin-Token: admin-token" \
  http://localhost:8000/api/v1/admin/system-variables
```

## Response Schema

```json
{
  "monitored_video_page_url": {
    "value": "string | null",
    "is_set": "boolean",
    "hint": "string"
  },
  "telegram_channel_id": {
    "value": "string | null",
    "is_set": "boolean",
    "hint": "string"
  },
  "telegram_bot_token": {
    "value": null,
    "is_set": "boolean",
    "hint": "string"
  }
}
```

### Field Descriptions

- **value**: The actual environment variable value. For non-secret values, this contains the configured value if set. For secret values (like bot tokens), this is always `null`.
- **is_set**: Boolean indicating whether the environment variable exists and is non-empty.
- **hint**: Human-friendly message describing the current state of the variable.

## Response Examples

### All Variables Configured

```json
{
  "monitored_video_page_url": {
    "value": "https://example.com/videos",
    "is_set": true,
    "hint": "Currently configured"
  },
  "telegram_channel_id": {
    "value": "@mychannel",
    "is_set": true,
    "hint": "Currently configured"
  },
  "telegram_bot_token": {
    "value": null,
    "is_set": true,
    "hint": "Set (value withheld for security)"
  }
}
```

### No Variables Configured

```json
{
  "monitored_video_page_url": {
    "value": null,
    "is_set": false,
    "hint": "Not set — update server .env file"
  },
  "telegram_channel_id": {
    "value": null,
    "is_set": false,
    "hint": "Not set — update server .env file"
  },
  "telegram_bot_token": {
    "value": null,
    "is_set": false,
    "hint": "Not set — update server .env file"
  }
}
```

## Error Responses

### 401 Unauthorized

Missing or invalid authentication token:

```json
{
  "detail": "Not authenticated. Admin token required."
}
```

## Security Considerations

### Secret Protection

The endpoint implements strict security measures:

1. **Bot Token Never Exposed**: The `telegram_bot_token` value is ALWAYS `null`, regardless of whether it's set. Only the presence (via `is_set`) is indicated.

2. **Generic Secret Detection**: Any environment variable with "TOKEN" or "SECRET" in its name is treated as a secret and its value is withheld.

3. **Authentication Required**: All requests must provide valid admin credentials.

### Safe Values

The following values are considered safe to return:
- Monitored video page URL (public URL)
- Telegram channel ID (can be a public channel identifier)

These values are returned as-is when configured.

## Environment Variables

The endpoint reads the following environment variables at request time:

| Variable Name | Description | Example Value |
|--------------|-------------|---------------|
| `MONITORED_URL` | URL of the video page to monitor | `https://example.com/videos` |
| `TELEGRAM_CHANNEL_ID` | Telegram channel where alerts are sent | `@mychannel` or `-1001234567890` |
| `TELEGRAM_BOT_TOKEN` | Telegram bot authentication token (SECRET) | `123456:ABCdefGHIjklMNOpqrsTUVwxyz` |

## Usage in Frontend

The frontend admin dashboard can use this endpoint to:

1. Display current configuration values to admins
2. Show validation status of required environment variables
3. Provide helpful hints when variables are not configured
4. Confirm that sensitive values (like bot tokens) are properly configured without exposing them

### Example React/TypeScript Integration

```typescript
interface SystemVariableDetail {
  value: string | null;
  is_set: boolean;
  hint: string;
}

interface SystemVariablesResponse {
  monitored_video_page_url: SystemVariableDetail;
  telegram_channel_id: SystemVariableDetail;
  telegram_bot_token: SystemVariableDetail;
}

async function fetchSystemVariables(): Promise<SystemVariablesResponse> {
  const response = await fetch('/api/v1/admin/system-variables', {
    headers: {
      'X-Admin-Token': getAdminToken(), // Your auth token logic
    },
  });
  
  if (!response.ok) {
    throw new Error('Failed to fetch system variables');
  }
  
  return response.json();
}
```

## Testing

Comprehensive tests are available in `backend/tests/test_admin_system_variables.py`.

Run tests with:
```bash
pytest tests/test_admin_system_variables.py -v
```

## Future Enhancements

Potential improvements for production:

1. Replace simple token auth with JWT or OAuth
2. Add role-based access control (RBAC)
3. Implement rate limiting
4. Add audit logging for access
5. Support for additional configuration values
6. Environment variable validation/linting

## Support

For issues or questions, please refer to:
- Backend README: `backend/README.md`
- Main project docs: `docs/`
- Issue tracker: [GitHub Issues](https://github.com/wookikiik/video-alert/issues)
