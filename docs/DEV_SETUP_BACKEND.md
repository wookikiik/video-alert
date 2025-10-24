# Backend Development Setup

This guide provides step-by-step instructions for setting up the FastAPI backend development environment for Video Alert.

## Prerequisites

### Required Software
- **Git** - Version control system
- **Python** - Python 3.8 or higher (3.10+ recommended)
- **pip** or **Poetry** - Python package manager

### System Dependencies for Playwright
Playwright requires certain system libraries to run browsers. On first run, Playwright will attempt to install these automatically, but you may need to install them manually on some systems.

#### Linux (Debian/Ubuntu)
```bash
# Playwright will attempt to install these automatically
# If you encounter issues, run:
sudo apt-get update
sudo apt-get install -y \
    libnss3 \
    libnspr4 \
    libatk1.0-0 \
    libatk-bridge2.0-0 \
    libcups2 \
    libdrm2 \
    libdbus-1-3 \
    libxkbcommon0 \
    libxcomposite1 \
    libxdamage1 \
    libxfixes3 \
    libxrandr2 \
    libgbm1 \
    libasound2
```

#### macOS
```bash
# Playwright browsers should work out of the box on macOS
# No additional system dependencies needed
```

#### Windows
```powershell
# Playwright browsers should work out of the box on Windows
# No additional system dependencies needed
```

For detailed system requirements, see: https://playwright.dev/python/docs/intro#system-requirements

## Quick Start (Automated)

The fastest way to get started is using the development helper script:

```bash
# From the repository root
./scripts/dev_backend.sh
```

This script will:
1. Detect your Python version and package manager (pip or Poetry)
2. Create/activate a virtual environment (for pip) or use Poetry's environment
3. Install all Python dependencies
4. Install Playwright browsers
5. Create `.env` from `.env.example` (if needed)
6. Initialize the SQLite database
7. Start the FastAPI development server

Continue reading for manual setup instructions and detailed explanations.

## Manual Setup

### Step 1: Determine Package Manager

This repository uses **pip** with `requirements.txt`. Check which package manager is in use:

```bash
cd backend

# Check for pip (requirements.txt)
ls requirements.txt

# Check for Poetry (pyproject.toml and poetry.lock)
ls pyproject.toml poetry.lock
```

**For this project**: We use **pip** with `requirements.txt`.

### Step 2: Create and Activate Virtual Environment

#### Using pip (recommended for this project)

```bash
cd backend

# Create virtual environment
python -m venv venv

# Activate virtual environment
# On Linux/macOS:
source venv/bin/activate

# On Windows (Command Prompt):
venv\Scripts\activate

# On Windows (PowerShell):
venv\Scripts\Activate.ps1

# Verify activation (should show venv path)
which python  # Linux/macOS
where python  # Windows
```

#### Using Poetry (alternative)

```bash
cd backend

# Install dependencies (Poetry creates its own venv)
poetry install

# Activate Poetry shell
poetry shell

# Or run commands with: poetry run <command>
```

### Step 3: Install Python Dependencies

#### Using pip
```bash
cd backend
source venv/bin/activate  # Activate venv first

# Install dependencies
pip install -r requirements.txt

# Verify installation
pip list
```

#### Using Poetry
```bash
cd backend

# Install dependencies
poetry install

# Verify installation
poetry show
```

### Step 4: Install Playwright Browsers

Playwright requires browser binaries to be installed separately:

```bash
cd backend

# Using pip (with venv activated)
python -m playwright install

# Using Poetry
poetry run python -m playwright install

# Optional: Install only specific browsers
python -m playwright install chromium
python -m playwright install firefox
python -m playwright install webkit

# Optional: Install with system dependencies (Linux)
python -m playwright install --with-deps
```

**Note**: The first browser installation downloads ~300MB of browser binaries and may take several minutes.

**Headless vs Headful**:
- By default, Playwright runs browsers in **headless** mode (no visible window)
- For debugging, you can run in **headful** mode by setting environment variable:
  ```bash
  PLAYWRIGHT_HEADLESS=false python your_script.py
  ```

**Troubleshooting Playwright**: See the [Troubleshooting](#troubleshooting) section below.

### Step 5: Configure Environment Variables

#### Create .env file

```bash
cd backend

# Copy example file
cp .env.example .env

# Edit with your values
nano .env  # or vim, code, etc.
```

#### Required Environment Variables

Edit `backend/.env` and configure these required variables:

```bash
# Database Configuration
DATABASE_URL=sqlite:///./dev.db

# Monitored URL - The website URL to monitor for new videos
MONITORED_URL=https://example.com/videos

# Telegram Bot Configuration
# Get your bot token from @BotFather on Telegram
TELEGRAM_BOT_TOKEN=123456789:ABCdefGHIjklMNOpqrsTUVwxyz

# Telegram Channel/Group ID where alerts will be sent
# Can be @channel_username or numeric ID like -1001234567890
TELEGRAM_CHANNEL_ID=@your_channel_id

# Scheduler Configuration
SCHEDULER_ENABLED=true
SCHEDULER_INTERVAL=300  # Check every 5 minutes (in seconds)
```

#### Getting Telegram Credentials

1. **Get Bot Token**:
   - Open Telegram and search for `@BotFather`
   - Send `/newbot` and follow instructions
   - Copy the bot token (format: `123456789:ABC...`)

2. **Get Channel ID**:
   - Create a channel or group in Telegram
   - Add your bot as an administrator
   - Send a test message to the channel
   - Visit: `https://api.telegram.org/bot<YOUR_BOT_TOKEN>/getUpdates`
   - Find the `"chat":{"id": ...}` value (e.g., `-1001234567890`)

#### Security Warning

⚠️ **NEVER commit your `.env` file to git!**

The `.env` file contains sensitive credentials. It is already in `.gitignore`, but verify:

```bash
# Check that .env is ignored
git status  # Should NOT show .env

# If .env appears, add it to .gitignore
echo ".env" >> backend/.gitignore
```

**Best practices**:
- Don't share your bot token publicly
- Don't include it in screenshots or logs
- Rotate it immediately if compromised (via @BotFather)
- Use different tokens for development and production

### Step 6: Initialize Database

The project uses SQLite for local development. Initialize the database and create tables:

```bash
# From repository root
python scripts/init_db.py

# Or using Poetry
poetry run python scripts/init_db.py
```

The script will:
- Read `DATABASE_URL` from `backend/.env`
- Create the database file if it doesn't exist (default: `backend/dev.db`)
- Create required tables: `videos`, `alert_logs`, `scheduler_runs`
- Create indexes for performance
- Display table information

**The script is idempotent** - safe to run multiple times without losing data.

#### Verify Database

```bash
cd backend

# Check that database file was created
ls -l dev.db

# Inspect database with sqlite3
sqlite3 dev.db

# SQLite commands:
.tables                    # List tables
.schema videos            # Show table schema
SELECT * FROM videos;     # Query data
.quit                     # Exit
```

#### Alternative: Manual Database Creation

If you prefer not to use the init script, you can create the database manually:

```python
# backend/create_db.py
from app.database import engine, Base

# Create all tables
Base.metadata.create_all(bind=engine)
print("Database initialized")
```

### Step 7: Run the Development Server

#### Single-Process Mode (Simple - Recommended for Development)

Run the FastAPI server with the scheduler in the same process:

```bash
cd backend
source venv/bin/activate  # If using pip

# Set environment variable to enable scheduler
export SCHEDULER_ENABLED=true

# Start server
uvicorn app.main:app --reload --host 0.0.0.0 --port 8000

# Using Poetry
poetry run uvicorn app.main:app --reload --host 0.0.0.0 --port 8000
```

**Note**: The scheduler runs as a background thread in the FastAPI application when `SCHEDULER_ENABLED=true` in your `.env` file.

#### Two-Process Mode (Advanced - Separate API and Scheduler)

For production-like setup, run the API and scheduler as separate processes:

**Terminal 1 - API Server**:
```bash
cd backend
source venv/bin/activate

# Disable scheduler in this process
export SCHEDULER_ENABLED=false

uvicorn app.main:app --reload --host 0.0.0.0 --port 8000
```

**Terminal 2 - Scheduler Process**:
```bash
cd backend
source venv/bin/activate

# Run the scheduler separately
python -m app.scheduler
# Or: poetry run python -m app.scheduler
```

#### Access the Application

Once the server is running:

- **API Root**: http://localhost:8000
- **Interactive API Docs (Swagger UI)**: http://localhost:8000/docs
- **Alternative API Docs (ReDoc)**: http://localhost:8000/redoc
- **Health Check**: http://localhost:8000/health

#### Override Server Port

If port 8000 is already in use:

```bash
# Use a different port
uvicorn app.main:app --reload --host 0.0.0.0 --port 8001

# Or set in environment
export PORT=8001
uvicorn app.main:app --reload --host 0.0.0.0 --port $PORT
```

### Step 8: Run Tests

#### Using pytest

```bash
cd backend
source venv/bin/activate  # If using pip

# Run all tests
pytest

# Run with verbose output
pytest -v

# Run specific test file
pytest tests/test_api.py

# Run with coverage report
pytest --cov=app --cov-report=html

# Using Poetry
poetry run pytest
```

#### Test Structure

```
backend/
├── app/
│   ├── main.py
│   └── ...
└── tests/
    ├── __init__.py
    ├── conftest.py       # Pytest fixtures
    ├── test_api.py       # API endpoint tests
    ├── test_models.py    # Database model tests
    └── test_scheduler.py # Scheduler tests
```

### Step 9: Linting and Type Checking

#### Code Formatting with Black (if available)

```bash
# Install black
pip install black

# Format all Python files
black backend/app

# Check formatting without changes
black --check backend/app
```

#### Linting with flake8 (if available)

```bash
# Install flake8
pip install flake8

# Run linter
flake8 backend/app

# With custom config
flake8 backend/app --max-line-length=100
```

#### Type Checking with mypy (if available)

```bash
# Install mypy
pip install mypy

# Run type checker
mypy backend/app
```

## Development Workflow

### Typical Development Session

```bash
# 1. Navigate to backend directory
cd backend

# 2. Activate virtual environment (if using pip)
source venv/bin/activate

# 3. Pull latest changes
git pull

# 4. Install any new dependencies
pip install -r requirements.txt

# 5. Run database migrations (if any)
python ../scripts/init_db.py

# 6. Start development server
uvicorn app.main:app --reload

# 7. In another terminal, run tests
pytest

# 8. Make your changes and test

# 9. Commit your changes
git add .
git commit -m "Your changes"
git push
```

### Using the Helper Script

For a streamlined experience, use the dev script which automates steps 2-6:

```bash
# From repository root
./scripts/dev_backend.sh
```

## Troubleshooting

### Missing or Incorrect Environment Variables

**Symptom**: Server fails to start with error about missing environment variables.

**Solution**:
1. Verify `backend/.env` exists:
   ```bash
   ls backend/.env
   ```

2. Check that required variables are set:
   ```bash
   cd backend
   grep "DATABASE_URL\|TELEGRAM_BOT_TOKEN\|TELEGRAM_CHANNEL_ID\|MONITORED_URL" .env
   ```

3. Ensure no trailing spaces or quotes in values:
   ```bash
   # Correct
   DATABASE_URL=sqlite:///./dev.db
   
   # Incorrect (has quotes)
   DATABASE_URL="sqlite:///./dev.db"
   ```

4. Validate .env is being loaded:
   ```python
   # Test in Python
   from dotenv import load_dotenv
   import os
   load_dotenv("backend/.env")
   print(os.getenv("DATABASE_URL"))  # Should print value
   ```

### Playwright/Browser Installation Failures

**Symptom**: `playwright install` fails or browsers don't run.

**Solutions**:

1. **Re-run installer with verbose output**:
   ```bash
   python -m playwright install --verbose
   ```

2. **Install with system dependencies** (Linux):
   ```bash
   python -m playwright install --with-deps
   ```

3. **Install system libraries manually** (Ubuntu/Debian):
   ```bash
   sudo apt-get update
   sudo apt-get install -y \
       libnss3 libnspr4 libatk1.0-0 libatk-bridge2.0-0 \
       libcups2 libdrm2 libdbus-1-3 libxkbcommon0 \
       libxcomposite1 libxdamage1 libxfixes3 libxrandr2 \
       libgbm1 libasound2
   ```

4. **Check browser installation location**:
   ```bash
   # List installed browsers
   python -m playwright install --help
   
   # Browsers are typically installed in:
   # Linux/Mac: ~/.cache/ms-playwright/
   # Windows: %USERPROFILE%\AppData\Local\ms-playwright\
   ```

5. **Try specific browser only**:
   ```bash
   # Install only Chromium (smallest)
   python -m playwright install chromium
   ```

6. **Permissions issues**:
   ```bash
   # Ensure playwright cache directory is writable
   chmod -R u+w ~/.cache/ms-playwright/
   ```

**Common error messages**:
- `Browser was not installed` - Run `playwright install`
- `Executable doesn't exist` - Browser install path issue, try reinstalling
- `Missing dependencies` - Install system libraries (Linux)

**Reference**: https://playwright.dev/python/docs/browsers

### SQLite "Database is Locked" Error

**Symptom**: Error when running queries: `sqlite3.OperationalError: database is locked`

**Causes**:
- Multiple processes trying to write to the database simultaneously
- A process crashed while holding a database lock
- Database file is on a network filesystem (NFS, SMB)

**Solutions**:

1. **Stop all processes accessing the database**:
   ```bash
   # Find processes using the database
   lsof backend/dev.db
   
   # Kill them if necessary
   pkill -f "uvicorn"
   pkill -f "app.scheduler"
   ```

2. **Reset database (CAUTION: Loses all data)**:
   ```bash
   cd backend
   
   # Backup existing database
   mv dev.db dev.db.backup
   
   # Reinitialize
   python ../scripts/init_db.py
   ```

3. **Use WAL mode for better concurrency** (if needed in production):
   ```python
   # In your database connection setup
   import sqlite3
   conn = sqlite3.connect("dev.db")
   conn.execute("PRAGMA journal_mode=WAL")
   ```

4. **Ensure database is on local filesystem**:
   ```bash
   # Check filesystem type
   df -T backend/dev.db
   
   # If on network filesystem, move to local disk
   mv dev.db /tmp/dev.db
   # Update DATABASE_URL in .env
   ```

**Prevention**:
- Use separate databases for development and testing
- Close database connections properly in code
- Use single-process mode for development

### Port Already in Use

**Symptom**: `Error: Address already in use` when starting uvicorn.

**Solutions**:

1. **Find process using port 8000**:
   ```bash
   # Linux/Mac
   lsof -i :8000
   
   # Or using netstat
   netstat -tuln | grep 8000
   
   # Windows
   netstat -ano | findstr :8000
   ```

2. **Kill the process**:
   ```bash
   # Linux/Mac (get PID from lsof output)
   kill <PID>
   
   # Or kill all uvicorn processes
   pkill -f uvicorn
   
   # Windows (get PID from netstat output)
   taskkill /PID <PID> /F
   ```

3. **Use a different port**:
   ```bash
   uvicorn app.main:app --reload --port 8001
   ```

4. **Check for stale processes**:
   ```bash
   ps aux | grep uvicorn
   ps aux | grep python
   ```

### Import Errors or Module Not Found

**Symptom**: `ModuleNotFoundError: No module named 'app'` or similar.

**Solutions**:

1. **Verify virtual environment is activated**:
   ```bash
   which python  # Should show venv path
   # If not, activate:
   source venv/bin/activate
   ```

2. **Reinstall dependencies**:
   ```bash
   pip install -r requirements.txt
   ```

3. **Check Python path**:
   ```bash
   # Run from backend directory
   cd backend
   uvicorn app.main:app --reload
   
   # NOT from repo root
   ```

4. **Verify app structure**:
   ```bash
   ls -la backend/app/__init__.py  # Must exist
   ls -la backend/app/main.py       # Must exist
   ```

### Tests Failing

**Symptom**: `pytest` fails or shows errors.

**Solutions**:

1. **Check test dependencies are installed**:
   ```bash
   pip list | grep pytest
   pip install pytest pytest-asyncio httpx
   ```

2. **Run tests from correct directory**:
   ```bash
   cd backend
   pytest
   ```

3. **Check test database isolation**:
   ```python
   # In tests/conftest.py, ensure test database is separate
   @pytest.fixture
   def test_db():
       test_db_path = "test.db"
       # Setup test database
       yield
       # Cleanup
       os.remove(test_db_path)
   ```

4. **Run tests with verbose output**:
   ```bash
   pytest -v -s
   ```

5. **Run specific test**:
   ```bash
   pytest tests/test_api.py::test_health_check -v
   ```

## Helper Scripts Reference

### scripts/dev_backend.sh

Automated development environment setup and server startup.

**Location**: `scripts/dev_backend.sh`

**Usage**:
```bash
# From repository root
./scripts/dev_backend.sh

# Pass additional uvicorn arguments
./scripts/dev_backend.sh --port 8001
```

**What it does**:
1. Detects Python version and package manager
2. Creates/activates virtual environment (pip) or uses Poetry
3. Installs Python dependencies
4. Installs Playwright browsers
5. Creates `.env` from `.env.example` if needed
6. Initializes SQLite database
7. Optionally runs tests
8. Starts FastAPI development server

### scripts/init_db.py

Database initialization and table creation script.

**Location**: `scripts/init_db.py`

**Usage**:
```bash
# From repository root
python scripts/init_db.py

# Or from backend directory
cd backend
python ../scripts/init_db.py
```

**What it does**:
1. Reads `DATABASE_URL` from `backend/.env`
2. Creates database file if it doesn't exist
3. Creates tables: `videos`, `alert_logs`, `scheduler_runs`
4. Creates database indexes
5. Verifies table creation
6. Displays table information and row counts

**Idempotent**: Safe to run multiple times - won't drop existing data.

## Environment Variables Reference

Complete list of environment variables used by the backend:

| Variable | Required | Default | Description |
|----------|----------|---------|-------------|
| `DATABASE_URL` | Yes | `sqlite:///./dev.db` | SQLite database connection string |
| `MONITORED_URL` | Yes | - | URL to monitor for new videos |
| `TELEGRAM_BOT_TOKEN` | Yes | - | Telegram bot token from @BotFather |
| `TELEGRAM_CHANNEL_ID` | Yes | - | Telegram channel/group ID for alerts |
| `SCHEDULER_ENABLED` | No | `true` | Enable/disable background scheduler |
| `SCHEDULER_INTERVAL` | No | `300` | Check interval in seconds (default: 5 min) |
| `PROJECT_NAME` | No | `Video Alert API` | API project name |
| `VERSION` | No | `1.0.0` | API version |
| `API_V1_PREFIX` | No | `/api/v1` | API route prefix |
| `ALLOWED_ORIGINS` | No | `http://localhost:3000,...` | CORS allowed origins (comma-separated) |
| `ENVIRONMENT` | No | `development` | Environment name (development/production) |
| `DEBUG` | No | `true` | Enable debug mode (never enable in production!) |

## Additional Resources

### Documentation
- **FastAPI Official Docs**: https://fastapi.tiangolo.com/
- **Playwright Python Docs**: https://playwright.dev/python/
- **APScheduler Docs**: https://apscheduler.readthedocs.io/
- **SQLAlchemy Docs**: https://docs.sqlalchemy.org/
- **Pydantic Docs**: https://docs.pydantic.dev/

### Related Guides
- **Frontend Setup**: `docs/DEV_SETUP_FRONTEND.md`
- **Main README**: `README.md`

### Getting Help
- Check existing issues in the repository
- Review error messages carefully
- Consult the [Troubleshooting](#troubleshooting) section above
- Check FastAPI and Playwright documentation

## Summary

**Quickest path to running backend**:
```bash
# From repository root
./scripts/dev_backend.sh
```

**Manual setup checklist**:
- [ ] Install Python 3.8+
- [ ] Create virtual environment
- [ ] Install dependencies from `requirements.txt`
- [ ] Install Playwright browsers: `python -m playwright install`
- [ ] Copy `backend/.env.example` to `backend/.env`
- [ ] Configure Telegram bot token and channel ID in `.env`
- [ ] Initialize database: `python scripts/init_db.py`
- [ ] Start server: `uvicorn app.main:app --reload`
- [ ] Access API docs at http://localhost:8000/docs

**Security reminders**:
- Never commit `.env` files
- Keep bot tokens secret
- Rotate credentials if compromised
- Use different credentials for dev/prod
