<!--
Sync Impact Report:
- Version change: 1.0.0 → 1.1.0
- Added principles:
  VIII. Documentation Language Standard (spec directory Korean requirement)
- Modified sections:
  - Governance: Updated version number, last amended date
- Templates requiring updates:
  ✅ spec-template.md: Added Korean language requirement notice at top
  ✅ plan-template.md: Added Korean language notice for spec documentation
  ✅ tasks-template.md: Added Korean language notice for spec documentation
  ✅ checklist-template.md: Added Korean language notice for spec documentation
  ✅ agent-file-template.md: Verified (no spec-specific references, no changes needed)
- Follow-up TODOs: None - all placeholders filled, all templates updated
-->

# Video Alert Constitution

## Core Principles

### I. Full-Stack Separation
**Non-negotiable**: Backend and frontend MUST remain independent, deployable services.

- Backend (`backend/`) is a standalone FastAPI application with its own dependencies, tests, and deployment
- Frontend (`frontend/`) is a standalone Next.js application with its own dependencies, tests, and deployment
- Communication ONLY through well-defined REST API endpoints at `/api/v1/*`
- CORS properly configured for cross-origin requests
- No direct database access from frontend; all data access through backend API
- Each service can be developed, tested, and deployed independently

**Rationale**: Enables independent scaling, technology evolution, team autonomy, and clearer separation of concerns.

### II. API-First Design
**Non-negotiable**: All backend functionality MUST be exposed through documented REST API endpoints.

- OpenAPI/Swagger documentation MUST be available at `/docs` endpoint
- API endpoints follow RESTful conventions with proper HTTP verbs (GET, POST, PUT, DELETE)
- All endpoints MUST have request/response schemas defined using Pydantic models
- API versioning through URL prefix (`/api/v1/`)
- No backend logic in frontend; frontend is a pure consumer of API

**Rationale**: Ensures API documentation stays current, enables API-first development, allows multiple frontend clients, and provides clear contract between backend and frontend.

### III. Test Coverage
**Strongly recommended**: Test coverage for critical paths and integration points.

- Backend: pytest for API endpoints, database operations, and business logic
- Contract tests for API endpoints that frontend depends on
- Integration tests for Playwright scraping functionality
- Frontend: Test framework optional but encouraged for complex components
- Database tests MUST use separate test database to avoid data pollution
- Tests run in CI/CD pipeline before deployment

**Rationale**: Web scraping and scheduled tasks are fragile; tests catch regressions early. API contract tests prevent breaking changes to frontend.

### IV. Environment Safety
**Non-negotiable**: Sensitive configuration MUST NOT be committed to version control.

- Backend environment variables in `backend/.env` (gitignored)
- Frontend environment variables in `frontend/.env.local` (gitignored)
- Required variables documented in CLAUDE.md and DEV_SETUP guides
- Secrets (Telegram bot token, API keys) MUST be in environment files only
- Example/template env files (`.env.example`) provided for developer onboarding
- Docker Compose uses `.env` files for configuration injection

**Rationale**: Prevents credential leaks, enables environment-specific configuration, supports secure deployment practices.

### V. Docker-First Deployment
**Strongly recommended**: Production deployment through Docker Compose; local development scripts for efficiency.

- `docker-compose.yml` defines complete stack (backend + frontend) for production-like environment
- Development scripts (`scripts/dev_backend.sh`, `scripts/dev_frontend.sh`) for faster iteration
- Docker ensures consistent environment across development, staging, production
- Each service has proper health checks and restart policies
- Port mapping follows conventions: 8000 (backend), 3000 (frontend dev), 3001 (frontend prod)

**Rationale**: Docker provides reproducible builds, simplifies deployment, ensures development/production parity.

### VI. Database Simplicity
**Current standard**: SQLite with SQLAlchemy ORM for data persistence.

- SQLite database file (default: `backend/dev.db`) for development
- Schema initialization via `scripts/init_db.py` (idempotent)
- Tables: `videos`, `alert_logs`, `scheduler_runs`
- Async database operations via aiosqlite
- Database migrations: Currently manual via init script; consider Alembic if schema changes become frequent
- Tests use separate test database

**Rationale**: SQLite sufficient for current scale; low operational overhead; easy to migrate to PostgreSQL if needed.

### VII. Scheduler Architecture
**Current standard**: APScheduler for periodic video monitoring; runs as background thread in FastAPI.

- Scheduler enabled/disabled via `SCHEDULER_ENABLED` environment variable
- Check interval configurable via `SCHEDULER_INTERVAL` (default: 300 seconds)
- For production: Consider running scheduler as separate process (`python -m app.scheduler`)
- Scheduler runs tracked in `scheduler_runs` table for observability
- Playwright scraping runs in headless mode; set `PLAYWRIGHT_HEADLESS=false` for debugging

**Rationale**: Embedded scheduler simplifies development; separate process for production enables independent scaling and fault isolation.

### VIII. Documentation Language Standard
**Non-negotiable**: All specification documents in `./specs/**/*.md` MUST be written in Korean.

- Feature specifications (`spec.md`) MUST be in Korean
- Implementation plans (`plan.md`) MUST be in Korean
- Task lists (`tasks.md`) MUST be in Korean
- Research documents (`research.md`) MUST be in Korean
- Design documents (data models, quickstart guides, contracts) MUST be in Korean
- Checklists and other spec-related documentation MUST be in Korean
- Templates may contain English instructions but generated content MUST be Korean
- Code comments, README.md, and technical documentation (CLAUDE.md, DEV_SETUP guides) remain in English

**Rationale**: Ensures consistent communication for Korean-speaking stakeholders and team members while maintaining technical documentation in English for broader developer access. Spec documents are user-facing planning artifacts, whereas code and setup documentation serve the international developer community.

## Development Standards

### Code Organization
- Backend: Models (`app/models/`), Schemas (`app/schemas/`), API routes (`app/api/endpoints/`), Configuration (`app/core/config.py`)
- Frontend: App Router pages (`src/app/`), Components (`src/components/`), Utilities (`src/lib/`)
- Scripts at repository root (`scripts/`) for database initialization and development helpers

### Dependency Management
- Backend: `requirements.txt` with pinned versions for reproducibility
- Frontend: `package.json` with semantic versioning; use `npm install` not `yarn`
- Playwright browsers: Separate installation step (`python -m playwright install`)

### Development Workflow
- Always activate Python virtual environment before backend work
- Restart Next.js dev server after `.env.local` changes
- Test API changes via interactive docs at `http://localhost:8000/docs`
- Run `python scripts/init_db.py` after database schema changes (idempotent)
- Type checking (TypeScript) and linting before commits

### Documentation
- CLAUDE.md provides AI assistant guidance for codebase (English)
- DEV_SETUP_*.md guides for backend/frontend setup with troubleshooting (English)
- API documentation auto-generated via FastAPI OpenAPI (English)
- README.md for project overview and quick start (English)
- Specification documents in `./specs/` directory (Korean, per Principle VIII)

## Governance

### Amendment Procedure
1. Propose amendment with rationale in project discussion or issue
2. Document impact on existing code and templates
3. Update constitution with version bump (see versioning policy below)
4. Propagate changes to dependent templates and documentation
5. Commit with message format: `docs: amend constitution to vX.Y.Z (summary of change)`

### Versioning Policy
**Current version**: 1.1.0 (MAJOR.MINOR.PATCH)

- **MAJOR**: Backward incompatible changes (e.g., removing a principle, changing non-negotiable standards)
- **MINOR**: New principle added or materially expanded guidance (e.g., adding new mandatory sections)
- **PATCH**: Clarifications, wording improvements, typo fixes, non-semantic refinements

### Compliance Review
- All PRs MUST verify compliance with non-negotiable principles (I, II, IV, VIII)
- Complexity that violates principles MUST be justified in plan.md "Complexity Tracking" section
- Constitution supersedes all other development practices
- Use CLAUDE.md for runtime development guidance; constitution defines project governance

**Version**: 1.1.0 | **Ratified**: 2025-10-25 | **Last Amended**: 2025-10-26
