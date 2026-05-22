# E2E Backend Setup Guide

## Prerequisites
- Python 3.11+
- Virtual environment (recommended)

## Manual Startup (Development)
Since Docker was not available in this environment, the backend was started manually using `uvicorn` with a SQLite database.

### 1. Environment Configuration
Create a `.env` file in the `backend/` directory:
```env
PORT=8000
DATABASE_URL=sqlite+aiosqlite:///./test.db
JWT_SECRET=change_me
SECRET_KEY=09d25e094faa6ca2556c818166b7a9563b93f7099f6f0f4caa6cf63b88e8d3e7
PROJECT_NAME="Smart Construction"
API_V1_STR="/api/v1"
```

### 2. Install Dependencies
```bash
cd backend
pip install -r requirements.txt
pip install aiosqlite matplotlib jinja2 pandas reportlab scikit-learn seaborn
```

### 3. Start Backend
```bash
# Windows (PowerShell)
$Env:DATABASE_URL="sqlite+aiosqlite:///./test.db"
python -m uvicorn app.main:app --host 0.0.0.0 --port 8000
```

## Verification
- **OpenAPI JSON**: [http://localhost:8000/api/v1/openapi.json](http://localhost:8000/api/v1/openapi.json)
- **Swagger UI**: [http://localhost:8000/docs](http://localhost:8000/docs)
- **Root URL**: [http://localhost:8000/](http://localhost:8000/)

## Ports
- **Backend API**: 8000

## Common Failures
- **Port 8000 already in use**: Kill the existing process (`Stop-Process -Id <PID> -Force` on Windows).
- **ModuleNotFoundError**: Install missing dependencies via `pip`.
- **Database Integrity Error**: Ensure `id` fields are cast to `UUID` objects when using SQLite with SQLAlchemy.
