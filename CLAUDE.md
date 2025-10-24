# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Video Alert is a full-stack application for monitoring websites and sending Telegram alerts when new videos are detected. The project uses FastAPI for the backend with Playwright for web scraping, and Next.js 16 with React 19 for the frontend.

## Development Commands

### Quick Start

**Backend**:
```bash
./scripts/dev_backend.sh
```
This script handles virtual environment setup, dependency installation, Playwright browser installation, database initialization, and starts the development server.

**Frontend**:
```bash
./scripts/dev_frontend.sh
```
This script checks dependencies, creates environment file, and starts the Next.js development server.

**Docker (recommended for production-like setup)**:
```bash
docker-compose up
```

### Backend Development

**Run server** (from `backend/` directory):
```bash
# With virtual environment activated
uvicorn app.main:app --reload --host 0.0.0.0 --port 8000
```

**Initialize database** (from repository root):
```bash
python scripts/init_db.py
```

**Run tests**:
```bash
cd backend
pytest
pytest -v  # verbose
pytest tests/test_api.py  # specific test file
```

**Install Playwright browsers** (required for web scraping):
```bash
cd backend
python -m playwright install
# Or specific browser: python -m playwright install chromium
```

### Frontend Development

**Run dev server** (from `frontend/` directory):
```bash
npm run dev
```

**Build for production**:
```bash
npm run build
npm start  # run production build
```

**Lint code**:
```bash
npm run lint
```

**Type check**:
```bash
npx tsc --noEmit
```

### Running Single Tests

**Backend**:
```bash
# Run specific test function
pytest tests/test_api.py::test_health_check -v

# Run specific test class
pytest tests/test_api.py::TestAdminEndpoints -v

# Run with output
pytest tests/test_api.py -v -s
```

**Frontend**: No test framework currently configured in package.json.

## Architecture

### Backend Architecture

**Request Flow**:
1. FastAPI application (`backend/app/main.py`) receives HTTP requests
2. CORS middleware configured in `main.py` for frontend access
3. Requests routed through `app.api.api_router` with `/api/v1` prefix
4. Admin endpoints in `backend/app/api/endpoints/admin.py` handle system configuration
5. Configuration loaded from `backend/app/core/config.py` using Pydantic Settings
6. Environment variables read from `backend/.env` file

**Key Components**:
- **FastAPI app** (`backend/app/main.py`): Main application entry point with CORS configuration
- **API router** (`backend/app/api/__init__.py`): Aggregates all endpoint routers
- **Admin endpoints** (`backend/app/api/endpoints/admin.py`): System variables and scheduling management
- **Configuration** (`backend/app/core/config.py`): Pydantic Settings for environment variables
- **Database**: SQLite with SQLAlchemy ORM (models to be defined in `backend/app/models/`)
- **Scheduler**: APScheduler for periodic video monitoring (when `SCHEDULER_ENABLED=true`)
- **Web scraping**: Playwright for browser automation

**Database**:
- SQLite database (default: `backend/dev.db`)
- Tables: `videos`, `alert_logs`, `scheduler_runs` (created by `scripts/init_db.py`)
- SQLAlchemy used for ORM
- Async support via aiosqlite

**Environment Configuration**:
Backend requires `backend/.env` file with:
- `DATABASE_URL`: SQLite connection string
- `MONITORED_URL`: Website URL to monitor
- `TELEGRAM_BOT_TOKEN`: Bot token from @BotFather
- `TELEGRAM_CHANNEL_ID`: Channel/group ID for alerts
- `SCHEDULER_ENABLED`: Enable/disable background scheduler
- `SCHEDULER_INTERVAL`: Check interval in seconds (default: 300)

### Frontend Architecture

**Next.js App Router Structure**:
- Uses Next.js 16 with App Router (not Pages Router)
- TypeScript for type safety
- React 19 with React Server Components
- Main layout: `frontend/src/app/layout.tsx`
- Homepage: `frontend/src/app/page.tsx`

**Styling**:
- Tailwind CSS v4 configured via `@tailwindcss/postcss`
- Global styles in `frontend/src/app/globals.css`
- shadcn/ui components (class-variance-authority, clsx, tailwind-merge)
- Lucide React for icons

**API Integration**:
- Backend API base URL configured via `NEXT_PUBLIC_API_BASE_URL` in `frontend/.env.local`
- Default: `http://localhost:8000`
- CORS configured in backend to allow `localhost:3000` and `localhost:3001`

**Key Locations**:
- App Router pages: `frontend/src/app/`
- Reusable components: `frontend/src/components/`
- Utility functions: `frontend/src/lib/`

## Important Implementation Details

### Backend

**CORS Configuration**:
CORS is configured in `backend/app/main.py` using FastAPI's CORSMiddleware. Allowed origins are loaded from `settings.ALLOWED_ORIGINS` which includes localhost:3000, localhost:3001, and 127.0.0.1 equivalents.

**API Routing**:
All API endpoints are prefixed with `/api/v1` (defined in `settings.API_V1_PREFIX`). The main router in `backend/app/api/__init__.py` includes sub-routers from endpoints directory. Currently includes:
- Admin router: `/api/v1/admin/*` endpoints

**Scheduler Architecture**:
When `SCHEDULER_ENABLED=true`, the scheduler runs as a background thread within the FastAPI application. For production, consider running scheduler as separate process using `python -m app.scheduler`.

**Playwright Usage**:
Playwright requires separate browser binary installation (`python -m playwright install`). Runs in headless mode by default. Set `PLAYWRIGHT_HEADLESS=false` for debugging with visible browser window.

### Frontend

**Environment Variables**:
Next.js loads environment variables on startup. After changing `frontend/.env.local`, restart the dev server. Variables prefixed with `NEXT_PUBLIC_` are exposed to the browser and embedded in client bundle.

**Tailwind CSS v4**:
This project uses Tailwind CSS v4, not v3. Configuration is handled via `@tailwindcss/postcss` rather than traditional `tailwind.config.js`. Styles are imported in `globals.css`.

**Next.js 16 Features**:
- Uses App Router (not Pages Router)
- React Server Components by default
- Client components require `"use client"` directive
- Async Server Components supported natively

## Development Workflow Best Practices

### Backend Development

1. **Always work in virtual environment**: Activate before running any Python commands
2. **Database changes**: Run `python scripts/init_db.py` after schema changes (idempotent)
3. **Testing Playwright**: Use `python -m playwright install --with-deps` on Linux if browser issues occur
4. **Never commit `.env`**: Verify `.env` is in `.gitignore` before committing
5. **API changes**: Test with interactive docs at `http://localhost:8000/docs`

### Frontend Development

1. **Restart after env changes**: Next.js only loads `.env.local` on startup
2. **Clear cache on issues**: `rm -rf .next && npm run dev`
3. **Type checking**: Run `npx tsc --noEmit` before committing to catch type errors
4. **API integration**: Ensure backend is running before testing frontend API calls

### Full Stack Development

1. **Start backend first**: Frontend depends on backend API
2. **Check CORS**: If API calls fail, verify CORS middleware allows frontend origin
3. **Port conflicts**: Default ports are 8000 (backend) and 3000 (frontend)
4. **Docker setup**: Use `docker-compose up` for consistent environment

## Testing

### Backend Testing

Tests located in `backend/tests/` directory. Key files:
- `conftest.py`: Pytest fixtures for test setup
- `test_api.py`: API endpoint tests
- Test database isolation: Tests should use separate test database

Run tests with:
```bash
cd backend
pytest -v  # verbose output
pytest --cov=app  # with coverage
```

### Frontend Testing

No test framework currently configured. When adding tests, common patterns:
- Jest + React Testing Library for component tests
- Playwright or Cypress for E2E tests

## Troubleshooting

**Backend**: Detailed troubleshooting in `docs/DEV_SETUP_BACKEND.md` including:
- Playwright browser installation issues
- SQLite "database is locked" errors
- Port conflicts
- Missing environment variables

**Frontend**: Detailed troubleshooting in `docs/DEV_SETUP_FRONTEND.md` including:
- CORS and API connection issues
- Environment variables not loading
- Node version mismatches
- Port conflicts

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
- Backend env: `backend/.env` (not committed)
- Frontend env: `frontend/.env.local` (not committed)
- Scripts: `scripts/dev_backend.sh`, `scripts/dev_frontend.sh`, `scripts/init_db.py`

## Additional Resources

- Backend setup guide: `docs/DEV_SETUP_BACKEND.md`
- Frontend setup guide: `docs/DEV_SETUP_FRONTEND.md`
- API documentation: `http://localhost:8000/docs` (when backend running)
- Main README: `README.md`
