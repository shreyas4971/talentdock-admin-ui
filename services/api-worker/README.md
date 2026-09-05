# TalentDock Cloudflare Worker Backend (V1)

Real backend for TalentDock built with **Cloudflare Workers**, **Hono**, **Cloudflare D1 (SQLite via Drizzle ORM)**, and **Cloudflare R2 Storage**.

---

## 🏗️ Architecture

```
Flutter Web (Candidate / Admin)
    ↓
HTTPS REST API (JSON & Multipart)
    ↓
Cloudflare Worker (Hono Router + Web Crypto JWT)
    ↓
Cloudflare D1 (Relational Data) + Cloudflare R2 (Resume & Document Storage)
```

---

## 🚀 Local Development Setup

### 1. Prerequisites
- Node.js 20+
- Cloudflare Wrangler CLI (`npm install -g wrangler` or via local `npx wrangler`)

### 2. Install Dependencies
```bash
cd services/api-worker
npm install
```

### 3. Initialize Local D1 Database & Run Migrations
```bash
# Apply schema migrations to the local D1 SQLite database
npm run drizzle:migrate:local
```

### 4. Seed Local Data (Admin Account & Sample Positions)
```bash
# Seed initial admin user (admin@talentdock.local / talentdock-temp) and positions
npm run seed:local
```

### 5. Start Local Worker Dev Server
```bash
npm run dev
```
The API server will run at `http://127.0.0.1:8787`.

---

## 🧪 Local API Testing

### Health Check:
```bash
curl http://127.0.0.1:8787/api/v1/health
```

### Public Positions:
```bash
curl http://127.0.0.1:8787/api/v1/positions/public
```

### Admin Login:
```bash
curl -X POST http://127.0.0.1:8787/api/v1/auth/login \
  -H "Content-Type: application/json" \
  -d '{"email":"admin@talentdock.local","password":"talentdock-temp"}'
```

---

## ☁️ Cloudflare Remote Deployment (When Ready)

When you are ready to provision Cloudflare infrastructure and deploy live:

### 1. Create Cloudflare D1 Database
```bash
npx wrangler d1 create talentdock-db
```
*(Copy the generated `database_id` into `wrangler.toml` under `[[d1_databases]]`).*

### 2. Create Cloudflare R2 Storage Bucket
```bash
npx wrangler r2 bucket create talentdock-resumes
```

### 3. Apply Migrations to Remote D1
```bash
npm run drizzle:migrate:remote
```

### 4. Deploy Worker
```bash
npm run deploy
```
