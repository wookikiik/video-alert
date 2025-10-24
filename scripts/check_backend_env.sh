#!/bin/sh
# Backend Development Environment Verification Script
# This script checks if the FastAPI backend development environment is properly set up

set -e  # Exit on error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Counters
PASSED=0
FAILED=0
WARNINGS=0

# Print colored output
print_header() {
    printf "\n${BLUE}=== %s ===${NC}\n" "$1"
}

print_check() {
    printf "${BLUE}[CHECK]${NC} %s" "$1"
}

print_pass() {
    printf " ${GREEN}✓ PASS${NC}\n"
    PASSED=$((PASSED + 1))
}

print_fail() {
    printf " ${RED}✗ FAIL${NC}\n"
    if [ -n "$1" ]; then
        printf "  ${RED}→${NC} %s\n" "$1"
    fi
    FAILED=$((FAILED + 1))
}

print_warn() {
    printf " ${YELLOW}⚠ WARNING${NC}\n"
    if [ -n "$1" ]; then
        printf "  ${YELLOW}→${NC} %s\n" "$1"
    fi
    WARNINGS=$((WARNINGS + 1))
}

print_info() {
    printf "  ${BLUE}ℹ${NC} %s\n" "$1"
}

# Get the repository root directory
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
BACKEND_DIR="$REPO_ROOT/backend"

print_header "Backend Development Environment Verification"
printf "Repository: %s\n" "$REPO_ROOT"
printf "Backend Directory: %s\n" "$BACKEND_DIR"

# Check 1: Backend directory exists
print_header "1. Directory Structure"
print_check "Backend directory exists..."
if [ -d "$BACKEND_DIR" ]; then
    print_pass
else
    print_fail "Backend directory not found at $BACKEND_DIR"
    exit 1
fi

# Check 2: Python installation
print_header "2. Python Installation"
print_check "Python is installed..."
if command -v python3 >/dev/null 2>&1; then
    PYTHON_CMD="python3"
    PYTHON_VERSION=$(python3 --version 2>&1 | cut -d' ' -f2)
    print_pass
    print_info "Python version: $PYTHON_VERSION"
elif command -v python >/dev/null 2>&1; then
    PYTHON_CMD="python"
    PYTHON_VERSION=$(python --version 2>&1 | cut -d' ' -f2)
    print_pass
    print_info "Python version: $PYTHON_VERSION"
else
    print_fail "Python is not installed"
    print_info "Install from: https://www.python.org/"
fi

print_check "Python version is 3.8 or higher..."
if command -v "$PYTHON_CMD" >/dev/null 2>&1; then
    PYTHON_MAJOR=$($PYTHON_CMD -c 'import sys; print(sys.version_info.major)')
    PYTHON_MINOR=$($PYTHON_CMD -c 'import sys; print(sys.version_info.minor)')
    if [ "$PYTHON_MAJOR" -ge 3 ] && [ "$PYTHON_MINOR" -ge 8 ]; then
        print_pass
    else
        print_fail "Python 3.8+ required, found $PYTHON_VERSION"
    fi
else
    print_fail "Python command not available"
fi

# Check 3: Package manager and dependencies
print_header "3. Package Manager & Dependencies"
cd "$BACKEND_DIR"

print_check "Package manager configured (pip or poetry)..."
if [ -f "requirements.txt" ]; then
    PACKAGE_MANAGER="pip"
    print_pass
    print_info "Using pip with requirements.txt"
elif [ -f "pyproject.toml" ]; then
    PACKAGE_MANAGER="poetry"
    print_pass
    print_info "Using Poetry with pyproject.toml"
else
    print_fail "No requirements.txt or pyproject.toml found"
    PACKAGE_MANAGER=""
fi

if [ "$PACKAGE_MANAGER" = "pip" ]; then
    print_check "Virtual environment exists (venv/)..."
    if [ -d "venv" ]; then
        print_pass
    else
        print_fail "Virtual environment not found"
        print_info "Create with: python -m venv venv"
    fi

    print_check "Virtual environment can be activated..."
    if [ -f "venv/bin/activate" ] || [ -f "venv/Scripts/activate" ]; then
        print_pass
    else
        print_fail "Activation script not found"
    fi

    print_check "Dependencies installed in virtual environment..."
    if [ -f "venv/bin/python" ] || [ -f "venv/Scripts/python.exe" ]; then
        if [ -f "venv/bin/python" ]; then
            VENV_PYTHON="venv/bin/python"
        else
            VENV_PYTHON="venv/Scripts/python.exe"
        fi
        
        # Check if fastapi is installed
        if $VENV_PYTHON -c "import fastapi" 2>/dev/null; then
            print_pass
            FASTAPI_VERSION=$($VENV_PYTHON -c "import fastapi; print(fastapi.__version__)" 2>/dev/null || echo "unknown")
            print_info "FastAPI version: $FASTAPI_VERSION"
        else
            print_fail "FastAPI not installed in virtual environment"
            print_info "Install with: pip install -r requirements.txt"
        fi
    else
        print_fail "Virtual environment Python not found"
    fi
elif [ "$PACKAGE_MANAGER" = "poetry" ]; then
    print_check "Poetry is installed..."
    if command -v poetry >/dev/null 2>&1; then
        print_pass
        POETRY_VERSION=$(poetry --version 2>&1 | cut -d' ' -f3)
        print_info "Poetry version: $POETRY_VERSION"
    else
        print_fail "Poetry not installed"
        print_info "Install from: https://python-poetry.org/"
    fi

    print_check "Poetry dependencies installed..."
    if poetry run python -c "import fastapi" 2>/dev/null; then
        print_pass
    else
        print_fail "Dependencies not installed"
        print_info "Install with: poetry install"
    fi
fi

# Check 4: Required Python packages
print_header "4. Required Python Packages"

check_package() {
    PKG_NAME=$1
    print_check "$PKG_NAME is installed..."
    
    if [ "$PACKAGE_MANAGER" = "pip" ] && [ -f "venv/bin/python" ]; then
        if venv/bin/python -c "import $PKG_NAME" 2>/dev/null; then
            print_pass
        else
            print_fail "$PKG_NAME not installed"
        fi
    elif [ "$PACKAGE_MANAGER" = "poetry" ]; then
        if poetry run python -c "import $PKG_NAME" 2>/dev/null; then
            print_pass
        else
            print_fail "$PKG_NAME not installed"
        fi
    elif command -v "$PYTHON_CMD" >/dev/null 2>&1; then
        if $PYTHON_CMD -c "import $PKG_NAME" 2>/dev/null; then
            print_pass
        else
            print_fail "$PKG_NAME not installed"
        fi
    else
        print_fail "Cannot check package"
    fi
}

check_package "fastapi"
check_package "uvicorn"
check_package "pydantic"
check_package "playwright"
check_package "sqlalchemy"
check_package "pytest"

# Check 5: Playwright browsers
print_header "5. Playwright Browser Installation"
print_check "Playwright browsers installed..."
if [ "$PACKAGE_MANAGER" = "pip" ] && [ -f "venv/bin/python" ]; then
    if venv/bin/python -m playwright --version >/dev/null 2>&1; then
        # Check if browsers are installed by looking for the cache directory
        if [ -d "$HOME/.cache/ms-playwright" ] || [ -d "$HOME/Library/Caches/ms-playwright" ]; then
            print_pass
            print_info "Browser cache found"
        else
            print_warn "Playwright installed but browsers may not be installed"
            print_info "Install with: python -m playwright install"
        fi
    else
        print_fail "Playwright command not available"
    fi
elif [ "$PACKAGE_MANAGER" = "poetry" ]; then
    if poetry run python -m playwright --version >/dev/null 2>&1; then
        if [ -d "$HOME/.cache/ms-playwright" ] || [ -d "$HOME/Library/Caches/ms-playwright" ]; then
            print_pass
            print_info "Browser cache found"
        else
            print_warn "Playwright installed but browsers may not be installed"
            print_info "Install with: poetry run python -m playwright install"
        fi
    else
        print_fail "Playwright command not available"
    fi
else
    print_fail "Cannot verify Playwright installation"
fi

# Check 6: Environment configuration
print_header "6. Environment Configuration"
print_check ".env file exists..."
if [ -f ".env" ]; then
    print_pass
else
    print_fail ".env file not found"
    print_info "Copy from: cp .env.example .env"
fi

if [ -f ".env" ]; then
    print_check "Required environment variables present..."
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
    
    if [ -z "$MISSING_VARS" ]; then
        print_pass
    else
        print_fail "Missing variables:$MISSING_VARS"
    fi
fi

# Check 7: Database
print_header "7. Database Configuration"
print_check "SQLite database file exists..."
if [ -f "dev.db" ]; then
    print_pass
    DB_SIZE=$(du -h dev.db 2>/dev/null | cut -f1)
    print_info "Database size: $DB_SIZE"
else
    print_warn "Database file not found (dev.db)"
    print_info "Initialize with: python ../scripts/init_db.py"
fi

# Check 8: Application structure
print_header "8. Application Structure"
print_check "app/ directory exists..."
if [ -d "app" ]; then
    print_pass
else
    print_fail "app/ directory not found"
fi

print_check "app/main.py exists..."
if [ -f "app/main.py" ]; then
    print_pass
else
    print_fail "app/main.py not found"
fi

print_check "app/__init__.py exists..."
if [ -f "app/__init__.py" ]; then
    print_pass
else
    print_warn "app/__init__.py not found (may be optional)"
fi

# Check 9: Tests
print_header "9. Test Infrastructure"
print_check "tests/ directory exists..."
if [ -d "tests" ]; then
    print_pass
    TEST_COUNT=$(find tests -name "test_*.py" 2>/dev/null | wc -l)
    print_info "Test files found: $TEST_COUNT"
else
    print_warn "tests/ directory not found"
fi

# Check 10: Port availability
print_header "10. Port Availability"
print_check "Port 8000 is available..."
if command -v lsof >/dev/null 2>&1; then
    if lsof -i :8000 >/dev/null 2>&1; then
        print_warn "Port 8000 is already in use"
        print_info "Check with: lsof -i :8000"
    else
        print_pass
    fi
elif command -v netstat >/dev/null 2>&1; then
    if netstat -tuln 2>/dev/null | grep -q ":8000 "; then
        print_warn "Port 8000 is already in use"
    else
        print_pass
    fi
else
    print_warn "Cannot check port availability (lsof/netstat not found)"
fi

# Summary
print_header "Verification Summary"
printf "\n"
printf "  ${GREEN}✓ Passed:${NC}   %d\n" "$PASSED"
printf "  ${RED}✗ Failed:${NC}   %d\n" "$FAILED"
printf "  ${YELLOW}⚠ Warnings:${NC} %d\n" "$WARNINGS"
printf "\n"

if [ "$FAILED" -eq 0 ]; then
    printf "${GREEN}Backend environment is properly configured!${NC}\n"
    printf "Start the development server with:\n"
    printf "  cd backend\n"
    if [ "$PACKAGE_MANAGER" = "poetry" ]; then
        printf "  poetry run uvicorn app.main:app --reload\n"
    else
        printf "  source venv/bin/activate\n"
        printf "  uvicorn app.main:app --reload\n"
    fi
    printf "\nOr use the helper script:\n"
    printf "  ./scripts/dev_backend.sh\n"
    exit 0
elif [ "$FAILED" -le 3 ]; then
    printf "${YELLOW}Backend environment has some issues that should be fixed.${NC}\n"
    printf "Review the failures above and follow the suggested fixes.\n"
    exit 1
else
    printf "${RED}Backend environment is not properly configured.${NC}\n"
    printf "Please review the failures above and set up the environment.\n"
    printf "See: docs/DEV_SETUP_BACKEND.md\n"
    exit 1
fi
