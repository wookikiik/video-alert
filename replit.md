# Video Alert - Replit Project

## Overview
Video Alert is a full-stack web application built with Next.js (frontend) and FastAPI (backend). The application monitors a specified URL for video content and sends alerts via Telegram when changes are detected.

**Current Status**: Successfully migrated from Vercel to Replit (October 25, 2025)

## Recent Changes
- **October 25, 2025**: Migrated from Vercel to Replit
  - Configured Next.js to run on port 5000 with proper Replit host bindings
  - Updated backend CORS to support Replit wildcard domains
  - Installed all dependencies (Node.js and Python)
  - Configured environment variables via Replit Secrets
  - Set up admin token authentication
  - Configured deployment for Replit autoscale
  - Both frontend and backend workflows running successfully

## Project Architecture

### Frontend (Next.js 16.0.0)
- **Location**: `frontend/`
- **Framework**: Next.js with TypeScript
- **UI**: TailwindCSS v4, shadcn/ui components
- **Port**: 5000 (required for Replit)
- **Key Features**:
  - Modern React 19 with Server Components
  - Admin dashboard for system variable management
  - Responsive design with TailwindCSS

### Backend (FastAPI)
- **Location**: `backend/`
- **Framework**: FastAPI with Python 3.11
- **Port**: 8000
- **Key Features**:
  - RESTful API with automatic OpenAPI docs
  - Admin authentication via X-Admin-Token header
  - System variables management endpoint
  - Health check endpoint
  - CORS configured for Replit domains

### Database
- SQLite (development): `backend/dev.db`
- Configured via DATABASE_URL environment variable

## Environment Variables
All configured via Replit Secrets:
- `MONITORED_URL`: URL to monitor for video content
- `TELEGRAM_BOT_TOKEN`: Telegram bot authentication token
- `TELEGRAM_CHANNEL_ID`: Telegram channel ID for alerts
- `X_ADMIN_TOKEN`: Admin authentication token for API

## API Endpoints

### Public Endpoints
- `GET /` - Welcome message with API info
- `GET /health` - Health check
- `GET /api/v1/ping` - API ping test

### Admin Endpoints (requires X-Admin-Token header)
- `GET /api/v1/admin/system-variables` - Get system variables
- `PUT /api/v1/admin/system-variables` - Update system variables

### API Documentation
- Swagger UI: `http://localhost:8000/docs`
- ReDoc: `http://localhost:8000/redoc`

## Running Locally

### Frontend
```bash
cd frontend
npm install
npm run dev
```

### Backend
```bash
cd backend
pip install -r requirements.txt
uvicorn app.main:app --host 0.0.0.0 --port 8000 --reload
```

## Deployment
Configured for Replit autoscale deployment:
- Build: `cd frontend && npm run build`
- Run: Both backend and frontend start simultaneously
- Frontend serves on port 5000
- Backend API on port 8000

## Development Notes
- Frontend must run on port 5000 (Replit requirement)
- Backend uses custom CORS middleware to support wildcard Replit domains
- Admin authentication uses environment variable validation
- All sensitive data stored in Replit Secrets
- **Important**: If you change the frontend development port, you must also update the `ALLOWED_ORIGINS` list in `backend/app/core/config.py` to include the new port
