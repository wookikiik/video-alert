# 개발 환경 체크리스트

이 문서는 Video Alert 프로젝트의 프론트엔드(frontend)와 백엔드(backend) 개발 환경이 올바르게 구성되어 있는지 확인하기 위한 체크리스트입니다.

## 🚀 빠른 검증

모든 환경을 한 번에 검증하려면:

```bash
./scripts/check_dev_env.sh
```

개별 환경을 검증하려면:

```bash
# 백엔드만 검증
./scripts/check_backend_env.sh

# 프론트엔드만 검증
./scripts/check_frontend_env.sh
```

---

## 📋 백엔드 개발 환경 체크리스트

### 1. 디렉토리 구조
- [ ] `backend/` 디렉토리가 존재하는가?
- [ ] `backend/app/` 디렉토리가 존재하는가?
- [ ] `backend/app/main.py` 파일이 존재하는가?
- [ ] `backend/tests/` 디렉토리가 존재하는가?

### 2. Python 설치 및 버전
- [ ] Python이 설치되어 있는가? (`python --version` 또는 `python3 --version`)
- [ ] Python 버전이 3.8 이상인가? (권장: 3.11.9)
- [ ] `pip`가 설치되어 있는가? (`pip --version`)

### 3. 가상 환경 (Virtual Environment)
- [ ] `backend/venv/` 디렉토리가 존재하는가?
- [ ] 가상 환경 활성화 스크립트가 존재하는가? (`venv/bin/activate`)
- [ ] 가상 환경을 활성화할 수 있는가?
  ```bash
  cd backend
  source venv/bin/activate  # Linux/Mac
  # 또는
  venv\Scripts\activate  # Windows
  ```

### 4. Python 패키지 의존성
- [ ] `backend/requirements.txt` 파일이 존재하는가?
- [ ] 필수 패키지가 설치되어 있는가?
  - [ ] FastAPI (`import fastapi`)
  - [ ] Uvicorn (`import uvicorn`)
  - [ ] Pydantic (`import pydantic`)
  - [ ] Playwright (`import playwright`)
  - [ ] SQLAlchemy (`import sqlalchemy`)
  - [ ] Pytest (`import pytest`)

### 5. Playwright 브라우저
- [ ] Playwright 브라우저가 설치되어 있는가?
- [ ] 브라우저 캐시 디렉토리가 존재하는가? (`~/.cache/ms-playwright/`)
- [ ] 설치 확인: `python -m playwright --version`

### 6. 환경 변수 설정
- [ ] `backend/.env` 파일이 존재하는가?
- [ ] 다음 필수 환경 변수가 설정되어 있는가?
  - [ ] `DATABASE_URL` - 데이터베이스 연결 문자열
  - [ ] `TELEGRAM_BOT_TOKEN` - 텔레그램 봇 토큰
  - [ ] `TELEGRAM_CHANNEL_ID` - 텔레그램 채널/그룹 ID
  - [ ] `MONITORED_URL` - 모니터링할 URL

### 7. 데이터베이스
- [ ] 데이터베이스 파일이 존재하는가? (`backend/dev.db`)
- [ ] 데이터베이스가 초기화되었는가?
  ```bash
  python scripts/init_db.py
  ```

### 8. 포트 가용성
- [ ] 포트 8000이 사용 가능한가?
  ```bash
  lsof -i :8000  # 결과가 없어야 함
  ```

### 9. 서버 실행
- [ ] 개발 서버를 시작할 수 있는가?
  ```bash
  cd backend
  source venv/bin/activate
  uvicorn app.main:app --reload
  ```
- [ ] API 문서에 접근할 수 있는가? http://localhost:8000/docs
- [ ] Health check 엔드포인트가 응답하는가? http://localhost:8000/health

### 10. 테스트
- [ ] 테스트를 실행할 수 있는가?
  ```bash
  cd backend
  pytest
  ```

---

## 🎨 프론트엔드 개발 환경 체크리스트

### 1. 디렉토리 구조
- [ ] `frontend/` 디렉토리가 존재하는가?
- [ ] `frontend/src/` 디렉토리가 존재하는가?
- [ ] `frontend/src/app/` 디렉토리가 존재하는가? (Next.js App Router)
- [ ] `frontend/src/components/` 디렉토리가 존재하는가?

### 2. Node.js 설치 및 버전
- [ ] Node.js가 설치되어 있는가? (`node --version`)
- [ ] Node.js 버전이 18 이상인가? (권장: 18.x LTS 이상)
- [ ] npm이 설치되어 있는가? (`npm --version`)

### 3. 패키지 매니저
- [ ] 패키지 매니저 잠금 파일이 존재하는가?
  - [ ] `package-lock.json` (npm)
  - [ ] `yarn.lock` (yarn)
  - [ ] `pnpm-lock.yaml` (pnpm)
- [ ] 사용 중인 패키지 매니저가 설치되어 있는가?

### 4. 의존성 패키지
- [ ] `frontend/package.json` 파일이 존재하는가?
- [ ] `frontend/node_modules/` 디렉토리가 존재하는가?
- [ ] 필수 패키지가 설치되어 있는가?
  - [ ] Next.js (`node_modules/next/`)
  - [ ] React (`node_modules/react/`)
  - [ ] TypeScript (`node_modules/typescript/`)

### 5. 환경 변수 설정
- [ ] `frontend/.env.local` 파일이 존재하는가?
- [ ] 다음 필수 환경 변수가 설정되어 있는가?
  - [ ] `NEXT_PUBLIC_API_BASE_URL` - 백엔드 API URL (예: http://localhost:8000)

### 6. 설정 파일
- [ ] TypeScript 설정 파일이 존재하는가? (`tsconfig.json`)
- [ ] Next.js 설정 파일이 존재하는가? (`next.config.ts` 또는 `next.config.js`)
- [ ] ESLint 설정 파일이 존재하는가? (`eslint.config.mjs`)
- [ ] PostCSS 설정 파일이 존재하는가? (`postcss.config.mjs`)

### 7. 포트 가용성
- [ ] 포트 3000이 사용 가능한가?
  ```bash
  lsof -i :3000  # 결과가 없어야 함
  ```

### 8. 백엔드 연결성
- [ ] 백엔드가 실행 중인가?
- [ ] 백엔드 API에 접근할 수 있는가?
  ```bash
  curl http://localhost:8000/health
  ```

### 9. 개발 서버 실행
- [ ] 개발 서버를 시작할 수 있는가?
  ```bash
  cd frontend
  npm run dev
  ```
- [ ] 프론트엔드에 접근할 수 있는가? http://localhost:3000

### 10. npm 스크립트
- [ ] `package.json`에 다음 스크립트가 정의되어 있는가?
  - [ ] `dev` - 개발 서버 시작
  - [ ] `build` - 프로덕션 빌드
  - [ ] `lint` - 코드 린팅

---

## 🔍 종합 검증 절차

### 자동 검증
```bash
# 프로젝트 루트에서 실행
./scripts/check_dev_env.sh
```

이 스크립트는 다음을 자동으로 검증합니다:
- 백엔드 환경 설정
- 프론트엔드 환경 설정
- 모든 필수 도구 및 패키지
- 포트 가용성
- 환경 변수 설정
- 서버 연결성

### 수동 검증

#### 백엔드 검증
```bash
# 1. 백엔드 디렉토리로 이동
cd backend

# 2. 가상 환경 활성화
source venv/bin/activate  # Linux/Mac
# 또는 venv\Scripts\activate  # Windows

# 3. Python 패키지 확인
python -c "import fastapi, uvicorn, playwright"

# 4. 환경 변수 확인
cat .env

# 5. 데이터베이스 확인
ls -l dev.db

# 6. 서버 시작
uvicorn app.main:app --reload

# 7. 다른 터미널에서 테스트
curl http://localhost:8000/health
curl http://localhost:8000/docs
```

#### 프론트엔드 검증
```bash
# 1. 프론트엔드 디렉토리로 이동
cd frontend

# 2. Node.js 버전 확인
node --version

# 3. 의존성 확인
ls node_modules/next node_modules/react

# 4. 환경 변수 확인
cat .env.local

# 5. 개발 서버 시작
npm run dev

# 6. 다른 터미널에서 테스트
curl http://localhost:3000
```

---

## 🛠️ 문제 해결

### 백엔드 문제

**Python이 설치되어 있지 않은 경우:**
```bash
# Python 설치
# macOS: brew install python@3.11
# Ubuntu: sudo apt-get install python3.11
# Windows: https://www.python.org/ 에서 다운로드
```

**가상 환경이 없는 경우:**
```bash
cd backend
python -m venv venv
source venv/bin/activate
pip install -r requirements.txt
```

**Playwright 브라우저가 없는 경우:**
```bash
cd backend
source venv/bin/activate
python -m playwright install
```

**환경 변수가 설정되지 않은 경우:**
```bash
cd backend
cp .env.example .env
# .env 파일을 편집하여 실제 값을 입력
```

**데이터베이스가 초기화되지 않은 경우:**
```bash
python scripts/init_db.py
```

### 프론트엔드 문제

**Node.js가 설치되어 있지 않은 경우:**
```bash
# nvm 사용 (권장)
nvm install 18
nvm use 18

# 또는 직접 설치
# https://nodejs.org/ 에서 다운로드
```

**의존성이 설치되지 않은 경우:**
```bash
cd frontend
npm install
```

**환경 변수가 설정되지 않은 경우:**
```bash
cd frontend
cp ../.env.example .env.local
# .env.local 파일 편집
```

**포트가 이미 사용 중인 경우:**
```bash
# 포트 8000 또는 3000을 사용하는 프로세스 찾기
lsof -i :8000
lsof -i :3000

# 프로세스 종료
kill -9 <PID>

# 또는 다른 포트 사용
PORT=3001 npm run dev
```

---

## 📚 추가 자료

### 상세 설정 가이드
- **백엔드:** [docs/DEV_SETUP_BACKEND.md](../docs/DEV_SETUP_BACKEND.md)
- **프론트엔드:** [docs/DEV_SETUP_FRONTEND.md](../docs/DEV_SETUP_FRONTEND.md)
- **메인 README:** [README.md](../README.md)

### 개발 스크립트
- **백엔드 자동 설정:** `./scripts/dev_backend.sh`
- **프론트엔드 자동 설정:** `./scripts/dev_frontend.sh`
- **환경 검증:** `./scripts/check_dev_env.sh`

### 온라인 문서
- [FastAPI 공식 문서](https://fastapi.tiangolo.com/)
- [Next.js 공식 문서](https://nextjs.org/docs)
- [Playwright 공식 문서](https://playwright.dev/python/)

---

## ✅ 최종 확인

모든 항목을 확인한 후, 다음 명령으로 전체 환경을 검증하세요:

```bash
./scripts/check_dev_env.sh
```

이 스크립트는 모든 체크리스트 항목을 자동으로 검증하고 결과를 보고합니다.

### 성공 기준
- ✓ 백엔드 환경: PASS
- ✓ 프론트엔드 환경: PASS
- 모든 필수 항목이 정상적으로 구성되어 있어야 합니다.

### 다음 단계
환경이 올바르게 구성되면:
1. 백엔드 서버 시작: `./scripts/dev_backend.sh`
2. 프론트엔드 서버 시작: `./scripts/dev_frontend.sh`
3. 브라우저에서 http://localhost:3000 접속
4. API 문서 확인: http://localhost:8000/docs
