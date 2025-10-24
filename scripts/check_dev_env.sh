#!/bin/sh
# Master Development Environment Verification Script
# This script checks if both frontend and backend development environments are properly set up

set -e  # Exit on error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
MAGENTA='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Get the script directory
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

# Print header
printf "\n"
printf "${MAGENTA}╔════════════════════════════════════════════════════════════════╗${NC}\n"
printf "${MAGENTA}║                                                                ║${NC}\n"
printf "${MAGENTA}║         ${CYAN}Video Alert - Development Environment Check${MAGENTA}         ║${NC}\n"
printf "${MAGENTA}║                                                                ║${NC}\n"
printf "${MAGENTA}╚════════════════════════════════════════════════════════════════╝${NC}\n"
printf "\n"
printf "${BLUE}Repository:${NC} %s\n" "$REPO_ROOT"
printf "${BLUE}Date:${NC} $(date)\n"
printf "\n"

# Function to print section headers
print_section() {
    printf "\n"
    printf "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}\n"
    printf "${CYAN}  %s${NC}\n" "$1"
    printf "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}\n"
    printf "\n"
}

# Check if scripts exist
BACKEND_SCRIPT="$SCRIPT_DIR/check_backend_env.sh"
FRONTEND_SCRIPT="$SCRIPT_DIR/check_frontend_env.sh"

if [ ! -f "$BACKEND_SCRIPT" ]; then
    printf "${RED}ERROR:${NC} Backend verification script not found at $BACKEND_SCRIPT\n"
    exit 1
fi

if [ ! -f "$FRONTEND_SCRIPT" ]; then
    printf "${RED}ERROR:${NC} Frontend verification script not found at $FRONTEND_SCRIPT\n"
    exit 1
fi

# Make scripts executable if they aren't
chmod +x "$BACKEND_SCRIPT" 2>/dev/null || true
chmod +x "$FRONTEND_SCRIPT" 2>/dev/null || true

# Track results
BACKEND_EXIT_CODE=0
FRONTEND_EXIT_CODE=0

# Run backend check
print_section "🔧 BACKEND ENVIRONMENT CHECK"
if "$BACKEND_SCRIPT"; then
    BACKEND_EXIT_CODE=0
    BACKEND_STATUS="${GREEN}✓ PASS${NC}"
else
    BACKEND_EXIT_CODE=$?
    if [ $BACKEND_EXIT_CODE -eq 1 ] && [ "$BACKEND_EXIT_CODE" -le 1 ]; then
        BACKEND_STATUS="${YELLOW}⚠ PARTIAL${NC}"
    else
        BACKEND_STATUS="${RED}✗ FAIL${NC}"
    fi
fi

# Run frontend check
print_section "🎨 FRONTEND ENVIRONMENT CHECK"
if "$FRONTEND_SCRIPT"; then
    FRONTEND_EXIT_CODE=0
    FRONTEND_STATUS="${GREEN}✓ PASS${NC}"
else
    FRONTEND_EXIT_CODE=$?
    if [ $FRONTEND_EXIT_CODE -eq 1 ] && [ "$FRONTEND_EXIT_CODE" -le 1 ]; then
        FRONTEND_STATUS="${YELLOW}⚠ PARTIAL${NC}"
    else
        FRONTEND_STATUS="${RED}✗ FAIL${NC}"
    fi
fi

# Final summary
printf "\n\n"
printf "${MAGENTA}╔════════════════════════════════════════════════════════════════╗${NC}\n"
printf "${MAGENTA}║                                                                ║${NC}\n"
printf "${MAGENTA}║                      ${CYAN}OVERALL SUMMARY${MAGENTA}                         ║${NC}\n"
printf "${MAGENTA}║                                                                ║${NC}\n"
printf "${MAGENTA}╚════════════════════════════════════════════════════════════════╝${NC}\n"
printf "\n"

printf "  ${BLUE}Backend Environment:${NC}  %b\n" "$BACKEND_STATUS"
printf "  ${BLUE}Frontend Environment:${NC} %b\n" "$FRONTEND_STATUS"
printf "\n"

# Overall assessment
if [ $BACKEND_EXIT_CODE -eq 0 ] && [ $FRONTEND_EXIT_CODE -eq 0 ]; then
    printf "${GREEN}═══════════════════════════════════════════════════════════════${NC}\n"
    printf "${GREEN}✓ All environments are properly configured!${NC}\n"
    printf "${GREEN}═══════════════════════════════════════════════════════════════${NC}\n"
    printf "\n"
    printf "${BLUE}Quick Start:${NC}\n"
    printf "\n"
    printf "  ${CYAN}1. Start Backend:${NC}\n"
    printf "     cd backend && source venv/bin/activate\n"
    printf "     uvicorn app.main:app --reload\n"
    printf "     ${YELLOW}or${NC} ./scripts/dev_backend.sh\n"
    printf "\n"
    printf "  ${CYAN}2. Start Frontend:${NC}\n"
    printf "     cd frontend && npm run dev\n"
    printf "     ${YELLOW}or${NC} ./scripts/dev_frontend.sh\n"
    printf "\n"
    printf "  ${CYAN}3. Access:${NC}\n"
    printf "     Frontend:  ${GREEN}http://localhost:3000${NC}\n"
    printf "     Backend:   ${GREEN}http://localhost:8000${NC}\n"
    printf "     API Docs:  ${GREEN}http://localhost:8000/docs${NC}\n"
    printf "\n"
    exit 0
elif [ $BACKEND_EXIT_CODE -le 1 ] && [ $FRONTEND_EXIT_CODE -le 1 ]; then
    printf "${YELLOW}═══════════════════════════════════════════════════════════════${NC}\n"
    printf "${YELLOW}⚠ Environments have some issues that should be reviewed.${NC}\n"
    printf "${YELLOW}═══════════════════════════════════════════════════════════════${NC}\n"
    printf "\n"
    printf "Review the warnings and failures above.\n"
    printf "Most issues can be fixed by following the setup documentation:\n"
    printf "  • Backend:  ${BLUE}docs/DEV_SETUP_BACKEND.md${NC}\n"
    printf "  • Frontend: ${BLUE}docs/DEV_SETUP_FRONTEND.md${NC}\n"
    printf "\n"
    exit 1
else
    printf "${RED}═══════════════════════════════════════════════════════════════${NC}\n"
    printf "${RED}✗ One or more environments are not properly configured.${NC}\n"
    printf "${RED}═══════════════════════════════════════════════════════════════${NC}\n"
    printf "\n"
    printf "Please review the failures above and set up the environments.\n"
    printf "\n"
    printf "${BLUE}Setup Documentation:${NC}\n"
    printf "  • Backend:  ${BLUE}docs/DEV_SETUP_BACKEND.md${NC}\n"
    printf "  • Frontend: ${BLUE}docs/DEV_SETUP_FRONTEND.md${NC}\n"
    printf "\n"
    printf "${BLUE}Helper Scripts:${NC}\n"
    printf "  • Backend:  ${BLUE}./scripts/dev_backend.sh${NC}\n"
    printf "  • Frontend: ${BLUE}./scripts/dev_frontend.sh${NC}\n"
    printf "\n"
    exit 1
fi
