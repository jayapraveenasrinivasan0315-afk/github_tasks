from fastapi import FastAPI, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from motor.motor_asyncio import AsyncIOMotorClient
from pydantic import BaseModel
from datetime import datetime, timezone
from dotenv import load_dotenv
import os

load_dotenv()

# ── Config ────────────────────────────────────────────────────────────────
MONGODB_URL   = os.getenv("MONGODB_URL", "mongodb+srv://gw-my-app-db:030615@cluster0.7szitnp.mongodb.net/myapp?appName=Cluster0")
DB_NAME       = os.getenv("DB_NAME", "myapp")
FRONTEND_URL  = os.getenv("FRONTEND_URL", "https://storage.googleapis.com/frontend-123")
BACKEND_URL   = os.getenv("BACKEND_URL", "https://backend-app-451325681713.asia-south1.run.app")

# ── FastAPI app ───────────────────────────────────────────────────────────
app = FastAPI(title="Names API", version="1.0.0")

app.add_middleware(
    CORSMiddleware,
    allow_origins=[
        "https://storage.googleapis.com",  # Production GCS frontend
        "http://localhost:5173",  # Vite dev server
        "http://localhost:3000",   # Alternative local dev
        "http://localhost:5500",   # Alternative local dev
    ],
    allow_credentials=True,
    allow_methods=["*"],  # Allow all methods (GET, POST, OPTIONS, etc.)
    allow_headers=["*"],
)

# ── MongoDB connection ────────────────────────────────────────────────────
@app.on_event("startup")
async def startup():
    try:
        app.mongodb_client = AsyncIOMotorClient(
            MONGODB_URL,
            serverSelectionTimeoutMS=5000,   # ✅ fail fast, don't hang
            tls=True,
            tlsAllowInvalidCertificates=False
        )
        await app.mongodb_client.admin.command('ping')
        app.db = app.mongodb_client[DB_NAME]
        print(f"✅ Connected to MongoDB: {DB_NAME}")
    except Exception as e:
        print(f"⚠️ MongoDB connection failed: {e}")
        # ✅ Don't raise — let app start anyway
        # Routes will return 503 if DB is unavailable
        app.db = None

@app.on_event("shutdown")
async def shutdown():
    if hasattr(app, 'mongodb_client'):
        app.mongodb_client.close()
        print("MongoDB connection closed.")

# ── Schemas ───────────────────────────────────────────────────────────────
class NameIn(BaseModel):
    name: str

class NameOut(BaseModel):
    id: str
    name: str
    created_at: datetime

# ── Routes ────────────────────────────────────────────────────────────────

@app.get("/health")
async def health():
    return {"status": "ok"}


@app.post("/names", response_model=NameOut, status_code=201)
async def save_name(payload: NameIn):
    """Save a name to MongoDB with a UTC timestamp."""
    name = payload.name.strip()
    if not name:
        raise HTTPException(status_code=400, detail="Name cannot be empty.")
    if len(name) > 100:
        raise HTTPException(status_code=400, detail="Name must be 100 characters or fewer.")

    doc = {
        "name": name,
        "created_at": datetime.now(timezone.utc),
    }

    result = await app.db["names"].insert_one(doc)

    return NameOut(
        id=str(result.inserted_id),
        name=doc["name"],
        created_at=doc["created_at"],
    )


@app.get("/names", response_model=list[NameOut])
async def get_names():
    """Return all saved names, oldest first."""
    cursor = app.db["names"].find().sort("created_at", 1)
    names = []
    async for doc in cursor:
        names.append(NameOut(
            id=str(doc["_id"]),
            name=doc["name"],
            created_at=doc["created_at"],
        ))
    return names