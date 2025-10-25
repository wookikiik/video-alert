# GitHub Copilot Instructions

This file provides instructions for GitHub Copilot coding agent when working on this repository.

## Project Overview

Video Alert is a full-stack application for monitoring websites and sending Telegram alerts when new videos are detected. The stack includes:
- **Backend**: FastAPI with Playwright for web scraping, SQLite database
- **Frontend**: Next.js 16 with React 19, Tailwind CSS v4, TypeScript
- **Deployment**: Docker Compose for production-like setup

## Quick Setup

### Backend Setup
```bash
./scripts/dev_backend.sh
```
This script handles virtual environment setup, dependency installation, Playwright browser installation, database initialization, and starts the development server on port 8000.

### Frontend Setup
```bash
./scripts/dev_frontend.sh
```
This script checks dependencies, creates environment file, and starts the Next.js development server on port 3000.

### Docker Setup
```bash
docker-compose up
```

## Development Commands

### Backend Commands (from `backend/` directory)
- **Run server**: `uvicorn app.main:app --reload --host 0.0.0.0 --port 8000` (with virtual environment activated)
- **Initialize database**: `python scripts/init_db.py` (from repository root)
- **Run tests**: `pytest` or `pytest -v` for verbose output
- **Run specific test**: `pytest tests/test_api.py::test_health_check -v`
- **Install Playwright browsers**: `python -m playwright install`

### Frontend Commands (from `frontend/` directory)
- **Run dev server**: `npm run dev`
- **Build for production**: `npm run build`
- **Run production build**: `npm start`
- **Lint code**: `npm run lint`
- **Type check**: `npx tsc --noEmit`

## Architecture

### Backend Architecture
- **Main app**: `backend/app/main.py` - FastAPI application entry point with CORS configuration
- **API routing**: All endpoints prefixed with `/api/v1`
- **Admin endpoints**: `backend/app/api/endpoints/admin.py` - System variables and scheduling management
- **Configuration**: `backend/app/core/config.py` - Pydantic Settings for environment variables
- **Database**: SQLite (`backend/dev.db`) with SQLAlchemy ORM, async support via aiosqlite
- **Tables**: `videos`, `alert_logs`, `scheduler_runs`
- **Scheduler**: APScheduler for periodic video monitoring (when `SCHEDULER_ENABLED=true`)
- **Web scraping**: Playwright for browser automation

### Frontend Architecture
- **Framework**: Next.js 16 with App Router (not Pages Router)
- **UI Library**: React 19 with React Server Components
- **Styling**: Tailwind CSS v4 via `@tailwindcss/postcss`, shadcn/ui components
- **Icons**: Lucide React
- **Type Safety**: TypeScript
- **Main layout**: `frontend/src/app/layout.tsx`
- **Homepage**: `frontend/src/app/page.tsx`
- **Components**: `frontend/src/components/`
- **Utilities**: `frontend/src/lib/`

## Coding Standards

### Backend
- Use Python 3.11+ features
- Follow PEP 8 style guidelines
- Use type hints for function signatures
- Use Pydantic models for request/response validation
- Always work within a virtual environment
- Use async/await for database operations
- Never commit `.env` files

### Frontend
- Use TypeScript for all new files
- Follow Next.js 16 App Router patterns (not Pages Router)
- Use React Server Components by default; add `"use client"` directive only when needed
- Use Tailwind CSS v4 for styling (not v3)
- Use functional components with hooks
- Prefer arrow functions for component definitions
- Use meaningful, descriptive variable names

## Environment Configuration

### Backend `.env` (never commit this file)
Required environment variables:
- `DATABASE_URL`: SQLite connection string
- `MONITORED_URL`: Website URL to monitor
- `TELEGRAM_BOT_TOKEN`: Bot token from @BotFather
- `TELEGRAM_CHANNEL_ID`: Channel/group ID for alerts
- `SCHEDULER_ENABLED`: Enable/disable background scheduler (true/false)
- `SCHEDULER_INTERVAL`: Check interval in seconds (default: 300)

### Frontend `.env.local` (never commit this file)
- `NEXT_PUBLIC_API_BASE_URL`: Backend API base URL (default: `http://localhost:8000`)

## Testing Requirements

### Backend
- Run tests before committing: `cd backend && pytest -v`
- Tests located in `backend/tests/`
- Use separate test database for isolation
- Key test files: `conftest.py` (fixtures), `test_api.py` (API endpoint tests)
- Coverage: `pytest --cov=app`

### Frontend
- No test framework currently configured
- When adding tests, use Jest + React Testing Library for component tests
- For E2E tests, consider Playwright or Cypress

## Important Implementation Details

### CORS Configuration
CORS is configured in `backend/app/main.py` using FastAPI's CORSMiddleware. Allowed origins include localhost:3000, localhost:3001, and 127.0.0.1 equivalents.

### API Routing
All API endpoints are prefixed with `/api/v1`. The main router in `backend/app/api/__init__.py` includes sub-routers from the endpoints directory.

### Playwright Requirements
- Requires separate browser binary installation: `python -m playwright install`
- Runs in headless mode by default
- Set `PLAYWRIGHT_HEADLESS=false` for debugging with visible browser window
- On Linux, may need: `python -m playwright install --with-deps`

### Next.js Specifics
- Environment variables are loaded on startup; restart dev server after changes
- Variables prefixed with `NEXT_PUBLIC_` are exposed to the browser
- Uses Tailwind CSS v4 (configuration via `@tailwindcss/postcss`, not `tailwind.config.js`)
- Clear cache on issues: `rm -rf .next && npm run dev`

## Development Workflow

1. **Start backend first**: Frontend depends on backend API
2. **Always use virtual environment** for Python commands
3. **Run database initialization** after schema changes: `python scripts/init_db.py` (idempotent)
4. **Test API changes** at `http://localhost:8000/docs` (interactive API documentation)
5. **Run linters** before committing (backend: pytest, frontend: `npm run lint`)
6. **Type check TypeScript**: `npx tsc --noEmit` before committing
7. **Check CORS**: If API calls fail, verify CORS middleware allows frontend origin
8. **Default ports**: Backend on 8000, Frontend on 3000

## Troubleshooting

- **Backend issues**: See `docs/DEV_SETUP_BACKEND.md` for Playwright installation, SQLite errors, port conflicts, and missing environment variables
- **Frontend issues**: See `docs/DEV_SETUP_FRONTEND.md` for CORS issues, environment variables, Node version mismatches, and port conflicts

## Key File Locations

**Backend**:
- Main app: `backend/app/main.py`
- Configuration: `backend/app/core/config.py`
- API routes: `backend/app/api/endpoints/*.py`
- Database models: `backend/app/models/`
- Schemas: `backend/app/schemas/`
- Tests: `backend/tests/`
- Requirements: `backend/requirements.txt`

**Frontend**:
- App entry: `frontend/src/app/layout.tsx`
- Homepage: `frontend/src/app/page.tsx`
- Components: `frontend/src/components/`
- Utilities: `frontend/src/lib/`
- Package config: `frontend/package.json`

**Configuration**:
- Docker: `docker-compose.yml` (root)
- Backend env: `backend/.env` (not committed, use `.env.example` as template)
- Frontend env: `frontend/.env.local` (not committed)
- Development scripts: `scripts/dev_backend.sh`, `scripts/dev_frontend.sh`, `scripts/init_db.py`

## Additional Documentation

- Backend setup guide: `docs/DEV_SETUP_BACKEND.md`
- Frontend setup guide: `docs/DEV_SETUP_FRONTEND.md`
- API documentation: Available at `http://localhost:8000/docs` when backend is running
- Main README: `README.md`
- Product requirements: `docs/prd.md`
- Technical specifications: `docs/tech.md`
