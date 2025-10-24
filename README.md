# Video Alert

A modern video alert application with FastAPI backend and Next.js frontend.

## Project Structure

```
video-alert/
├── backend/           # FastAPI backend
│   ├── app/
│   │   ├── api/      # API routes
│   │   ├── core/     # Core configuration
│   │   ├── models/   # Database models
│   │   ├── schemas/  # Pydantic schemas
│   │   └── main.py   # Application entry point
│   └── requirements.txt
├── frontend/          # Next.js frontend
│   ├── src/
│   │   ├── app/      # App Router pages
│   │   ├── components/ # React components
│   │   └── lib/      # Utility functions
│   └── package.json
└── docker-compose.yml # Docker setup
```

## Tech Stack

### Backend
- **FastAPI** - Modern Python web framework
- **Uvicorn** - ASGI server
- **Pydantic** - Data validation

### Frontend
- **Next.js 16** - React framework with App Router
- **TypeScript** - Type safety
- **Tailwind CSS v4** - Utility-first CSS
- **shadcn/ui** - UI component library

## Quick Start

### Using Docker Compose (Recommended)

```bash
docker-compose up
```

- Frontend: http://localhost:3000
- Backend API: http://localhost:8000
- API Documentation: http://localhost:8000/docs

### Manual Setup

#### Backend

```bash
cd backend
python -m venv venv
source venv/bin/activate  # On Windows: venv\Scripts\activate
pip install -r requirements.txt
uvicorn app.main:app --reload --host 0.0.0.0 --port 8000
```

#### Frontend

```bash
cd frontend
npm install
npm run dev
```

## Development

- Backend runs on port 8000
- Frontend runs on port 3000
- API documentation available at http://localhost:8000/docs

### Development Guides

For detailed setup instructions:
- **Backend Development**: See [docs/DEV_SETUP_BACKEND.md](docs/DEV_SETUP_BACKEND.md)
- **Frontend Development**: See [docs/DEV_SETUP_FRONTEND.md](docs/DEV_SETUP_FRONTEND.md)
- **Environment Checklist**: See [docs/DEV_ENV_CHECKLIST.md](docs/DEV_ENV_CHECKLIST.md)

### Quick Start for Developers

**Verify Development Environment**:
```bash
./scripts/check_dev_env.sh
```

**Backend**:
```bash
./scripts/dev_backend.sh
```

**Frontend**:
```bash
./scripts/dev_frontend.sh
```

## License

MIT