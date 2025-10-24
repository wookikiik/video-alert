# Frontend Development Setup

This guide provides step-by-step instructions for setting up the Next.js frontend development environment for Video Alert.

## Prerequisites

### Required Software
- **Git** - Version control system
- **Node.js** - JavaScript runtime (see version requirements below)
- **Package Manager** - npm (comes with Node.js), yarn, or pnpm

### Determining Required Node.js Version

The project's Node.js version requirement can be determined by checking the following files in order:

1. **`.nvmrc`** (in repo root or frontend directory) - If present, contains the exact Node version
2. **`.node-version`** (in repo root or frontend directory) - Alternative Node version file
3. **`package.json`** - Check the `"engines"` field for Node version constraints
4. **Fallback** - If none of the above exist, use Node.js LTS (18.x or higher recommended)

**For this project**: Currently, there are no explicit version constraints. We recommend using Node.js **18.x or higher** (LTS version).

### Installing/Managing Node.js Versions

#### Using nvm (Node Version Manager)

```bash
# Install nvm (if not already installed)
# Visit: https://github.com/nvm-sh/nvm

# If .nvmrc exists, simply run:
nvm use

# Or install a specific version:
nvm install 18
nvm use 18

# Verify Node version
node --version
```

#### Using n (Alternative Node Manager)

```bash
# Install n (if not already installed)
npm install -g n

# Install and use LTS version
n lts

# Or install specific version
n 18
```

## Installation

### 1. Clone the Repository

```bash
git clone https://github.com/wookikiik/video-alert.git
cd video-alert
```

### 2. Navigate to Frontend Directory

```bash
cd frontend
```

### 3. Determine Package Manager

This project uses **npm** as indicated by the presence of `package-lock.json`.

**General rule**: Check for lockfiles to determine the package manager:
- `pnpm-lock.yaml` → use `pnpm install`
- `yarn.lock` → use `yarn install`
- `package-lock.json` → use `npm install`

### 4. Install Dependencies

```bash
npm install
```

This will install all dependencies listed in `package.json`.

## Environment Configuration

### Environment Variables

Create a `.env.local` file in the `frontend` directory by copying from the example:

```bash
# From the frontend directory
cp ../.env.example .env.local
```

Or manually create `.env.local` with the following variables:

```bash
# API Backend URL
NEXT_PUBLIC_API_BASE_URL=http://localhost:8000
```

### Required Environment Variables

| Variable | Description | Example Value |
|----------|-------------|---------------|
| `NEXT_PUBLIC_API_BASE_URL` | Backend API base URL. Used to call backend endpoints including `/admin/system-variables` and other API routes. | `http://localhost:8000` |

**Note**: `NEXT_PUBLIC_*` variables are exposed to the browser and embedded in the client-side bundle. Currently, no additional `NEXT_PUBLIC_*` variables are required beyond the API base URL.

### Environment Variable Scopes

- **`.env.local`** - Local development overrides (not committed to git)
- **`.env.example`** - Template with safe example values (committed to git)

## Running the Development Server

### Start the Dev Server

From the `frontend` directory:

```bash
npm run dev
```

The application will be available at [http://localhost:3000](http://localhost:3000).

### Available Scripts

The following scripts are defined in `package.json`:

| Command | Description |
|---------|-------------|
| `npm run dev` | Start the Next.js development server with hot reload |
| `npm run build` | Create an optimized production build |
| `npm start` | Start the production server (requires `npm run build` first) |
| `npm run lint` | Run ESLint to check code quality |

### Type Checking

TypeScript type checking is performed automatically by Next.js during development and build. To manually check types:

```bash
npx tsc --noEmit
```

### Testing

Currently, no test scripts are configured in `package.json`. If tests are added in the future, they will appear as `npm test` or similar commands.

## Authentication in Local Development

### Accessing Admin Routes

The admin UI requires authentication to access system variables and scheduling features.

**For local development**:
1. Refer to the [Backend Development Setup](../backend/README.md) for information on seeded admin credentials or development authentication
2. The backend may provide dev-only credentials or test user accounts
3. If the backend includes authentication bypass for local development, ensure your backend is configured appropriately

**Common approaches**:
- Use backend-seeded test admin credentials (username/password)
- Backend may provide JWT tokens for development
- Some setups may include a dev-only authentication bypass

Consult the backend documentation for specific authentication details.

## End-to-End Verification

### Complete Setup Verification

Follow these steps to verify the frontend and backend are properly connected:

#### 1. Start the Backend

Ensure the FastAPI backend is running. From the repo root:

```bash
cd backend
# Follow backend setup instructions (see backend/README.md)
# Typically:
python -m venv venv
source venv/bin/activate  # Windows: venv\Scripts\activate
pip install -r requirements.txt
uvicorn app.main:app --reload --host 0.0.0.0 --port 8000
```

Verify backend is running: [http://localhost:8000/health](http://localhost:8000/health)

#### 2. Configure Frontend Environment

Ensure `.env.local` is created with:

```bash
NEXT_PUBLIC_API_BASE_URL=http://localhost:8000
```

#### 3. Start the Frontend

From the `frontend` directory:

```bash
npm run dev
```

#### 4. Verify API Connection

Test the backend connection manually:

```bash
# Health check
curl http://localhost:8000/health

# API ping endpoint
curl http://localhost:8000/api/v1/ping

# System variables endpoint (may require authentication)
curl http://localhost:8000/api/v1/admin/system-variables
```

Expected response structure for system variables (example):
```json
{
  "monitored_url": "https://example.com",
  "telegram_channel_id": "@example_channel"
}
```

#### 5. Access the Frontend

Open [http://localhost:3000](http://localhost:3000) in your browser and verify:
- The homepage loads correctly
- Navigation to admin routes works (if authenticated)
- System variables display in the admin UI (read-only)

## Troubleshooting

### CORS / API Base URL Issues

**Symptoms**:
- Browser console shows CORS errors
- API requests fail with network errors
- 404 errors when calling backend endpoints

**Solutions**:
1. Verify `NEXT_PUBLIC_API_BASE_URL` in `.env.local` matches your backend URL exactly
   ```bash
   # Check your .env.local
   cat .env.local
   ```

2. **Restart the Next.js dev server** after changing `.env.local`:
   ```bash
   # Stop the server (Ctrl+C) and restart
   npm run dev
   ```

3. Verify backend CORS configuration allows requests from `http://localhost:3000`:
   - Check `backend/app/core/config.py` for `ALLOWED_ORIGINS`
   - Default should include `http://localhost:3000`

4. Common CORS symptoms:
   - Error: "Access-Control-Allow-Origin" header is missing
   - Error: "CORS policy: No 'Access-Control-Allow-Origin' header"
   
   → Ensure backend is running and CORS middleware is configured

### Environment Variables Not Picked Up

**Symptoms**:
- `NEXT_PUBLIC_API_BASE_URL` is undefined in browser console
- API calls go to wrong URL or undefined

**Solutions**:
1. **Restart the dev server**: Next.js loads environment variables on startup
   ```bash
   # Stop the server (Ctrl+C) and restart
   npm run dev
   ```

2. Verify `.env.local` is in the correct location:
   ```bash
   # Must be in frontend/ directory, not repo root
   ls -la frontend/.env.local
   ```

3. Check variable naming: Must start with `NEXT_PUBLIC_` to be exposed to browser

4. Clear Next.js cache:
   ```bash
   rm -rf frontend/.next
   npm run dev
   ```

### Node Version Mismatches

**Symptoms**:
- `npm install` fails with errors
- Runtime errors about unsupported Node features
- Build fails with syntax errors

**Solutions**:
1. Check required Node version:
   ```bash
   # If .nvmrc exists:
   cat .nvmrc
   
   # Check package.json engines (if defined):
   cat package.json | grep -A 3 '"engines"'
   ```

2. Switch to correct Node version:
   ```bash
   # Using nvm
   nvm install 18
   nvm use 18
   
   # Using n
   n 18
   ```

3. Verify Node version:
   ```bash
   node --version
   npm --version
   ```

### Clearing Caches / Reinstalling Dependencies

**When to do this**:
- Dependency conflicts
- Strange runtime errors after pulling new changes
- `npm install` warnings about outdated lockfile

**Steps**:
```bash
# Remove dependencies and caches
rm -rf node_modules
rm -rf .next
npm cache clean --force

# Reinstall
npm install

# Restart dev server
npm run dev
```

### Port Already in Use

**Symptom**:
- Error: "Port 3000 is already in use"

**Solutions**:
```bash
# Find and kill process using port 3000
# On macOS/Linux:
lsof -ti:3000 | xargs kill -9

# On Windows:
netstat -ano | findstr :3000
taskkill /PID <PID> /F

# Or use a different port:
PORT=3001 npm run dev
```

### Authentication Issues

**Symptoms**:
- Cannot access admin routes
- "Unauthorized" or 401 errors
- Redirected to login page repeatedly

**Solutions**:
1. Clear browser cookies and local storage:
   - Open browser DevTools (F12)
   - Application tab → Storage → Clear site data

2. Check for stale tokens:
   ```javascript
   // In browser console
   localStorage.clear()
   sessionStorage.clear()
   ```

3. Verify backend authentication is working:
   ```bash
   # Test backend auth endpoint directly
   curl http://localhost:8000/api/v1/auth/login
   ```

4. Check if backend dev credentials are configured (see backend docs)

### Lint Errors

**Symptom**:
- `npm run lint` shows errors

**Solutions**:
```bash
# Check what's failing
npm run lint

# Some linters support auto-fix
npx eslint . --fix

# If using Prettier:
npx prettier --write .
```

## Helper Script

A convenience script is provided at `scripts/dev_frontend.sh` that automates the setup:

```bash
# From repo root
./scripts/dev_frontend.sh
```

This script will:
- Check for and install dependencies if needed
- Create `.env.local` from `.env.example` if it doesn't exist
- Start the dev server

## Quick Reference

### Common Commands

```bash
# Navigate to frontend
cd frontend

# Install dependencies
npm install

# Start dev server
npm run dev

# Run linter
npm run lint

# Build for production
npm run build

# Type check
npx tsc --noEmit
```

### Environment Setup

```bash
# Create .env.local from example
cp ../.env.example frontend/.env.local

# Edit environment variables
nano frontend/.env.local  # or use your preferred editor
```

### Verification Checklist

- [ ] Node.js 18+ installed
- [ ] Dependencies installed (`npm install`)
- [ ] `.env.local` created and configured
- [ ] Backend running on port 8000
- [ ] Frontend dev server running on port 3000
- [ ] Can access [http://localhost:3000](http://localhost:3000)
- [ ] API health check responds: [http://localhost:8000/health](http://localhost:8000/health)

## Additional Resources

- [Next.js Documentation](https://nextjs.org/docs)
- [TypeScript Documentation](https://www.typescriptlang.org/docs/)
- [Tailwind CSS v4 Documentation](https://tailwindcss.com/docs)
- [shadcn/ui Components](https://ui.shadcn.com/)
- [Backend Development Setup](../backend/README.md)

## Files Added by This Setup

| File | Location | Purpose |
|------|----------|---------|
| `DEV_SETUP_FRONTEND.md` | `docs/` | This comprehensive setup guide |
| `.env.example` | Repository root | Template for environment variables |
| `dev_frontend.sh` | `scripts/` | Helper script to automate setup |

## API Endpoints Reference

The frontend connects to the following backend endpoints:

- **Health Check**: `GET /health`
- **API Ping**: `GET /api/v1/ping`
- **System Variables** (Admin): `GET /api/v1/admin/system-variables`
  - Returns monitored URL and Telegram channel ID
  - Read-only endpoint for admin UI display

For full API documentation, visit [http://localhost:8000/docs](http://localhost:8000/docs) when the backend is running.
