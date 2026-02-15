from fastapi import FastAPI, HTTPException, UploadFile, File, Form
from fastapi.middleware.cors import CORSMiddleware
from fastapi.staticfiles import StaticFiles
from pydantic import BaseModel
import random
import os
import shutil
from typing import List

app = FastAPI(title="Qush Uyi API", version="1.0")

# Setup Uploads Directory
UPLOAD_DIR = "uploads"
os.makedirs(UPLOAD_DIR, exist_ok=True)

# Mount Uploads for Static Access (e.g. http://localhost:8000/uploads/file.jpg)
app.mount("/uploads", StaticFiles(directory=UPLOAD_DIR), name="uploads")

# CORS Configuration (Allow All for Web/Desktop dev)
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# ... (Auth Models & Endpoints remain same) ...

# --- BIRD LISTING & MEDIA FEATURE ---

# Setup Uploads Directory for Documents
DOCS_UPLOAD_DIR = "uploads/docs"
os.makedirs(DOCS_UPLOAD_DIR, exist_ok=True)

# ... (Previous code) ...

# --- BIRD LISTING, MEDIA & VERIFICATION FEATURE ---

@app.post("/upload/document")
async def upload_document(file: UploadFile = File(...)):
    # Generate unique filename for document
    unique_name = f"doc_{random.randint(100000, 999999)}_{file.filename}"
    file_path = os.path.join(DOCS_UPLOAD_DIR, unique_name)
    
    with open(file_path, "wb") as buffer:
        shutil.copyfileobj(file.file, buffer)
        
    return {"status": "success", "url": f"/uploads/docs/{unique_name}"}

@app.post("/birds/create-with-media")
async def create_bird_with_media(
    category: str = Form(...),
    breed: str = Form(...),
    price: float = Form(...),
    description: str = Form(...),
    region_id: int = Form(...),
    user_id: str = Form(...),
    document_url: str = Form(None), # Optional Document URL
    files: List[UploadFile] = File(...)
):
    # 1. Validation
    if not files or len(files) == 0:
         raise HTTPException(status_code=400, detail="At least one image is required")
    
    saved_file_paths = []
    
    for file in files:
        # Generate unique filename
        file_ext = file.filename.split(".")[-1]
        unique_name = f"{random.randint(100000, 999999)}_{file.filename}"
        file_path = os.path.join(UPLOAD_DIR, unique_name)
        
        # 2. Save File
        with open(file_path, "wb") as buffer:
            shutil.copyfileobj(file.file, buffer)
            
        # 3. Compress Video (Placeholder for FFMPEG)
        if file.content_type.startswith("video"):
            print(f"Server: Compressing video {unique_name} using FFMPEG...")
            # subprocess.run(["ffmpeg", "-i", file_path, ...])
            
        saved_file_paths.append(f"/uploads/{unique_name}")

    # 4. Save Bird Data
    new_bird = {
        "id": f"bird_{random.randint(10000, 99999)}",
        "category": category,
        "breed": breed,
        "price": price,
        "description": description,
        "region_id": region_id,
        "user_id": user_id,
        "status": "active", # Auto-publish (Task 2.3)
        "media": saved_file_paths,
        "document_url": document_url, # Store document path
        "is_verified": False # Default to False
    }
    
    BIRDS.append(new_bird)
    return {"status": "success", "bird": new_bird}

# Models
class SendOtpRequest(BaseModel):
    phone: str

class VerifyOtpRequest(BaseModel):
    phone: str
    code: str

class UserUpdateProfileRequest(BaseModel):
    full_name: str
    region_id: int

# In-memory storage for demo purposes (Use Redis/DB in production)
otp_storage = {}

# Mock Regions Data
REGIONS = [
    {"id": 1, "name_uz": "Andijon viloyati"},
    {"id": 2, "name_uz": "Buxoro viloyati"},
    {"id": 3, "name_uz": "Farg'ona viloyati"},
    {"id": 4, "name_uz": "Jizzax viloyati"},
    {"id": 5, "name_uz": "Xorazm viloyati"},
    {"id": 6, "name_uz": "Namangan viloyati"},
    {"id": 7, "name_uz": "Navoiy viloyati"},
    {"id": 8, "name_uz": "Qashqadaryo viloyati"},
    {"id": 9, "name_uz": "Samarqand viloyati"},
    {"id": 10, "name_uz": "Sirdaryo viloyati"},
    {"id": 11, "name_uz": "Surxondaryo viloyati"},
    {"id": 12, "name_uz": "Toshkent viloyati"},
    {"id": 13, "name_uz": "Toshkent shahri"},
    {"id": 14, "name_uz": "Qoraqalpog'iston Respublikasi"},
]

@app.post("/auth/send-otp")
async def send_otp(request: SendOtpRequest):
    # Generate 4-digit mock code
    mock_code = str(random.randint(1000, 9999))
    otp_storage[request.phone] = mock_code
    
    # In real app, send request to SMS provider here
    return {
        "message": "SMS sent successfully",
        "debug_code": mock_code, # Returned for testing ease
        "phone": request.phone
    }

@app.post("/auth/verify-otp")
async def verify_otp(request: VerifyOtpRequest):
    stored_code = otp_storage.get(request.phone)
    
    if not stored_code:
        raise HTTPException(status_code=400, detail="OTP not sent or expired")
    
    if request.code != stored_code and request.code != "1122": # 1122 is master code
        raise HTTPException(status_code=400, detail="Invalid OTP code")
        
    # Clear OTP after success
    if request.phone in otp_storage:
        del otp_storage[request.phone]
        
    # Generate Mock JWT
    mock_token = f"ey_mock_jwt_token_for_{request.phone}"
    
    return {
        "access_token": mock_token,
        "token_type": "bearer",
        "user_role": "user", # Default role
        "is_new_user": True, # Always true for demo to trigger profile fill
        "user": {
            "id": "mock_user_id",
            "phone": request.phone
        }
    }

@app.get("/regions")
async def get_regions():
    return REGIONS

@app.post("/user/update-profile")
async def update_profile(
    phone_number: str = Form(...),
    full_name: str = Form(...),
    region_id: int = Form(...),
    role: str = Form("user") # Default to user, can be 'seller'
):
    # Mock Update Logic
    # In real app: UPDATE users SET full_name=..., region_id=..., role=... WHERE phone_number=...
    
    # Update local mock storage if exists (simplified)
    for user in USERS.values():
        if user.get("phone_number") == phone_number:
            user["full_name"] = full_name
            user["region_id"] = region_id
            user["role"] = role
            return {"status": "success", "user": user}
            
    # If not found, create (lazy create for mock)
    new_user = {
        "id": f"user_{random.randint(1000,9999)}",
        "phone_number": phone_number,
        "full_name": full_name,
        "region_id": region_id,
        "role": role 
    }
    USERS[phone_number] = new_user
    
    return {"status": "success", "user": new_user}

# --- BIRD LISTING FEATURE ---

class CreateBirdRequest(BaseModel):
    category: str
    breed: str
    price: float
    description: str
    region_id: int
    user_id: str # In real app, get from Token

# Mock Bird Data
BIRDS = []

CATEGORIES = [
    "Kabutar", "To'ti", "Kanareyka", "Bedana", "Tovuq", "O'rdak", "G'oz", "Boshqa"
]

@app.get("/categories")
async def get_categories():
    return CATEGORIES

@app.post("/birds/create")
async def create_bird(bird: CreateBirdRequest):
    new_bird = {
        "id": f"bird_{len(BIRDS) + 1}",
        "category": bird.category,
        "breed": bird.breed,
        "price": bird.price,
        "description": bird.description,
        "region_id": bird.region_id,
        "user_id": bird.user_id,
        "status": "active", # Auto-publish (Task 2.3)
        "is_verified": False
    }
    BIRDS.append(new_bird)
    return {"status": "success", "bird": new_bird}

@app.get("/birds")
async def get_birds(category: str = None, breed: str = None, is_verified: bool = None):
    # Filter logic
    filtered_birds = BIRDS
    if category and category != "Hammasi":
        filtered_birds = [b for b in filtered_birds if b["category"].lower() == category.lower()]
    if breed:
        filtered_birds = [b for b in filtered_birds if breed.lower() in b["breed"].lower()]
    if is_verified is not None:
         filtered_birds = [b for b in filtered_birds if b.get("is_verified") == is_verified]
        
    return filtered_birds

@app.post("/admin/approve-bird/{bird_id}")
async def approve_bird(bird_id: str):
    for bird in BIRDS:
        if bird["id"] == bird_id:
            bird["is_verified"] = True
            return {"status": "success", "message": f"Bird {bird_id} verified"}
    raise HTTPException(status_code=404, detail="Bird not found")

try:
    import qrcode
except ImportError:
    qrcode = None

# Setup Uploads Directory for QR Codes
QR_UPLOAD_DIR = "uploads/qrcodes"
os.makedirs(QR_UPLOAD_DIR, exist_ok=True)

# ...

@app.post("/birds/{bird_id}/generate-passport")
async def generate_passport(bird_id: str):
    # Find Bird
    bird = next((b for b in BIRDS if b["id"] == bird_id), None)
    if not bird:
        raise HTTPException(status_code=404, detail="Bird not found")
        
    qr_filename = f"qr_{bird_id}.png"
    qr_path = os.path.join(QR_UPLOAD_DIR, qr_filename)
    
    # Generate QR Code
    if qrcode:
        # Data to encode (e.g., link to bird detail)
        qr_data = f"https://qushuyi.uz/birds/{bird_id}"
        img = qrcode.make(qr_data)
        img.save(qr_path)
    else:
        # Mock QR creation if library not installed
        with open(qr_path, "wb") as f:
            f.write(b"Mock QR Code Content") 
            
    # Update Bird with QR Path
    bird["passport_qr"] = f"/uploads/qrcodes/{qr_filename}"
    
    return {"status": "success", "qr_url": bird["passport_qr"]}

@app.get("/birds/{bird_id}/passport")
async def get_bird_passport(bird_id: str):
    bird = next((b for b in BIRDS if b["id"] == bird_id), None)
    if not bird:
        raise HTTPException(status_code=404, detail="Bird not found")
        
    # Auto-generate if missing
    if "passport_qr" not in bird:
        await generate_passport(bird_id)
        
    return {
        "bird_name": f"{bird['category']} - {bird['breed']}",
        "is_verified": bird.get("is_verified", False),
        "qr_code": bird.get("passport_qr"),
        "owner_id": bird["user_id"],
        "region_id": bird["region_id"],
        "issued_at": "2026-02-15" # Mock date
    }

@app.get("/")
async def root():
    return {"message": "Qush Uyi API is running"}
