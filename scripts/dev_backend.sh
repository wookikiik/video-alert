#!/bin/sh
# Backend Development Helper Script
# This script automates the setup and startup of the FastAPI backend development server

# Usage:
#   ./scripts/dev_backend.sh           # Interactive mode (prompts for user input)
#   ./scripts/dev_backend.sh --bypass  # Bypass mode (no prompts, auto-proceed)

set -e  # Exit on error

# Parse command line arguments
BYPASS_MODE=false
for arg in "$@"; do
    if [ "$arg" = "--bypass" ]; then
        BYPASS_MODE=true
        shift
        break
    fi
done

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Print colored output
print_info() {
    printf "${BLUE}[INFO]${NC} %s\n" "$1"
}

print_success() {
    printf "${GREEN}[SUCCESS]${NC} %s\n" "$1"
}

print_warning() {
    printf "${YELLOW}[WARNING]${NC} %s\n" "$1"
}

print_error() {
    printf "${RED}[ERROR]${NC} %s\n" "$1"
}

# Get the repository root directory (where this script lives)
REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
BACKEND_DIR="$REPO_ROOT/backend"
SCRIPTS_DIR="$REPO_ROOT/scripts"

print_info "Video Alert Backend Development Setup"
print_info "========================================"
if [ "$BYPASS_MODE" = true ]; then
    print_info "Mode: Bypass (no prompts)"
else
    print_info "Mode: Interactive"
fi
echo ""

# Check if we're in the right directory
if [ ! -d "$BACKEND_DIR" ]; then
    print_error "Backend directory not found at: $BACKEND_DIR"
    exit 1
fi

cd "$BACKEND_DIR"
print_info "Working directory: $BACKEND_DIR"
echo ""

# Step 1: Detect Python version and package manager
print_info "Step 1: Detecting Python and package manager..."

# Check for Python
if command -v python3 >/dev/null 2>&1; then
    PYTHON_CMD="python3"
elif command -v python >/dev/null 2>&1; then
    PYTHON_CMD="python"
else
    print_error "Python is not installed"
    print_info "Please install Python 3.8+ from https://www.python.org/"
    exit 1
fi

PYTHON_VERSION=$($PYTHON_CMD --version 2>&1)
print_success "Python: $PYTHON_VERSION"

# Check for Poetry
if [ -f "$BACKEND_DIR/pyproject.toml" ] && [ -f "$BACKEND_DIR/poetry.lock" ]; then
    PACKAGE_MANAGER="poetry"
    print_success "Package manager: Poetry (detected pyproject.toml and poetry.lock)"
elif [ -f "$BACKEND_DIR/requirements.txt" ]; then
    PACKAGE_MANAGER="pip"
    print_success "Package manager: pip (detected requirements.txt)"
else
    print_error "No dependency file found (requirements.txt or pyproject.toml)"
    exit 1
fi
echo ""

# Step 2: Setup virtual environment (for pip only, Poetry manages its own)
if [ "$PACKAGE_MANAGER" = "pip" ]; then
    print_info "Step 2: Setting up Python virtual environment..."

    if [ ! -d ".venv" ]; then
        print_info "Creating virtual environment..."
        $PYTHON_CMD -m venv .venv
        print_success "Virtual environment created: .venv/"
    else
        print_success "Virtual environment already exists: .venv/"
    fi

    # Activate virtual environment
    if [ -f ".venv/bin/activate" ]; then
        print_info "Activating virtual environment..."
        . .venv/bin/activate
        print_success "Virtual environment activated"
    else
        print_error "Could not find .venv/bin/activate"
        exit 1
    fi
    echo ""
else
    print_info "Step 2: Poetry manages its own virtual environment"
    echo ""
fi

# Step 3: Install dependencies
print_info "Step 3: Installing Python dependencies..."

if [ "$PACKAGE_MANAGER" = "poetry" ]; then
    if ! command -v poetry >/dev/null 2>&1; then
        print_error "Poetry is not installed"
        print_info "Install Poetry: curl -sSL https://install.python-poetry.org | python3 -"
        exit 1
    fi
    print_info "Running: poetry install"
    poetry install
    print_success "Dependencies installed with Poetry"
elif [ "$PACKAGE_MANAGER" = "pip" ]; then
    print_info "Running: pip install -r requirements.txt"
    pip install -r requirements.txt
    print_success "Dependencies installed with pip"
fi
echo ""

# Step 4: Install Playwright browsers
print_info "Step 4: Installing Playwright browsers..."
print_warning "This may take a few minutes on first run..."

if [ "$PACKAGE_MANAGER" = "poetry" ]; then
    if poetry run python -m playwright --version >/dev/null 2>&1; then
        print_info "Running: poetry run python -m playwright install"
        poetry run python -m playwright install
        print_success "Playwright browsers installed"
    else
        print_warning "Playwright not found in dependencies, skipping browser install"
    fi
elif [ "$PACKAGE_MANAGER" = "pip" ]; then
    if python -m playwright --version >/dev/null 2>&1; then
        print_info "Running: python -m playwright install"
        python -m playwright install
        print_success "Playwright browsers installed"
    else
        print_warning "Playwright not found in dependencies, skipping browser install"
    fi
fi
echo ""

# Step 5: Setup environment variables
print_info "Step 5: Checking environment configuration..."

if [ ! -f ".env" ]; then
    print_warning ".env not found in backend directory"

    if [ -f ".env.example" ]; then
        if [ "$BYPASS_MODE" = true ]; then
            # Bypass mode: auto-create from .env.example
            cp ".env.example" ".env"
            print_success "Created .env from .env.example (bypass mode)"
            print_warning "IMPORTANT: Please edit .env with your actual configuration later:"
            print_info "  • TELEGRAM_BOT_TOKEN - Get from @BotFather on Telegram"
            print_info "  • TELEGRAM_CHANNEL_ID - Your Telegram channel/group ID"
            print_info "  • MONITORED_URL - The URL to monitor for videos"
            print_info "  • DATABASE_URL - SQLite database path (default: sqlite:///./dev.db)"
            echo ""
        else
            # Interactive mode: ask user
            print_info "Would you like to create .env from .env.example? (y/n)"
            printf "Choice: "
            read -r create_env

            if [ "$create_env" = "y" ] || [ "$create_env" = "Y" ]; then
                cp ".env.example" ".env"
                print_success "Created .env from .env.example"
                print_warning "IMPORTANT: Please edit .env with your actual configuration:"
                print_info "  • TELEGRAM_BOT_TOKEN - Get from @BotFather on Telegram"
                print_info "  • TELEGRAM_CHANNEL_ID - Your Telegram channel/group ID"
                print_info "  • MONITORED_URL - The URL to monitor for videos"
                print_info "  • DATABASE_URL - SQLite database path (default: sqlite:///./dev.db)"
                echo ""
                print_info "Press Enter to continue after editing, or Ctrl+C to exit..."
                read -r dummy
            else
                print_warning "Skipping .env creation"
                print_info "You can create it manually: cp backend/.env.example backend/.env"
                print_info "The server may fail to start without proper environment variables!"
                echo ""
                print_info "Continue anyway? (y/n)"
                printf "Choice: "
                read -r continue_without_env
                if [ "$continue_without_env" != "y" ] && [ "$continue_without_env" != "Y" ]; then
                    print_info "Exiting. Please create .env file first."
                    exit 0
                fi
            fi
        fi
    else
        print_error ".env.example not found"
        print_info "Please create .env manually with required variables:"
        print_info "  DATABASE_URL=sqlite:///./dev.db"
        print_info "  TELEGRAM_BOT_TOKEN=your_token_here"
        print_info "  TELEGRAM_CHANNEL_ID=@your_channel"
        print_info "  MONITORED_URL=https://example.com"
        if [ "$BYPASS_MODE" = false ]; then
            exit 1
        else
            print_warning "Continuing in bypass mode despite missing .env.example..."
        fi
    fi
else
    print_success ".env already exists"
    
    # Check for required variables (without exposing values)
    print_info "Checking required environment variables..."
    MISSING_VARS=""
    
    if ! grep -q "^DATABASE_URL=" .env 2>/dev/null; then
        MISSING_VARS="$MISSING_VARS DATABASE_URL"
    fi
    if ! grep -q "^TELEGRAM_BOT_TOKEN=" .env 2>/dev/null; then
        MISSING_VARS="$MISSING_VARS TELEGRAM_BOT_TOKEN"
    fi
    if ! grep -q "^TELEGRAM_CHANNEL_ID=" .env 2>/dev/null; then
        MISSING_VARS="$MISSING_VARS TELEGRAM_CHANNEL_ID"
    fi
    if ! grep -q "^MONITORED_URL=" .env 2>/dev/null; then
        MISSING_VARS="$MISSING_VARS MONITORED_URL"
    fi
    
    if [ -n "$MISSING_VARS" ]; then
        print_warning "Missing environment variables in .env:$MISSING_VARS"
        print_info "Please add them to backend/.env before starting the server"
    else
        print_success "All required environment variables present"
    fi
fi
echo ""

# Step 6: Initialize database
print_info "Step 6: Initializing database..."

if [ -f "$SCRIPTS_DIR/init_db.py" ]; then
    print_info "Running: python $SCRIPTS_DIR/init_db.py"
    if [ "$PACKAGE_MANAGER" = "poetry" ]; then
        poetry run python "$SCRIPTS_DIR/init_db.py"
    else
        python "$SCRIPTS_DIR/init_db.py"
    fi
    print_success "Database initialization complete"
else
    print_warning "Database initialization script not found at: $SCRIPTS_DIR/init_db.py"
    print_info "You may need to initialize the database manually"
fi
echo ""

# Step 7: Run tests (if pytest is available)
print_info "Step 7: Running tests (optional)..."

if [ "$BYPASS_MODE" = true ]; then
    # Bypass mode: skip tests (default N)
    print_info "Skipping tests (bypass mode, default: N)"
else
    # Interactive mode: ask user
    print_info "Would you like to run tests before starting the server? (y/n)"
    printf "Choice: "
    read -r run_tests

    if [ "$run_tests" = "y" ] || [ "$run_tests" = "Y" ]; then
        if [ "$PACKAGE_MANAGER" = "poetry" ]; then
            if poetry run pytest --version >/dev/null 2>&1; then
                print_info "Running: poetry run pytest"
                poetry run pytest || print_warning "Some tests failed, but continuing..."
            else
                print_warning "pytest not found in Poetry environment"
            fi
        else
            if python -m pytest --version >/dev/null 2>&1; then
                print_info "Running: pytest"
                pytest || print_warning "Some tests failed, but continuing..."
            else
                print_warning "pytest not installed, skipping tests"
            fi
        fi
    else
        print_info "Skipping tests"
    fi
fi
echo ""

# Step 8: Start development server
print_info "Step 8: Starting FastAPI development server..."
print_info ""
print_info "========================================"
print_info "Server Configuration:"
print_info "  • Host: 0.0.0.0 (all interfaces)"
print_info "  • Port: 8000 (override with --port)"
print_info "  • Auto-reload: enabled"
print_info ""
print_info "Server will be available at:"
print_info "  • API: http://localhost:8000"
print_info "  • Docs (Swagger): http://localhost:8000/docs"
print_info "  • Docs (ReDoc): http://localhost:8000/redoc"
print_info ""
print_info "Press Ctrl+C to stop the server"
print_info "========================================"
echo ""

# Determine how to run uvicorn
if [ "$PACKAGE_MANAGER" = "poetry" ]; then
    print_success "Running: poetry run uvicorn app.main:app --reload --host 0.0.0.0 --port 8000"
    exec poetry run uvicorn app.main:app --reload --host 0.0.0.0 --port 8000 "$@"
else
    print_success "Running: uvicorn app.main:app --reload --host 0.0.0.0 --port 8000"
    exec uvicorn app.main:app --reload --host 0.0.0.0 --port 8000 "$@"
fi
