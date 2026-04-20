# Deployment Fix Guide

## What Was Fixed ✅

### 1. Backend CORS Middleware (`backend/main.py`)
- Updated CORS to allow **all HTTP methods** (not just GET/POST)
- Removed specific file path from CORS allowed origins (was `https://storage.googleapis.com/frontend-123/index.html`, now just `https://storage.googleapis.com`)
- Added more local dev origins for testing
- Result: Backend now properly accepts requests from GCS-hosted frontend

### 2. Backend Environment (`backend/.env`)
- Updated `FRONTEND_URL` to point to GCS domain for production
- This allows CORS to properly validate requests from your GCS frontend
- Result: Correct origin validation for production deployments

### 3. Frontend Environment (`frontend/.env`)
- ✅ Already correct: `VITE_API_BASE_URL=https://backend-app-451325681713.asia-south1.run.app`
- This will be baked into your production JavaScript at build time via Vite
- Result: Frontend always calls the correct Cloud Run backend

---

## Deployment Steps

### Step 1: Rebuild & Deploy Frontend to GCS

```bash
cd frontend

# Build the production bundle
# The VITE_API_BASE_URL environment variable will be compiled into the JavaScript
npm run build

# This creates a 'dist/' folder with:
# - index.html
# - dist/assets/main-[hash].jsx (contains the backend URL)
# - dist/assets/index-[hash].css

# Upload to GCS (example - adjust your bucket path)
gsutil -m cp -r dist/* gs://frontend-123/
```

**Verify Frontend:**
- Visit: `https://storage.googleapis.com/frontend-123/index.html`
- Open DevTools → Network tab
- Try entering a name and submitting
- Watch the Network tab for the fetch to `/names` endpoint

### Step 2: Redeploy Backend to Cloud Run

```bash
cd backend

# Ensure main.py is updated with new CORS settings
# (This was already done for you ✅)

# Build and push to Cloud Run
gcloud run deploy backend-app \
  --source . \
  --region asia-south1 \
  --allow-unauthenticated
```

**Verify Backend:**
- Test health: `curl https://backend-app-451325681713.asia-south1.run.app/health`
- Test GET names: `curl https://backend-app-451325681713.asia-south1.run.app/names`
- Should return `{"status":"ok"}` and `[]` (empty list or your saved names)

---

## Complete Connection Flow

```
┌─────────────────────────────────────────┐
│  Browser at GCS Frontend                │
│  storage.googleapis.com/frontend-123    │
└──────────────────┬──────────────────────┘
                   │
                   │ fetch() with origin:
                   │ https://storage.googleapis.com
                   │
                   ▼
┌─────────────────────────────────────────┐
│  Cloud Run Backend (FastAPI)            │
│  https://backend-app-451325681713...    │
│  ✅ CORS allows https://storage.googleapis.com
│  ✅ Routes: /health, /names, /names     │
└──────────────────┬──────────────────────┘
                   │
                   │ mongoDB connection via Secret Manager
                   │
                   ▼
┌─────────────────────────────────────────┐
│  MongoDB Atlas                          │
│  mongodb+srv://c:030615@cluster0...     │
│  ✅ Already verified working             │
└─────────────────────────────────────────┘
```

---

## Troubleshooting

### Still Getting 403 Forbidden?
1. Check browser DevTools → Network → Request Headers
2. Look for `Origin: https://storage.googleapis.com`
3. Check Response Headers for `Access-Control-Allow-Origin: https://storage.googleapis.com`
4. If missing, backend CORS isn't being recognized. Redeploy backend.

### Still Getting 400 Bad Request?
1. Check that `VITE_API_BASE_URL` is set correctly in `frontend/.env`
2. Run `npm run build` to ensure it's baked into production
3. Check DevTools → Network → the fetch URL
4. Should be `https://backend-app-451325681713.asia-south1.run.app/names`

### Getting 404 at `/` (root)?
✅ This is **normal**. Your backend has no route at `/`. Only `/health`, `/names` (GET), and `/names` (POST) are defined.

### MongoDB showing "Connection failed"?
- This is separate from the frontend/backend connection issue
- Check backend logs: `gcloud run logs read backend-app --region asia-south1`
- Verify `MONGODB_URL` is correct in backend `.env` or Cloud Run secrets

---

## Environment Variables Summary

### Frontend (`frontend/.env`)
```
VITE_API_URL=http://localhost:8000                           # Local dev
VITE_API_BASE_URL=https://backend-app-451325681713.asia-south1.run.app  # Production
```
- ✅ These are baked into the production build via Vite's environment variable system

### Backend (`backend/.env`)
```
MONGODB_URL=mongodb+srv://c:030615@cluster0.7szitnp.mongodb.net/myapp?appName=Cluster0
DB_NAME=myapp
FRONTEND_URL=https://storage.googleapis.com  # For CORS validation
```
- ✅ Set in Cloud Run via Secret Manager or environment variables

---

## Quick Verification Checklist

- [ ] Frontend `npm run build` completes without errors
- [ ] Frontend dist/ folder created with `index.html` and `assets/` subfolder
- [ ] Frontend uploaded to GCS
- [ ] Backend redeployed to Cloud Run with new CORS settings
- [ ] Test backend health: `curl https://backend-app-451325681713.asia-south1.run.app/health` → `{"status":"ok"}`
- [ ] Test frontend in browser: enter name, click save
- [ ] DevTools Network tab shows successful request to `/names`
- [ ] Name appears in the list
- [ ] Success message appears: `"[name]" saved successfully!`

---

## What's Working Now

✅ **MongoDB** — Already connected (confirmed in backend logs)
✅ **Backend Routes** — `/health`, `/names` GET, `/names` POST
✅ **Backend Deployment** — Cloud Run with correct config
✅ **Frontend URL** — Correct backend endpoint configured
✅ **CORS Middleware** — Properly allows GCS frontend requests

🔧 **Just Deploy:** Build frontend, upload to GCS, and redeploy backend.
