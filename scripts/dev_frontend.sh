#!/bin/sh
# Frontend Development Helper Script
# This script automates the setup and startup of the Next.js frontend development server

# Usage: ./dev_frontend.sh [--bypass]
#   ./scripts/dev_frontend.sh           # Interactive mode (prompts for user input)
#   ./scripts/dev_frontend.sh --bypass  # Bypass mode (no prompts, auto-proceed)

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
FRONTEND_DIR="$REPO_ROOT/frontend"

print_info "Video Alert Frontend Development Setup"
print_info "========================================"
echo ""

# Check if we're in the right directory
if [ ! -d "$FRONTEND_DIR" ]; then
    print_error "Frontend directory not found at: $FRONTEND_DIR"
    exit 1
fi

cd "$FRONTEND_DIR"
print_info "Working directory: $FRONTEND_DIR"
echo ""

# Step 1: Detect package manager
print_info "Step 1: Detecting package manager..."
PACKAGE_MANAGER=""
INSTALL_CMD=""
DEV_CMD=""

if [ -f "pnpm-lock.yaml" ]; then
    PACKAGE_MANAGER="pnpm"
    INSTALL_CMD="pnpm install"
    DEV_CMD="pnpm dev"
elif [ -f "yarn.lock" ]; then
    PACKAGE_MANAGER="yarn"
    INSTALL_CMD="yarn install"
    DEV_CMD="yarn dev"
elif [ -f "package-lock.json" ]; then
    PACKAGE_MANAGER="npm"
    INSTALL_CMD="npm install"
    DEV_CMD="npm run dev"
else
    print_warning "No lockfile found, defaulting to npm"
    PACKAGE_MANAGER="npm"
    INSTALL_CMD="npm install"
    DEV_CMD="npm run dev"
fi

print_success "Package manager: $PACKAGE_MANAGER"
echo ""

# Step 2: Check and install dependencies
print_info "Step 2: Checking dependencies..."
if [ ! -d "node_modules" ]; then
    print_warning "node_modules not found. Installing dependencies..."
    print_info "Running: $INSTALL_CMD"
    $INSTALL_CMD
    print_success "Dependencies installed successfully"
else
    print_success "node_modules already exists"
    print_info "To reinstall dependencies, run: $INSTALL_CMD"
fi
echo ""

# Step 3: Check for .env.local
print_info "Step 3: Checking environment configuration..."
if [ ! -f ".env.local" ]; then
    print_warning ".env.local not found"
    
    if [ -f "$REPO_ROOT/.env.example" ]; then
        print_info "Would you like to create .env.local from .env.example? (y/n)"
        printf "Choice: "
        read -r create_env
        
        if [ "$create_env" = "y" ] || [ "$create_env" = "Y" ]; then
            cp "$REPO_ROOT/.env.example" ".env.local"
            print_success "Created .env.local from .env.example"
            print_warning "IMPORTANT: Please review and edit .env.local with your settings"
            print_info "Default API URL: http://localhost:8000"
            echo ""
            print_info "Press Enter to continue after editing, or Ctrl+C to exit..."
            read -r dummy
        else
            print_warning "Skipping .env.local creation"
            print_info "You can create it manually by copying .env.example:"
            print_info "  cp $REPO_ROOT/.env.example .env.local"
        fi
    else
        print_error ".env.example not found in repository root"
        print_info "Please create .env.local manually with the following content:"
        echo ""
        echo "NEXT_PUBLIC_API_BASE_URL=http://localhost:8000"
        echo ""
        print_info "Press Enter to continue or Ctrl+C to exit and create .env.local"
        read -r dummy
    fi
else
    print_success ".env.local already exists"
    print_info "Current configuration:"
    grep "NEXT_PUBLIC_API_BASE_URL" .env.local 2>/dev/null || print_warning "NEXT_PUBLIC_API_BASE_URL not found in .env.local"
fi
echo ""

# Step 4: Pre-flight checks
print_info "Step 4: Running pre-flight checks..."

# Check Node version
if command -v node >/dev/null 2>&1; then
    NODE_VERSION=$(node --version)
    print_success "Node.js version: $NODE_VERSION"
else
    print_error "Node.js is not installed"
    print_info "Please install Node.js 18+ from https://nodejs.org/"
    exit 1
fi

# Check if backend is running
if [ "$BYPASS_MODE" = true ]; then
    print_warning "Skipping backend check (--bypass flag provided)"
else
    print_info "Checking if backend is running..."
    if command -v curl >/dev/null 2>&1; then
        if curl -s -f -o /dev/null "http://localhost:8000/health" 2>/dev/null; then
            print_success "Backend is running at http://localhost:8000"
        else
            print_warning "Backend does not appear to be running at http://localhost:8000"
            print_info "Make sure to start the backend first (see backend/README.md)"
            print_info "Backend should be running before starting the frontend"
            echo ""
            print_info "Continue anyway? (y/n)"
            printf "Choice: "
            read -r continue_anyway
            if [ "$continue_anyway" != "y" ] && [ "$continue_anyway" != "Y" ]; then
                print_info "Exiting. Please start the backend first."
                exit 0
            fi
        fi
    else
        print_warning "curl not found, skipping backend check"
    fi
fi
echo ""

# Step 5: Start development server
print_info "Step 5: Starting development server..."
print_success "Running: $DEV_CMD"
echo ""
print_info "========================================"
print_info "Frontend will be available at: http://localhost:3000"
print_info "Backend API should be at: http://localhost:8000"
print_info "Press Ctrl+C to stop the server"
print_info "========================================"
echo ""

# Start the dev server
exec $DEV_CMD
