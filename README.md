# Aarogyam — Project Structure

This is a monorepo containing the frontend, backend, and database configuration for the Aarogyam healthcare platform.

## 📁 Directory Structure
- `frontend/`: Flutter mobile & web application.
- `backend/`: Node.js Express API.
- `database/`: PostgreSQL configuration using Docker.

## 🚀 Getting Started

### 1. Database
Ensure you have Docker installed.
```bash
cd database
docker-compose up -d
```

### 2. Backend
```bash
cd backend
npm install
npm start
```
Make sure to configure the `.env` file in the `backend/` directory.

### 3. Frontend
```bash
cd frontend
flutter pub get
flutter run
```

## 🛠️ Tech Stack
- **Frontend:** Flutter, GoRouter, Riverpod, Dio.
- **Backend:** Node.js, Express, PostgreSQL (pg).
- **Database:** PostgreSQL via Docker.
- **Infrastructure:** AWS (Planned).
