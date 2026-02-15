from fastapi import FastAPI, HTTPException, Form, File, UploadFile
from fastapi.staticfiles import StaticFiles
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel
from typing import List, Optional
import os
import shutil
import random
import qrcode
from io import BytesIO

app = FastAPI()

# CORS
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Uploads
UPLOAD_DIR = "uploads"
QR_DIR = "uploads/qrcodes"
DOC_DIR = "uploads/docs"
os.makedirs(UPLOAD_DIR, exist_ok=True)
os.makedirs(QR_DIR, exist_ok=True)
os.makedirs(DOC_DIR, exist_ok=True)

app.mount("/uploads", StaticFiles(directory="uploads"), name="uploads")

# --- MOCK DATA ---
USERS = {}
BIRDS = []
REGIONS = [
    "Toshkent shahri", "Toshkent viloyati", "Andijon", "Buxoro", "Jizzax", 
    "Qashqadaryo", "Navoiy", "Namangan", "Samarqand", "Surxondaryo", 
    "Sirdaryo", "Xorazm", "Farg'ona", "Qoraqalpog'iston"
]
TRANSACTIONS = []

# --- MODELS ---
class VerifyOtpRequest(BaseModel):
    phone: str
    code: str

class SendOtpRequest(BaseModel):
    phone: str

class UserUpdateProfileRequest(BaseModel):
    phone_number: str
    full_name: str
    region_id: int
    role: str = "user"
    show_phone: bool = True
    allow_telegram: bool = True

class LinkTelegramRequest(BaseModel):
    phone: str
    telegram_chat_id: int

class CreateBirdRequest(BaseModel):
    category: str
    breed: str
    price: float
    description: str
    region_id: int
    user_id: str

class MockConfirmRequest(BaseModel):
    transaction_id: str
    category: Optional[str] = None
    breed: Optional[str] = None
    price: Optional[float] = None
    description: Optional[str] = None
    region_id: Optional[int] = None
    user_id: Optional[str] = None



class TransactionRequest(BaseModel):
    bird_id: str
    amount: float
    payment_method: str # 'click' or 'payme'
    buyer_id: str

# --- AUTH ENDPOINTS ---
otp_storage = {}

@app.post("/auth/send-otp")
async def send_otp(request: SendOtpRequest):
    mock_code = "1122" # Fixed mock code
    otp_storage[request.phone] = mock_code
    return {"message": "SMS sent", "debug_code": mock_code, "phone": request.phone}

@app.post("/auth/verify-otp")
async def verify_otp(request: VerifyOtpRequest):
    stored_code = otp_storage.get(request.phone)
    if not stored_code or (request.code != stored_code and request.code != "1122"):
        raise HTTPException(status_code=400, detail="Invalid OTP")
    
    if request.phone in otp_storage:
        del otp_storage[request.phone]
        
    return {
        "access_token": f"mock_token_{request.phone}",
        "token_type": "bearer",
        "user_role": USERS.get(request.phone, {}).get("role", "user"),
        "is_new_user": request.phone not in USERS
    }

# --- USER ENDPOINTS ---
@app.get("/regions")
async def get_regions():
    return REGIONS

@app.post("/user/update-profile")
async def update_profile(
    phone_number: str = Form(...),
    full_name: str = Form(...),
    region_id: int = Form(...),
    role: str = Form("user")
):
    user = USERS.get(phone_number, {"id": f"u_{random.randint(1000,9999)}", "phone_number": phone_number})
    user.update({
        "full_name": full_name, 
        "region_id": region_id,
        "role": role,
        "show_phone": True,  # Default
        "allow_telegram": True # Default
    })
    USERS[phone_number] = user
    return {"status": "success", "user": user}

@app.post("/user/link-telegram")
async def link_telegram(request: LinkTelegramRequest):
    user = USERS.get(request.phone)
    if not user: raise HTTPException(404, "User not found")
    
    user["telegram_chat_id"] = request.telegram_chat_id
    USERS[request.phone] = user
    return {"status": "success", "message": "Telegram successfully linked", "user": user}

@app.post("/user/update-settings")
async def update_settings(request: UserUpdateProfileRequest):
    user = USERS.get(request.phone_number)
    if not user: raise HTTPException(404, "User not found")
    
    user.update({
        "show_phone": request.show_phone,
        "allow_telegram": request.allow_telegram
    })
    USERS[request.phone_number] = user
    return {"status": "success", "user": user}

# --- BIRD ENDPOINTS ---
CATEGORIES = ["Kabutar", "To'ti", "Kanareyka", "Bedana", "Tovuq", "O'rdak", "G'oz", "Boshqa"]

@app.get("/categories")
async def get_categories():
    return CATEGORIES

@app.post("/birds/create")
async def create_bird(bird: CreateBirdRequest):
    new_bird = bird.dict()
    new_bird.update({
        "id": f"bird_{len(BIRDS)+1}", 
        "status": "active", 
        "is_verified": False,
        "media": [],
        "document_url": None
    })
    BIRDS.append(new_bird)
    return {"status": "success", "bird": new_bird}

@app.post("/birds/create-with-media")
async def create_bird_with_media(
    category: str = Form(...),
    breed: str = Form(...),
    price: float = Form(...),
    description: str = Form(...),
    region_id: int = Form(...),
    user_id: str = Form(...),
    files: List[UploadFile] = File(...),
    document_url: str = Form(None)
):
    saved_paths = []
    for file in files:
        unique_name = f"{random.randint(10000,99999)}_{file.filename}"
        path = os.path.join(UPLOAD_DIR, unique_name)
        with open(path, "wb") as buffer:
            shutil.copyfileobj(file.file, buffer)
        saved_paths.append(f"/uploads/{unique_name}")
        
    new_bird = {
        "id": f"bird_{len(BIRDS)+1}",
        "category": category,
        "breed": breed,
        "price": price,
        "description": description,
        "region_id": region_id,
        "user_id": user_id,
        "status": "active",
        "media": saved_paths,
        "document_url": document_url,
        "is_verified": False
    }
    BIRDS.append(new_bird)
    return {"status": "success", "bird": new_bird}

@app.get("/birds")
async def get_birds(category: str = None, breed: str = None, is_verified: bool = None, q: str = None):
    results = []
    for bird in BIRDS:
        # Show 'active' and 'held' (so we can display "Sold/Held" badge)
        if bird.get("status") not in ["active", "held"]: continue
        
        # Filtering
        if category and category != "Hammasi" and bird["category"].lower() != category.lower(): continue
        if breed and breed.lower() not in bird["breed"].lower(): continue
        if is_verified is not None and bird.get("is_verified") != is_verified: continue
        
        # Search
        if q:
            query = q.lower()
            if query not in bird["category"].lower() and query not in bird["breed"].lower(): continue
            
        # Enrich
        user = next((u for u in USERS.values() if u.get("id") == bird["user_id"] or u.get("phone_number") == bird["user_id"]), {"full_name": "Sotuvchi", "phone_number": "Noma'lum"})
        region_name = REGIONS[int(bird["region_id"])-1] if 0 <= int(bird["region_id"])-1 < len(REGIONS) else "Noma'lum"
        
        bird_resp = bird.copy()
        bird_resp.update({
            "seller_name": user["full_name"],
            "seller_phone": user["phone_number"],
            "region_name": region_name
        })
        results.append(bird_resp)
    return results

# --- VERIFICATION & PASSPORT ---
@app.post("/birds/{bird_id}/generate-passport")
async def generate_passport(bird_id: str):
    # Find Bird
    bird = next((b for b in BIRDS if b["id"] == bird_id), None)
    if not bird: raise HTTPException(404, "Bird not found")
    
    # Generate QR
    qr = qrcode.QRCode(version=1, box_size=10, border=5)
    qr.add_data(f"https://qush-uyi.uz/birds/{bird_id}")
    qr.make(fit=True)
    img = qr.make_image(fill_color="black", back_color="white")
    
    filename = f"{bird_id}_passport.png"
    filepath = os.path.join(QR_DIR, filename)
    img.save(filepath)
    
    return {"status": "success", "passport_url": f"/uploads/qrcodes/{filename}"}

@app.get("/birds/{bird_id}/passport")
async def get_passport(bird_id: str):
    bird = next((b for b in BIRDS if b["id"] == bird_id), None)
    if not bird: raise HTTPException(404, "Bird not found")
    
    # Check if passport exists or generate on fly
    filename = f"{bird_id}_passport.png"
    if not os.path.exists(os.path.join(QR_DIR, filename)):
        await generate_passport(bird_id)
        
    return {
        "bird": bird,
        "passport_url": f"/uploads/qrcodes/{filename}",
        "is_verified": bird.get("is_verified", False)
    }

# --- PAYMENT (TASK 5.1) ---
@app.post("/pay/process")
async def process_payment(request: TransactionRequest):
    if request.amount <= 0: raise HTTPException(400, "Invalid amount")
    
    # Check if bird is already held or sold
    bird = next((b for b in BIRDS if b["id"] == request.bird_id), None)
    if not bird: raise HTTPException(404, "Bird not found")
    if bird["status"] != "active": raise HTTPException(400, "Bird is not available")

    tx_id = f"tx_{random.randint(100000, 999999)}"
    transaction = {
        "id": tx_id,
        "bird_id": request.bird_id,
        "amount": request.amount,
        "payment_method": request.payment_method,
        "buyer_id": request.buyer_id,
        "status": "held", # ESCROW HOLD
        "timestamp": "2023-10-27T10:00:00Z"
    }
    TRANSACTIONS.append(transaction)
    
    # UPDATE BIRD STATUS
    bird["status"] = "held"
    print(f"💰 ESCROW HOLD ACTIVATED: Bird {bird['id']} is now HELD for Transaction {tx_id}")
    
    return {"status": "success", "transaction": transaction}
    
@app.post("/pay/mock-confirm")
async def confirm_payment(request: MockConfirmRequest):
    # Find transaction
    tx = next((t for t in TRANSACTIONS if t["id"] == request.transaction_id), None)
    if not tx: raise HTTPException(404, "Transaction not found")
    
    # Update Status to HELD (if not already)
    tx["status"] = "held"
    tx["updated_at"] = "2023-10-27T10:05:00Z"
    
    # Ensure Bird is Held
    bird = next((b for b in BIRDS if b["id"] == tx["bird_id"]), None)
    if bird:
        bird["status"] = "held"
    
    return {
        "status": "success",
        "message": "Payment confirmed. Money is now HELD in Escrow.",
        "transaction": tx
    }

# --- DISPUTE & REFUND (TASK 5.3) ---
@app.post("/pay/dispute/{transaction_id}")
async def open_dispute(transaction_id: str):
    tx = next((t for t in TRANSACTIONS if t["id"] == transaction_id), None)
    if not tx: raise HTTPException(404, "Transaction not found")
    
    if tx["status"] != "held":
        raise HTTPException(400, "Only held transactions can be disputed")
        
    tx["status"] = "disputed"
    
    # Update Bird Status
    bird = next((b for b in BIRDS if b["id"] == tx["bird_id"]), None)
    if bird:
        bird["status"] = "disputed"
        
    return {"status": "success", "message": "Dispute opened", "transaction": tx}

@app.post("/pay/refund/{transaction_id}")
async def process_refund(transaction_id: str):
    tx = next((t for t in TRANSACTIONS if t["id"] == transaction_id), None)
    if not tx: raise HTTPException(404, "Transaction not found")
    
    # Allow refunding held or disputed transactions
    if tx["status"] not in ["held", "disputed"]:
        raise HTTPException(400, "Transaction cannot be refunded")
        
    tx["status"] = "refunded"
    
    # Release Bird back to Active
    bird = next((b for b in BIRDS if b["id"] == tx["bird_id"]), None)
    if bird:
        bird["status"] = "active"
        
    return {"status": "success", "message": "Money refunded to buyer. Bird is active again.", "transaction": tx}
