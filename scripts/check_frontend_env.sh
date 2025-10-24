#!/bin/sh
# Frontend Development Environment Verification Script
# This script checks if the Next.js frontend development environment is properly set up

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
FRONTEND_DIR="$REPO_ROOT/frontend"

print_header "Frontend Development Environment Verification"
printf "Repository: %s\n" "$REPO_ROOT"
printf "Frontend Directory: %s\n" "$FRONTEND_DIR"

# Check 1: Frontend directory exists
print_header "1. Directory Structure"
print_check "Frontend directory exists..."
if [ -d "$FRONTEND_DIR" ]; then
    print_pass
else
    print_fail "Frontend directory not found at $FRONTEND_DIR"
    exit 1
fi

# Check 2: Node.js installation
print_header "2. Node.js Installation"
print_check "Node.js is installed..."
if command -v node >/dev/null 2>&1; then
    NODE_VERSION=$(node --version 2>&1)
    print_pass
    print_info "Node.js version: $NODE_VERSION"
else
    print_fail "Node.js is not installed"
    print_info "Install from: https://nodejs.org/"
fi

print_check "Node.js version is 18 or higher..."
if command -v node >/dev/null 2>&1; then
    NODE_MAJOR=$(node -e "console.log(process.versions.node.split('.')[0])")
    if [ "$NODE_MAJOR" -ge 18 ]; then
        print_pass
    else
        print_warn "Node.js 18+ recommended, found v$NODE_MAJOR"
        print_info "Current LTS versions are preferred"
    fi
else
    print_fail "Node.js command not available"
fi

print_check "npm is installed..."
if command -v npm >/dev/null 2>&1; then
    NPM_VERSION=$(npm --version 2>&1)
    print_pass
    print_info "npm version: $NPM_VERSION"
else
    print_fail "npm is not installed"
fi

# Check 3: Package manager
print_header "3. Package Manager & Dependencies"
cd "$FRONTEND_DIR"

print_check "Package manager identified..."
PACKAGE_MANAGER=""
if [ -f "pnpm-lock.yaml" ]; then
    PACKAGE_MANAGER="pnpm"
    print_pass
    print_info "Using pnpm (detected pnpm-lock.yaml)"
elif [ -f "yarn.lock" ]; then
    PACKAGE_MANAGER="yarn"
    print_pass
    print_info "Using yarn (detected yarn.lock)"
elif [ -f "package-lock.json" ]; then
    PACKAGE_MANAGER="npm"
    print_pass
    print_info "Using npm (detected package-lock.json)"
else
    PACKAGE_MANAGER="npm"
    print_warn "No lockfile found, assuming npm"
fi

print_check "package.json exists..."
if [ -f "package.json" ]; then
    print_pass
else
    print_fail "package.json not found"
fi

# Check if package manager is installed
if [ "$PACKAGE_MANAGER" = "pnpm" ]; then
    print_check "pnpm is installed..."
    if command -v pnpm >/dev/null 2>&1; then
        print_pass
        PNPM_VERSION=$(pnpm --version 2>&1)
        print_info "pnpm version: $PNPM_VERSION"
    else
        print_fail "pnpm not installed"
        print_info "Install with: npm install -g pnpm"
    fi
elif [ "$PACKAGE_MANAGER" = "yarn" ]; then
    print_check "yarn is installed..."
    if command -v yarn >/dev/null 2>&1; then
        print_pass
        YARN_VERSION=$(yarn --version 2>&1)
        print_info "yarn version: $YARN_VERSION"
    else
        print_fail "yarn not installed"
        print_info "Install with: npm install -g yarn"
    fi
fi

# Check 4: Dependencies installed
print_header "4. Dependencies Installation"
print_check "node_modules/ exists..."
if [ -d "node_modules" ]; then
    print_pass
    NODE_MODULES_SIZE=$(du -sh node_modules 2>/dev/null | cut -f1)
    print_info "node_modules size: $NODE_MODULES_SIZE"
else
    print_fail "node_modules not found"
    if [ "$PACKAGE_MANAGER" = "pnpm" ]; then
        print_info "Install with: pnpm install"
    elif [ "$PACKAGE_MANAGER" = "yarn" ]; then
        print_info "Install with: yarn install"
    else
        print_info "Install with: npm install"
    fi
fi

print_check "Next.js is installed..."
if [ -d "node_modules/next" ]; then
    print_pass
    if [ -f "node_modules/next/package.json" ]; then
        NEXT_VERSION=$(cat node_modules/next/package.json | grep '"version"' | head -1 | cut -d'"' -f4)
        print_info "Next.js version: $NEXT_VERSION"
    fi
else
    print_fail "Next.js not installed in node_modules"
fi

print_check "React is installed..."
if [ -d "node_modules/react" ]; then
    print_pass
    if [ -f "node_modules/react/package.json" ]; then
        REACT_VERSION=$(cat node_modules/react/package.json | grep '"version"' | head -1 | cut -d'"' -f4)
        print_info "React version: $REACT_VERSION"
    fi
else
    print_fail "React not installed in node_modules"
fi

print_check "TypeScript is installed..."
if [ -d "node_modules/typescript" ]; then
    print_pass
    if [ -f "node_modules/typescript/package.json" ]; then
        TS_VERSION=$(cat node_modules/typescript/package.json | grep '"version"' | head -1 | cut -d'"' -f4)
        print_info "TypeScript version: $TS_VERSION"
    fi
else
    print_fail "TypeScript not installed in node_modules"
fi

# Check 5: Environment configuration
print_header "5. Environment Configuration"
print_check ".env.local file exists..."
if [ -f ".env.local" ]; then
    print_pass
else
    print_fail ".env.local file not found"
    print_info "Create from: cp ../.env.example .env.local"
fi

if [ -f ".env.local" ]; then
    print_check "NEXT_PUBLIC_API_BASE_URL is configured..."
    if grep -q "^NEXT_PUBLIC_API_BASE_URL=" .env.local 2>/dev/null; then
        print_pass
        API_URL=$(grep "^NEXT_PUBLIC_API_BASE_URL=" .env.local | cut -d'=' -f2)
        print_info "API Base URL: $API_URL"
    else
        print_fail "NEXT_PUBLIC_API_BASE_URL not found in .env.local"
    fi
fi

# Check 6: Configuration files
print_header "6. Configuration Files"
print_check "next.config.ts exists..."
if [ -f "next.config.ts" ] || [ -f "next.config.js" ]; then
    print_pass
else
    print_warn "next.config.ts/js not found (may be optional)"
fi

print_check "tsconfig.json exists..."
if [ -f "tsconfig.json" ]; then
    print_pass
else
    print_fail "tsconfig.json not found"
fi

print_check "tailwind.css configuration exists..."
if [ -f "postcss.config.mjs" ] || [ -f "postcss.config.js" ]; then
    print_pass
else
    print_warn "PostCSS config not found (may use default)"
fi

print_check "ESLint configuration exists..."
if [ -f "eslint.config.mjs" ] || [ -f ".eslintrc.json" ] || [ -f ".eslintrc.js" ]; then
    print_pass
else
    print_warn "ESLint config not found"
fi

# Check 7: Application structure
print_header "7. Application Structure"
print_check "src/ directory exists..."
if [ -d "src" ]; then
    print_pass
else
    print_fail "src/ directory not found"
fi

print_check "src/app/ directory exists (Next.js App Router)..."
if [ -d "src/app" ]; then
    print_pass
    PAGE_COUNT=$(find src/app -name "page.tsx" -o -name "page.ts" -o -name "page.jsx" -o -name "page.js" 2>/dev/null | wc -l)
    print_info "Page files found: $PAGE_COUNT"
else
    print_fail "src/app/ directory not found"
fi

print_check "src/components/ directory exists..."
if [ -d "src/components" ]; then
    print_pass
else
    print_warn "src/components/ directory not found (may be optional)"
fi

# Check 8: Build artifacts
print_header "8. Build Configuration"
print_check ".next/ directory status..."
if [ -d ".next" ]; then
    print_pass
    print_info "Build cache exists (good for faster rebuilds)"
else
    print_warn "No build cache found (will be created on first build)"
fi

# Check 9: Scripts availability
print_header "9. npm Scripts"
if [ -f "package.json" ]; then
    print_check "dev script exists..."
    if grep -q '"dev"' package.json 2>/dev/null; then
        print_pass
    else
        print_fail "dev script not found in package.json"
    fi

    print_check "build script exists..."
    if grep -q '"build"' package.json 2>/dev/null; then
        print_pass
    else
        print_fail "build script not found in package.json"
    fi

    print_check "lint script exists..."
    if grep -q '"lint"' package.json 2>/dev/null; then
        print_pass
    else
        print_warn "lint script not found in package.json"
    fi
fi

# Check 10: Port availability
print_header "10. Port Availability"
print_check "Port 3000 is available..."
if command -v lsof >/dev/null 2>&1; then
    if lsof -i :3000 >/dev/null 2>&1; then
        print_warn "Port 3000 is already in use"
        print_info "Check with: lsof -i :3000"
    else
        print_pass
    fi
elif command -v netstat >/dev/null 2>&1; then
    if netstat -tuln 2>/dev/null | grep -q ":3000 "; then
        print_warn "Port 3000 is already in use"
    else
        print_pass
    fi
else
    print_warn "Cannot check port availability (lsof/netstat not found)"
fi

# Check 11: Backend connectivity
print_header "11. Backend Connectivity"
print_check "Backend is reachable..."
BACKEND_URL="http://localhost:8000"
if [ -f ".env.local" ] && grep -q "^NEXT_PUBLIC_API_BASE_URL=" .env.local 2>/dev/null; then
    BACKEND_URL=$(grep "^NEXT_PUBLIC_API_BASE_URL=" .env.local | cut -d'=' -f2)
fi

if command -v curl >/dev/null 2>&1; then
    if curl -s -f -o /dev/null --max-time 2 "$BACKEND_URL/health" 2>/dev/null; then
        print_pass
        print_info "Backend responding at $BACKEND_URL"
    else
        print_warn "Backend not responding at $BACKEND_URL"
        print_info "Make sure backend is running before starting frontend"
    fi
else
    print_warn "Cannot check backend (curl not found)"
fi

# Summary
print_header "Verification Summary"
printf "\n"
printf "  ${GREEN}✓ Passed:${NC}   %d\n" "$PASSED"
printf "  ${RED}✗ Failed:${NC}   %d\n" "$FAILED"
printf "  ${YELLOW}⚠ Warnings:${NC} %d\n" "$WARNINGS"
printf "\n"

if [ "$FAILED" -eq 0 ]; then
    printf "${GREEN}Frontend environment is properly configured!${NC}\n"
    printf "Start the development server with:\n"
    printf "  cd frontend\n"
    if [ "$PACKAGE_MANAGER" = "pnpm" ]; then
        printf "  pnpm dev\n"
    elif [ "$PACKAGE_MANAGER" = "yarn" ]; then
        printf "  yarn dev\n"
    else
        printf "  npm run dev\n"
    fi
    printf "\nOr use the helper script:\n"
    printf "  ./scripts/dev_frontend.sh\n"
    exit 0
elif [ "$FAILED" -le 3 ]; then
    printf "${YELLOW}Frontend environment has some issues that should be fixed.${NC}\n"
    printf "Review the failures above and follow the suggested fixes.\n"
    exit 1
else
    printf "${RED}Frontend environment is not properly configured.${NC}\n"
    printf "Please review the failures above and set up the environment.\n"
    printf "See: docs/DEV_SETUP_FRONTEND.md\n"
    exit 1
fi
